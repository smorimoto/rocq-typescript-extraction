From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".

(* Self recursion that the generated code runs at any depth: in non-tail
   position, through a constructor, under a match in a call argument, in
   a local fixpoint, in a function with both kinds of call, and in one
   whose closure reads a parameter that a self call changes, with the
   operands of a call evaluated in order. *)

Inductive tree := Leaf | Node (l : tree) (k : nat) (r : tree).

Fixpoint size (t : tree) : nat :=
  match t with
  | Leaf => 0
  | Node l _ r => S (size l + size r)
  end.

Fixpoint mirror (t : tree) : tree :=
  match t with
  | Leaf => Leaf
  | Node l k r => Node (mirror r) k (mirror l)
  end.

Fixpoint app {A} (l m : list A) : list A :=
  match l with
  | nil => m
  | cons x l' => cons x (app l' m)
  end.

Inductive color := Red | Green | Blue.

Fixpoint weigh (c : color) (n : nat) : nat :=
  match n with
  | O => 0
  | S m => 1 + (match c with Red => weigh c m | Green => 2 | Blue => weigh Red m end)
  end.

Definition count_from (base : nat) (n : nat) : nat :=
  let fix go (k : nat) : nat := match k with O => base | S j => S (go j) end in
  go n + go 1.

Fixpoint walk (n acc : nat) (b : bool) : nat :=
  match n with
  | O => acc
  | S m => if b then walk m (S acc) (negb b) else S (walk m acc (negb b))
  end.

Fixpoint compose_n (n : nat) (k : nat -> nat) : nat -> nat :=
  match n with
  | O => k
  | S m => compose_n m (fun x => k (x + 1))
  end.

Fixpoint ev (n : nat) : bool := match n with O => true | S m => od m end
with od (n : nat) : bool := match n with O => false | S m => ev m end.

Fixpoint up_even (n : nat) : nat := match n with O => 0 | S m => S (up_odd m) end
with up_odd (n : nat) : nat := match n with O => 1 | S m => S (up_even m) end.

Fixpoint mod3_0 (n : nat) : nat := match n with O => 0 | S m => mod3_1 m end
with mod3_1 (n : nat) : nat := match n with O => 1 | S m => mod3_2 m end
with mod3_2 (n : nat) : nat := match n with O => 2 | S m => mod3_0 m end.

Definition local_parity (n : nat) : bool :=
  let lev :=
    fix lev (k : nat) : bool := match k with O => true | S j => lod j end
    with lod (k : nat) : bool := match k with O => false | S j => lev j end
    for lev
  in
  lev n.

Fixpoint map_nat (f : nat -> nat) (l : list nat) : list nat :=
  match l with
  | nil => nil
  | cons x l' => cons (f x) (map_nat f l')
  end.

Fixpoint fold_tree (f : nat -> nat) (t : tree) : nat :=
  match t with
  | Leaf => 0
  | Node l k r => f k + fold_tree f l + fold_tree f r
  end.

Inductive rose := RNode (k : nat) (f : forest)
with forest := FNil | FCons (r : rose) (f : forest).

Fixpoint rose_size (r : rose) : nat := match r with RNode _ f => S (forest_size f) end
with forest_size (f : forest) : nat :=
  match f with FNil => 0 | FCons r f' => rose_size r + forest_size f' end.

Fixpoint rose_sum (r : rose) (acc : nat) : nat :=
  match r with RNode k f => forest_sum f (acc + k) end
with forest_sum (f : forest) (acc : nat) : nat :=
  match f with FNil => acc | FCons r f' => forest_sum f' (rose_sum r acc) end.

Fixpoint twice_after (n : nat) : nat :=
  match n with
  | O => 0
  | S m => let f := fun x => x + n in f (f (twice_after m))
  end.

Fixpoint merge (l1 l2 : list nat) : list nat :=
  let fix merge_aux (l2 : list nat) : list nat :=
    match l1, l2 with
    | nil, _ => l2
    | _, nil => l1
    | cons x l1', cons y l2' =>
      if Nat.leb x y then cons x (merge l1' l2) else cons y (merge_aux l2')
    end
  in merge_aux l2.

Axiom boom : nat -> nat.
Axiom bottom : nat -> nat.

Fixpoint order (n : nat) : nat :=
  match n with
  | O => bottom 0
  | S m => (if Nat.eqb m 2 then boom m else m) + order m
  end.

Fixpoint saved_values {A} (combine : A -> A -> A) (n : nat) (x y : A) : A :=
  match n with
  | O => y
  | S m => combine x (saved_values combine m y x)
  end.

Fixpoint shuttle {A} (n : nat) (x y : A) : A :=
  match n with
  | O => x
  | S m => match shuttle_list m (y, x) with nil => y | cons a _ => a end
  end
with shuttle_list {A} (n : nat) (xy : A * A) : list A :=
  match n with
  | O => cons (snd xy) nil
  | S m => cons (fst xy) (cons (shuttle m (snd xy) (fst xy)) nil)
  end.

Fixpoint observed_even (visit : nat -> list nat -> list nat) (xs : list nat) : bool :=
  match xs with
  | nil => true
  | cons _ rest => observed_odd visit rest (visit 2 (visit 1 rest))
  end
with observed_odd (visit : nat -> list nat -> list nat) (xs unused : list nat) : bool :=
  match xs with
  | nil => false
  | cons _ rest => observed_even visit rest
  end.

Fixpoint observed_tail (visit : nat -> nat) (n unused : nat) : nat :=
  match n with O => 0 | S m => observed_tail visit m (visit n) end.

Fixpoint drop_closure (n x : nat) (unused : unit -> nat) : nat :=
  match n with O => O | S m => drop_closure m 0 (fun _ => x) end.

Fixpoint drop_let_closure (n x : nat) (unused : unit -> nat) : nat :=
  match n with
  | O => O
  | S m => let y := x + 1 in drop_let_closure m 0 (fun _ => y)
  end.

Fixpoint drop_closure_chain (n x y : nat) (unused : unit -> nat) : nat :=
  match n with O => O | S m => drop_closure_chain m y 0 (fun _ => x) end.

Fixpoint drop_mutual_closure (n x y : nat) (unused : unit -> nat) : nat :=
  match n with O => O | S m => drop_mutual_closure_odd m y 0 (fun _ => x) end
with drop_mutual_closure_odd (n x y : nat) (unused : unit -> nat) : nat :=
  match n with O => O | S m => drop_mutual_closure m y 0 (fun _ => x) end.

Fixpoint drop_effect_closure (visit : nat -> nat) (n x : nat)
  (unused : unit -> nat) : nat :=
  match n with
  | O => O
  | S m =>
      let y := visit n in drop_effect_closure visit m 0 (fun _ => x + y)
  end.

Definition drop_local_closure (n x : nat) : nat :=
  let fix loop (n x : nat) (unused : unit -> nat) : nat :=
    match n with O => O | S m => loop m 0 (fun _ => x) end
  in loop n x (fun _ => x).

TypeScript Extraction "stack.ts"
  size mirror app weigh count_from walk compose_n ev od up_even up_odd mod3_0 mod3_1
  mod3_2 local_parity map_nat fold_tree rose_size forest_size rose_sum forest_sum
  twice_after merge order saved_values shuttle shuttle_list observed_even observed_odd
  observed_tail drop_closure drop_let_closure drop_closure_chain drop_mutual_closure
  drop_mutual_closure_odd drop_effect_closure drop_local_closure.
