From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

(* Extraction keeps one erased parameter on a function whose every
   parameter is a proof, and the erased arrows of a function-typed
   parameter. The output drops them: three is nullary, as are its calls,
   its uses as a value, and the calls of h. *)
Definition three : True -> nat := fun _ => 3.
Definition apply_proof (h : True -> nat) : nat := h I.
Definition applied : nat := apply_proof three.
Definition as_value : True -> nat := three.
Definition twice (h : True -> True -> nat) : nat := h I I.
Definition five : True -> True -> nat := fun _ _ => 5.
Definition applied_twice : nat := twice five.
Definition local_erased (n : nat) : nat := let f := fun (_ : True) => n in f I + f I.
Definition from_option (o : option (True -> nat)) : nat :=
  match o with Some f => f I | None => 0 end.
Definition some_three : option (True -> nat) := Some three.

TypeScript Extraction "erased.ts"
  three apply_proof applied as_value twice five applied_twice local_erased from_option
  some_three.
