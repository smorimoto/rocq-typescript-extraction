(** Extraction commands for the TypeScript backend.

    The functions below are the entry points behind the
    [TypeScript Extraction] vernacular commands. They drive the MiniML
    pipeline of Rocq's extraction plugin and hand the result to
    {!Typescript}. Each reads the bodies of opaque constants through its
    [opaque_access] argument. Each extracts under
    [Extraction Language OCaml], whose MiniML the backend reads, whatever
    the language set, and restores the language set when it returns or
    raises. *)

(** [simple_extraction ~opaque_access q] prints the TypeScript extraction
    of [q] to the standard output, reading opaque bodies through
    [opaque_access]. If [q] is a module, the whole module is extracted. *)
val simple_extraction : opaque_access:Global.indirect_accessor -> Libnames.qualid -> unit

(** [full_extraction ~opaque_access file qs] extracts [qs] and everything
    they depend on into one TypeScript module, reading opaque bodies
    through [opaque_access]. It writes the module to [f] when [file] is
    [Some f], and prints it to the standard output when [file] is
    [None]. *)
val full_extraction
  :  opaque_access:Global.indirect_accessor
  -> string option
  -> Libnames.qualid list
  -> unit

(** [separate_extraction ~opaque_access qs] extracts [qs] and everything
    they depend on, one TypeScript file per Rocq library file, reading
    opaque bodies through [opaque_access]. *)
val separate_extraction
  :  opaque_access:Global.indirect_accessor
  -> Libnames.qualid list
  -> unit
