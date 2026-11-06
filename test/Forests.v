From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

Inductive tree := Node (x : nat) (children : forest)
with forest := Nil | Cons (t : tree) (rest : forest).

Fixpoint map (f : nat -> nat) (t : tree) : tree :=
  match t with Node x c => Node (f x) (map_forest f c) end
with map_forest (f : nat -> nat) (c : forest) : forest :=
  match c with Nil => Nil | Cons t rest => Cons (map f t) (map_forest f rest) end.

Definition doubled (t : tree) : tree := map (fun n => n + n) t.

Definition all (p : nat -> bool) (t : tree) : bool :=
  (fix every (t : tree) : bool :=
     match t with Node x c => andb (p x) (every_forest c) end
   with every_forest (c : forest) : bool :=
     match c with Nil => true | Cons t rest => andb (every t) (every_forest rest) end
   for every) t.

Definition all_zero (t : tree) : bool := all (fun n => Nat.eqb n 0) t.

(* One member of each group below is named like a method of a built-in
   that a rule of the presets reads specially when called through an
   object. *)
Fixpoint reduce (f : nat -> nat -> nat) (acc : nat) (t : tree) : nat :=
  match t with Node x c => reduce_forest f (f acc x) c end
with reduce_forest (f : nat -> nat -> nat) (acc : nat) (c : forest) : nat :=
  match c with Nil => acc | Cons t rest => reduce_forest f (reduce f acc t) rest end.

Fixpoint append (c d : forest) : forest :=
  match c with Nil => d | Cons t rest => Cons t (append rest d) end.
Fixpoint concat (t : tree) : forest :=
  match t with Node x c => Cons (Node x Nil) (concat_forest c) end
with concat_forest (c : forest) : forest :=
  match c with Nil => Nil | Cons t rest => append (concat t) (concat_forest rest) end.

Fixpoint has_own_property (x : nat) (t : tree) : bool :=
  match t with Node y c => orb (Nat.eqb x y) (has_own_property_forest x c) end
with has_own_property_forest (x : nat) (c : forest) : bool :=
  match c with
  | Nil => false
  | Cons t rest => orb (has_own_property x t) (has_own_property_forest x rest)
  end.

Fixpoint substr (n : nat) (t : tree) : tree :=
  match t with Node x c => Node x (substr_forest n c) end
with substr_forest (n : nat) (c : forest) : forest :=
  match n, c with
  | O, _ | _, Nil => Nil
  | S k, Cons t rest => Cons (substr k t) (substr_forest n rest)
  end.

Definition root (t : tree) : nat := match t with Node x _ => x end.
Fixpoint insert (t : tree) (c : forest) : forest :=
  match c with
  | Nil => Cons t Nil
  | Cons u rest => if Nat.leb (root t) (root u) then Cons t c else Cons u (insert t rest)
  end.
Fixpoint sort (t : tree) : tree :=
  match t with Node x c => Node x (sort_forest c) end
with sort_forest (c : forest) : forest :=
  match c with Nil => Nil | Cons t rest => insert (sort t) (sort_forest rest) end.

Fixpoint to_fixed (d : nat) (t : tree) : tree :=
  match t with Node x c => Node (Nat.min x d) (to_fixed_forest d c) end
with to_fixed_forest (d : nat) (c : forest) : forest :=
  match c with Nil => Nil | Cons t rest => Cons (to_fixed d t) (to_fixed_forest d rest) end.

TypeScript Extraction "forests.ts"
  tree forest map map_forest doubled all_zero reduce concat has_own_property substr
  sort to_fixed.
