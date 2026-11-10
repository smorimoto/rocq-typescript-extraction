(** [source ()] is the full module for the TypeScript type, format, and
    runtime checks. *)
val source : unit -> string

(** [declaration name] is the generated declaration of the tuple fixture
    [name], with types reconstructed over the full module. *)
val declaration : string -> string

(** [sign_declaration ()] is the generated declaration of the tag type and
    the constructors that the conditional tuple fixture uses. *)
val sign_declaration : unit -> string
