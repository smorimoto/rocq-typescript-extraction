open Import
open Names
open Extraction_plugin
module Refset = Table.Refset'

type subject =
  | Globals of Miniml.global list
  | Module of ModPath.t

let informative_instances gr =
  let context = Environ.universes_of_global (Global.env ()) gr in
  List.map (Miniml.InfvInst.generate context) ~f:(fun inst -> { Miniml.glob = gr; inst })
;;

let subject qid =
  let module_ =
    match Nametab.locate_module qid with
    | mp -> Some mp
    | exception Stdlib.Not_found -> None
  in
  let global =
    match Smartlocate.global_with_alias qid with
    | gr -> Some gr
    | exception (Nametab.GlobalizationError _ | CErrors.UserError _) -> None
  in
  match module_, global with
  | Some mp, Some gr ->
    Table.warning_ambiguous_name ?loc:qid.CAst.loc (qid, mp, gr);
    Module mp
  | Some mp, None -> Module mp
  | None, Some gr -> Globals (informative_instances gr)
  | None, None ->
    (match Nametab.locate_modtype qid with
     | _ ->
       CErrors.user_err
         ?loc:qid.CAst.loc
         Pp.(
           str "TypeScript extraction cannot name the module type "
           ++ Libnames.pr_qualid qid
           ++ str " in a command. Its interface is declared with a functor that takes it"
           ++ str " or with a module sealed by it; ask for one of those.")
     | exception Stdlib.Not_found -> Nametab.error_global_not_found ~info:Exninfo.null qid)
;;

let subjects qids =
  let globals, modules =
    List.partition_map qids ~f:(fun qid ->
      match subject qid with
      | Globals gs -> Either.First gs
      | Module mp -> Either.Second mp)
  in
  List.concat globals, modules
;;

(* The environment that extraction reads closes every open module and
   module type as a structure, so a command run inside a module type would
   write the module type as a module object. *)
let check_outside_module_type () =
  let opened = function
    | Lib.OpenedModule (true, _, prefix, _), _ -> Some prefix.Libobject.obj_mp
    | (Lib.OpenedModule _ | Lib.OpenedSection _ | Lib.CompilingLibrary _), _ -> None
  in
  match List.rev (List.filter_map (Lib.contents ()) ~f:opened) with
  | [] -> ()
  | outermost :: _ ->
    let name =
      String.concat
        ~sep:"."
        (List.rev_map (snd (Lib.split_modpath outermost)) ~f:Id.to_string)
    in
    CErrors.user_err
      Pp.(
        str "TypeScript extraction cannot run inside the module type "
        ++ str name
        ++ str ", since a module type has no value; run the command outside it.")
;;

let directive_objects =
  [ "ML extractions"
  ; "ML extractions custom matches"
  ; "Extraction Inline"
  ; "TypeScript Extract Match"
  ]
;;

(* Rocq caches a directive given in a functor body only at each
   application, under the application's path, and drops it when the
   functor closes, so the body's own globals are in no table. The
   functor's substitutive objects keep the directive with the body's
   globals, and caching it from there registers them. An Include in the
   body keeps a reference to the objects of the included module instead,
   whose directives are cached under the substitution of the include. *)
let replay_functor_directives () =
  let modules = Hashtbl.create (module Ts_modpath_key) ~size:16 in
  let collect (prefix : Libobject.object_prefix) (o : Libobject.t) =
    match o with
    | Libobject.ModuleObject (id, (_, aobjs)) ->
      Hashtbl.set modules ~key:(ModPath.MPdot (prefix.obj_mp, id)) ~data:aobjs
    | Libobject.AtomicObject _
    | Libobject.IncludeObject _
    | Libobject.ModuleTypeObject _
    | Libobject.KeepObject _
    | Libobject.EscapeObject _
    | Libobject.ExportObject _ -> ()
  in
  Declaremods.iter_all_interp_segments collect;
  let rec visit ~in_functor ~subst prefix (o : Libobject.t) =
    match o with
    | Libobject.AtomicObject a ->
      if
        in_functor
        && List.mem directive_objects (Libobject.object_name a) ~equal:String.equal
      then (
        let a =
          match subst with
          | Some subst -> Libobject.subst_object (subst, a)
          | None -> a
        in
        Libobject.cache_object (prefix, a))
    | Libobject.ModuleObject (_, (mbids, aobjs)) ->
      algebraic ~in_functor:(in_functor || not (List.is_empty mbids)) ~subst prefix aobjs
    | Libobject.IncludeObject aobjs -> algebraic ~in_functor ~subst prefix aobjs
    | Libobject.ModuleTypeObject _
    | Libobject.KeepObject _
    | Libobject.EscapeObject _
    | Libobject.ExportObject _ -> ()
  and algebraic ~in_functor ~subst prefix = function
    | Libobject.Objs objs -> List.iter objs ~f:(visit ~in_functor ~subst prefix)
    | Libobject.Ref (mp, s) when in_functor ->
      let subst =
        match subst with
        | Some outer -> Mod_subst.join s outer
        | None -> s
      in
      Option.iter
        (Hashtbl.find modules mp)
        ~f:(algebraic ~in_functor ~subst:(Some subst) prefix)
    | Libobject.Ref _ -> ()
  in
  Declaremods.iter_all_interp_segments (visit ~in_functor:false ~subst:None)
;;

(* Includes can predate the realiser of their original constant. Extraction
   indexes directives by user name, so replay that realiser for an alias only
   when it has no directive of its own. *)
