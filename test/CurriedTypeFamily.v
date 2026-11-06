From TypeScriptExtraction Require Import Number.
From Stdlib Require Import List.
Import ListNotations.
Set Universe Polymorphism.

Definition arrows : Type -> list Type -> Type :=
  fold_right (fun input rest => input -> rest).

Definition keep_action {result : Type} (inputs : list Type)
  (action : arrows result inputs) := action.

Definition select (flag : bool) : arrows nat (if flag then [nat] else [bool; nat]) :=
  match flag return arrows nat (if flag then [nat] else [bool; nat]) with
  | true => fun n => n
  | false => fun enabled n => if enabled then n else 0
  end.
Definition selected := select false true 7.

Definition run_number (enabled : bool) (n : nat) : nat :=
  keep_action (result := nat) [bool; nat; unit]
    (fun enabled n _ => if enabled then n + 2 else 0) enabled n tt.

Definition run_flag (n : nat) (enabled : bool) : bool :=
  keep_action (result := bool) [nat; bool]
    (fun n enabled => andb enabled (Nat.eqb n 4)) n enabled.

Definition no_inputs : bool := keep_action (result := bool) [] true.

Definition use_consumer (inputs : list Type)
  (consume : forall A, arrows A inputs -> A) (action : arrows nat inputs) : nat :=
  consume nat action.

Definition higher_rank_result (n : nat) : nat :=
  use_consumer [] (fun A (value : arrows A []) => value) n.

Definition function_action (empty : bool) :
  arrows (nat -> bool) (if empty then [] else [bool]) :=
  match empty return arrows (nat -> bool) (if empty then [] else [bool]) with
  | true => fun n => Nat.eqb n 6
  | false => fun enabled n => andb enabled (Nat.eqb n 6)
  end.

Definition function_result (empty enabled : bool) (n : nat) : bool :=
  if empty then function_action true n else function_action false enabled n.

(* The seed constrains the domain of the final function before the action
   chooses which of its arrows belongs to that function. *)
Definition keep_function {argument result : Type} (inputs : list Type)
  (action : arrows (argument -> result) inputs) (seed : argument) := action.

Definition function_seed (n : nat) : bool :=
  keep_function [bool]
    (fun flag count => if flag then Nat.eqb count n else false) 0 true 3.

(* A shared result parameter must retain both producers when their erased
   input lists leave the final result unconstrained. *)
Definition keep_two {result : Type} (first second : list Type)
  (action : arrows result first) (other : arrows result second) := action.

Definition two_actions (n : nat) : nat :=
  keep_two [nat] [bool; nat]
    (fun count => count + n) (fun flag count => if flag then count else n) 3.

(* The unknown type is still negative when it is the result of a callback
   passed to the action. *)
Definition callbacks (result : Type) (inputs : list Type) : Type :=
  fold_right (fun input rest => (nat -> input) -> rest) result inputs.

Definition keep_callbacks {result : Type} (inputs : list Type)
  (action : callbacks result inputs) := action.

Definition callback_result (enabled : bool) (n : nat) : nat :=
  keep_callbacks (result := nat) [bool; nat]
    (fun flag count => if flag 0 then count 2 else 0)
    (fun _ => enabled) (fun offset => n + offset).

(* Both captured type parameters must survive a recursive call. *)
Definition paired_arrows (left right : Type) (inputs : list Type) : Type :=
  fold_right (fun input rest => input -> rest) (left * right)%type inputs.

Definition keep_pair {left right : Type} (inputs : list Type)
  (action : paired_arrows left right inputs) := action.

Definition paired_result (enabled : bool) (n : nat) : nat * bool :=
  keep_pair (left := nat) (right := bool) [bool; nat]
    (fun enabled n => (n + 1, enabled)) enabled n.

Unset Universe Polymorphism.

Module Type Grammar.
  Parameter symbol : Type.
  Parameter semantic : symbol -> Type.
  Parameter production : Type.
  Parameter result : production -> symbol.
  Parameter inputs : production -> list symbol.
  Parameter action : forall p, arrows (semantic (result p)) (map semantic (inputs p)).
End Grammar.
Module Use (G : Grammar).
  Definition get := G.action.
End Use.

Module Sample <: Grammar.
  Inductive symbol_kind := Count | Flag | Empty.
  Definition symbol := symbol_kind.
  Definition semantic (s : symbol) : Type :=
    match s with Count => nat | Flag => bool | Empty => unit end.

  Inductive rule := Count_rule | Flag_rule | Empty_rule.
  Definition production := rule.
  Definition result (p : production) : symbol :=
    match p with
    | Count_rule => Count
    | Flag_rule => Flag
    | Empty_rule => Empty
    end.
  Definition inputs (p : production) : list symbol :=
    match p with
    | Count_rule => [Flag; Count; Empty]
    | Flag_rule => [Count; Flag]
    | Empty_rule => []
    end.
  Definition action (p : production) :
    arrows (semantic (result p)) (map semantic (inputs p)) :=
    match p return arrows (semantic (result p)) (map semantic (inputs p)) with
    | Count_rule => fun enabled n _ => if enabled then n + 3 else 0
    | Flag_rule => fun n enabled => andb enabled (Nat.eqb n 4)
    | Empty_rule => tt
    end.
End Sample.

Module Applied := Use Sample.

Definition grammar_number (enabled : bool) (n : nat) : nat :=
  Applied.get Sample.Count_rule enabled n tt.
Definition grammar_flag (n : nat) (enabled : bool) : bool :=
  Applied.get Sample.Flag_rule n enabled.
Definition grammar_empty : unit := Applied.get Sample.Empty_rule.

TypeScript Extraction "curried-type-family.ts"
  keep_action select selected run_number run_flag no_inputs
  use_consumer higher_rank_result
  function_action function_result keep_function function_seed keep_two two_actions
  keep_callbacks callback_result keep_pair paired_result
  Use Applied grammar_number grammar_flag grammar_empty.
