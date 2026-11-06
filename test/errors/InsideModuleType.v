From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Extraction Output Directory ".".

(* The environment closes an open module type as a structure, which would
   write it as a module object, so a command run inside one names the
   outermost module type. *)
Module M.
  Module Type T.
    Definition w : nat := 4.
    Module Type U.
      Definition v : nat := 5.
      Redirect "InsideModuleType" Fail TypeScript Separate Extraction v.
    End U.
  End T.
End M.
