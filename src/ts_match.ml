open Import
open Names
open Extraction_plugin
open Miniml

type selector =
  { test : string option
  ; args : string list
  }

let table = Summary.ref ~name:"TypeScriptExtractMatch" Table.Refmap'.empty
let find r = Table.Refmap'.find_opt r !table

let directive : global * selector array -> Libobject.obj =
  Libobject.declare_object
  @@ Libobject.superglobal_object_nodischarge
       "TypeScript Extract Match"
       ~cache:(fun (r, selectors) -> table := Table.Refmap'.add r selectors !table)
       ~subst:
         (Some
            (fun (s, (r, selectors)) ->
              { r with glob = fst (Globnames.subst_global s r.glob) }, selectors))
;;

let extract_match q selectors =
  Table.check_inside_section ();
  let gr = Smartlocate.global_with_alias q in
  let loc = q.CAst.loc in
  Dumpglob.add_glob ?loc gr;
  let directive_for = Pp.(str "TypeScript Extract Match for " ++ Printer.pr_global gr) in
  let count n word =
    Pp.(int n ++ str " " ++ str word ++ str (if n = 1 then "" else "s"))
  in
  match gr with
  | GlobRef.IndRef (kn, i) ->
    let mib = Global.lookup_mind kn in
    let n = Array.length mib.Declarations.mind_packets.(i).Declarations.mind_consnames in
    let given = List.length selectors in
    if given <> n
    then
      CErrors.user_err
        ?loc
        Pp.(
          directive_for
          ++ str " gives "
          ++ count given "selector"
          ++ str ", but the type has "
          ++ count n "constructor"
          ++ str ", one selector each.");
    let untested = List.count selectors ~f:(fun s -> Option.is_none s.test) in
    if n = 1 && untested = 0
    then
      CErrors.user_err
        ?loc
        Pp.(
          directive_for
          ++ str " gives a test for its one constructor, which no match tests, so"
          ++ str " its selector is written with _.");
    if n > 1 && untested > 0
    then
      CErrors.user_err
        ?loc
        Pp.(
          directive_for
          ++ str " writes "
          ++ count untested "selector"
          ++ str " with _, but a type of several constructors needs a test for each.");
    let context = Environ.universes_of_global (Global.env ()) gr in
    List.iter (InfvInst.generate context) ~f:(fun inst ->
      Lib.add_leaf (directive ({ glob = gr; inst }, Array.of_list selectors)))
  | GlobRef.VarRef _ | GlobRef.ConstRef _ | GlobRef.ConstructRef _ ->
    CErrors.user_err
      ?loc
      Pp.(
        str "TypeScript Extract Match: "
        ++ Printer.pr_global gr
        ++ str " is not an inductive type.")
;;
