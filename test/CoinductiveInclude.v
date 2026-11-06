From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".

Module Type INPUT.
  Parameter token : Type.
End INPUT.

Module Make (I : INPUT).
  CoInductive buffer := Buf_cons { buf_head : I.token; buf_tail : buffer }.
End Make.

Module Type INTER (I : INPUT).
  Include (Make I).
End INTER.

Module Use (I : INPUT) (Inter : INTER I).
  Definition prepend (head : I.token) (tail : Inter.buffer) :=
    Inter.Buf_cons head tail.
  Definition head (buffer : Inter.buffer) := Inter.buf_head buffer.
End Use.

Module Driver (I : INPUT).
  Module Inter := Make I.
  Module Consumer := Use I Inter.
End Driver.

TypeScript Extraction "coinductive-include.ts" Driver.
