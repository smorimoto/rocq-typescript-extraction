From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".

Definition sum_to (n : nat) : nat :=
  let fix go (k acc : nat) : nat :=
    match k with 0 => acc | S k' => go k' (acc + k) end
  in go n 0.

Definition parity (n : nat) : bool :=
  (fix ev (k : nat) : bool := match k with 0 => true | S k' => od k' end
   with od (k : nat) : bool := match k with 0 => false | S k' => ev k' end
   for ev) n.

Definition twice_plus (n : nat) : nat :=
  let f := fun x y => x + y + y in f n (f n 1).

Definition double_plus (n m : nat) : nat := (let k := S n in k + k) + m.

Definition countdown (n : nat) : list nat :=
  match n with
  | 0 => nil
  | S p =>
    let fix go (k : nat) : list nat :=
      match k with 0 => cons p nil | S k' => cons k (go k') end
    in go p
  end.

Definition adder (n : nat) : nat -> nat :=
  let base := n + n in fun m => base + m.

TypeScript Extraction "lets.ts" sum_to parity twice_plus double_plus countdown adder.