let inherit_constant_directives () =
  let env = Global.env () in
  Environ.fold_constants
    (fun c _ () ->
       let original = Constant.make1 (Environ.lookup_constant_canonical c env) in
       if not (Constant.UserOrd.equal c original)
       then (
         let aliases = informative_instances (GlobRef.ConstRef c) in
         List.iter aliases ~f:(fun alias ->
           let source = { alias with glob = GlobRef.ConstRef original } in
           if (not (Table.is_custom alias)) && Table.is_custom source
           then (
             let ids, code = Table.find_type_custom source in
             let name = Libnames.qualid_of_string (Constant.to_string c) in
             let inline =
               Table.to_inline alias
               || (Table.to_inline source && not (Table.to_keep alias))
             in
             if Table.is_foreign_custom source
             then Table.extract_constant_foreign name code
             else Table.extract_constant_inline inline name ids code))))
    env
    ()
;;

let with_directives f =
  let frozen = Summary.Interp.freeze_summaries () in
  Exn.protect
    ~f:(fun () ->
      replay_functor_directives ();
      inherit_constant_directives ();
      f ())
    ~finally:(fun () -> Summary.Interp.unfreeze_summaries frozen)
;;

let session ~modular =
  Table.check_inside_section ();
  check_outside_module_type ();
  Common.State.make ~modular ~library:false ~keywords:Typescript.keywords ()
;;

(* Selecting OCaml adds an object to the library, which the protection
   drops, restoring the user's language, whether [f] returns or raises. *)
let in_ocaml f x =
  Vernacstate.System.protect
    (fun x ->
       Table.extraction_language Table.Ocaml;
       f x)
    x
;;

let extract state ~opaque_access (globals, modules) =
  let rec close globals =
    let structure = Extract_env.mono_environment state ~opaque_access globals modules in
    let structure = Modutil.optimize_struct state (globals, modules) structure in
    let refined =
      Ts_known.reduce
        (Ts_alias.resolve structure)
        ~separate:(Common.State.get_modular state)
    in
    let sigs = Ts_sig.create refined in
    let env = Ts_env.create state sigs refined in
    match Ts_env.missing_dependencies env sigs refined with
    | [] -> structure
    | missing ->
      let roots = List.fold globals ~init:Refset.empty ~f:(fun s r -> Refset.add r s) in
      List.iter missing ~f:(fun r ->
        if Refset.mem r roots
        then
          CErrors.anomaly
            Pp.(
              str "Ts_extract.extract: reconstructed dependency was not extracted: "
              ++ Printer.pr_global r.glob));
      close (missing @ globals)
  in
  let structure = close globals in
  let table = Common.State.get_table state in
  Table.warning_opaques table (Table.access_opaque ());
  Ts_primitives.remove_owned_axioms table;
  Table.warning_axioms table;
  structure
;;

let warn_unchecked_casts =
  CWarnings.create
    ~name:"typescript-extraction-unchecked-casts"
    ~category:CWarnings.CoreCategories.extraction
    (fun n ->
       Pp.(
         str "TypeScript extraction inserted "
         ++ int n
         ++ str (if n = 1 then " cast" else " casts")
         ++ str " (__magic) where its type reconstruction disagrees with"
         ++ spc ()
         ++ str "extraction. tsc does not check the code at those casts."))
;;

let report (stats : Typescript.stats) =
  if stats.unchecked_casts > 0 then warn_unchecked_casts stats.unchecked_casts
;;

let show contents =
  Feedback.msg_notice
    (Pp.prlist_with_sep Pp.fnl Pp.str (String.split (String.strip contents) ~on:'\n'))
;;

let write path contents =
  Out_channel.write_all path ~data:contents;
  Table.info_file path
;;

let output_path name =
  let base = String.chop_suffix_if_exists name ~suffix:Typescript.file_suffix in
  let base =
    if Stdlib.Filename.is_relative base
    then Stdlib.Filename.concat (Table.output_directory ()) base
    else base
  in
  base ^ Typescript.file_suffix
;;

let whole_module ~opaque_access destination (globals, modules) =
  List.iter modules ~f:(fun mp ->
    if Table.is_modfile mp then Table.error_MPfile_as_mod mp true);
  let state = session ~modular:false in
  let requested = globals, modules in
  let contents, stats =
    Typescript.structure state ~requested (extract state ~opaque_access requested)
  in
  report stats;
  match destination with
  | None -> show contents
  | Some name -> write (output_path name) contents
;;

let full_extraction ~opaque_access destination qids =
  in_ocaml
    (fun qids ->
       with_directives (fun () -> whole_module ~opaque_access destination (subjects qids)))
    qids
;;

let simple ~opaque_access qid =
  with_directives
  @@ fun () ->
  match subject qid with
  | Module mp -> whole_module ~opaque_access None ([], [ mp ])
  | Globals globals ->
    let state = session ~modular:false in
    let structure = extract state ~opaque_access (globals, []) in
    List.iter globals ~f:(fun global ->
      let contents, stats = Typescript.declaration state structure global in
      report stats;
      show contents)
;;

let simple_extraction ~opaque_access qid = in_ocaml (simple ~opaque_access) qid

let separate ~opaque_access qids =
  with_directives
  @@ fun () ->
  let state = session ~modular:true in
  let requested = subjects qids in
  let structure = extract state ~opaque_access requested in
  let outputs, stats = Typescript.files state ~requested structure in
  report stats;
  List.iter outputs ~f:(fun (name, contents) ->
    write
      (Stdlib.Filename.concat (Table.output_directory ()) (name ^ Typescript.file_suffix))
      contents)
;;

let separate_extraction ~opaque_access qids = in_ocaml (separate ~opaque_access) qids
