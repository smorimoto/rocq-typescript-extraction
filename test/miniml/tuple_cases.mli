(** The full module for TypeScript type, format, and runtime checks. *)
val source : unit -> string

(** The generated declaration named by a tuple fixture, using the full module
    for type reconstruction. *)
val declaration : string -> string

(** The tag type and constructors used by the conditional tuple fixture. *)
val sign_declaration : unit -> string
