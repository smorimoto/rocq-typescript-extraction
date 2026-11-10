(** Module alias resolution.

    [Module M := N] and [with Module M := N] make references through [M]
    refer to declarations in [N]. Resolution follows alias chains in
    structures, functor bodies, and module types. *)

open Extraction_plugin

(** [resolve struc] is [struc] with references through aliases replaced
    by references to their declarations. For [Module M := N], [M.x]
    becomes [N.x]. Resolution follows aliases at any level of a path,
    including nested aliases and references in functor bodies and module
    types. Module expressions, functor applications, and [with Module]
    constraints name their resolved targets. Declarations keep their
    names, and aliases remain [MEident] modules in [struc]. *)
val resolve : Miniml.ml_structure -> Miniml.ml_structure

(** [global struc r] is the global that [r] stands for in the output of
    {!resolve}. It is [r] itself or the declaration reached through an
    alias. *)
val global : Miniml.ml_structure -> Miniml.global -> Miniml.global

(** [rebase mp r] is the global named like [r] in the module [mp]. It is
    how a type [N.t] is named through the alias [M], as [M.t]. *)
val rebase : Names.ModPath.t -> Miniml.global -> Miniml.global

(** [find struc mp] is the structure of the file or module [mp] in
    [struc], or [None] if no such structure exists. Applications,
    functors, and functor parameters have no structure. *)
val find : Miniml.ml_structure -> Names.ModPath.t -> Miniml.ml_module_structure option

(** [functor_body me] is the structure under the functor parameters of
    [me], with its path, or [None] if a module name or an application is
    under them. A structure is its own body. *)
val functor_body
  :  Miniml.ml_module_expr
  -> (Names.ModPath.t * Miniml.ml_module_structure) option
