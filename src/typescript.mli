(** The TypeScript backend, from an optimised MiniML structure to the text
    of TypeScript modules.

    The driver calls no other module of the backend. The backend owns the
    layout of a module. It decides which declarations a Rocq declaration
    becomes, where they go, how a Rocq module becomes flat file-level
    values and types and a module object, how a module alias becomes the
    object of the module it stands for and one type alias per type of that
    module, how a module type becomes an interface whose type parameters
    are the abstract types its members mention, with its types at the top
    level, listing only the members that some functor reads unless it
    types what a functor returns, how a constraint on a module type fixes
    a type parameter, how a functor signature becomes an alias of a
    generic arrow type, how a functor becomes a generic arrow, curried
    per parameter, from the interfaces of its parameters to the interface
    of its result, or of the module type it is sealed with, with its
    types, the modules and module types of its body, and the members that
    read nothing of the body at the top level, how an application becomes
    the call of the functor with the type arguments the argument modules
    instantiate and one alias per type of its signature, or a generic
    arrow over the parameters left when it is partial, and which
    declarations a module exports, writes without exporting, or leaves
    out.

    A declaration is exported when the command asked for it. The command
    asks for a global it names, the object of a top-level module that it
    names or that holds something it names, and a type declared in a
    module it names. Asking for an inductive type asks for its constructor
    interfaces and its constructor functions, asking for an
    [Extract Inductive] type asks for its realisers, and asking for a
    constructor asks for its constructor function, or for its realiser. A global asked for
    through a module alias is the declaration it stands for, and the alias
    is asked for with it. A declaration is also
    exported when the signature of an exported declaration names its type,
    transitively through the types a type names, and then so are the
    constructor functions that build its values, the object of the
    top-level module that holds them, or the functor whose body declares
    the type. The members of a module object count as its signature, and
    so do the functor and the type arguments of an application, so an
    exported application exports its functor, and the functor's signature
    exports the interfaces of its parameters and of its result. In
    separate extraction, a declaration is also exported when another file
    refers to it. Every other declaration is
    private, and is written only when a written declaration of its file,
    or of any file in separate extraction, refers to it, so a constructor
    function, a realiser, a helper, or a member of a mutually recursive
    group that nothing uses is left out, as is a module object that nothing
    asks for. The code of an [Extract] directive is read for the names it
    mentions outside its string literals. *)

open Extraction_plugin

(** [keywords] is {!Ts_names.keywords}, for [Common.State.make]. *)
val keywords : Names.Id.Set.t

(** [file_suffix] is [".ts"]. *)
val file_suffix : string

(** The type for statistics about the output. [unchecked_casts] is the
    number of casts that reconstruction inserted where it disagreed with
    extraction, summed over the output. *)
type stats = { unchecked_casts : int }

(** [structure state ~requested struc] is one TypeScript module holding
    the declarations of [struc] that the rule above keeps, with all its
    files flattened into one module and named in one scope, and the
    statistics of the output. [requested] is the globals and the modules
    the command asked for, and [state] is the extraction state that
    produced [struc]. *)
val structure
  :  Common.State.t
  -> requested:Miniml.global list * Names.ModPath.t list
  -> Miniml.ml_structure
  -> string * stats

(** [files state ~requested struc] is one TypeScript module per file of
    [struc] that keeps a declaration, each with the name of its file
    without the suffix, as {!Ts_names.file_name} gives it, and with
    [import * as $Dep from "./dep.ts"] for every file its kept declarations
    refer to, and the statistics of the output. A file that keeps no
    declaration, such as [Datatypes] under the Number preset when only its
    mapped types are used, gets no module, header comment or not, and no
    module imports it. Names are assigned over the whole of [struc] first,
    so cross-file references agree. [requested] is the globals and the
    modules the command asked for, and [state] is the extraction state
    that produced [struc]. *)
val files
  :  Common.State.t
  -> requested:Miniml.global list * Names.ModPath.t list
  -> Miniml.ml_structure
  -> (string * string) list * stats

(** [declaration state struc r] is the declarations that [r] becomes, alone
    and every one exported, and the statistics of the output. Their types
    and arities still come from all of [struc]. An inductive that
    [Extract Inductive] realises shows every realiser, where {!structure}
    and {!files} declare only those that the output refers to. [state] is
    the extraction state that produced [struc]. *)
val declaration : Common.State.t -> Miniml.ml_structure -> Miniml.global -> string * stats
