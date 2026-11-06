From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

CoInductive stream (A : Type) := SCons (h : A) (t : stream A).
Arguments SCons {A}.

CoFixpoint from (n : nat) : stream nat := SCons n (from (S n)).
CoFixpoint ones : stream nat := SCons 1 ones.

CoFixpoint map_s {A B} (f : A -> B) (s : stream A) : stream B :=
  match s with SCons h t => SCons (f h) (map_s f t) end.

Definition shead {A} (s : stream A) : A := match s with SCons h _ => h end.
Definition stail {A} (s : stream A) : stream A := match s with SCons _ t => t end.

Fixpoint take {A} (n : nat) (s : stream A) : list A :=
  match n with
  | 0 => nil
  | S k => match s with SCons h t => cons h (take k t) end
  end.

Definition evens : stream nat := map_s (fun n => n + n) (from 0).

CoInductive colist := CNil | CCons (h : nat) (t : colist).
CoFixpoint countdown (n : nat) : colist :=
  match n with 0 => CNil | S k => CCons n (countdown k) end.
Definition head_or (d : nat) (l : colist) : nat :=
  match l with CNil => d | CCons h _ => h end.

TypeScript Extraction "streams.ts" from ones map_s shead stail take evens countdown head_or.
