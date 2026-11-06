From Stdlib Require Import List ZArith.
From compcert.lib Require Import Integers.
From compcert.common Require Import AST Errors Values Memory Globalenvs.
From compcert.cfrontend Require Import Ctypes Cop Csyntax Ctyping.

Import ListNotations.
Local Open Scope Z_scope.

Definition check_program
    (types : list composite_definition) (functions : list (ident * function)) :=
  match Ctypes.make_program types
      (List.map (fun '(id, f) => (id, Gfun (Internal f))) functions) [1%positive] 1%positive with
  | Error e => Error e
  | OK p => Ctyping.typecheck_program p
  end.

Definition integer (n : Z) := Csyntax.Eval (Vint (Int.repr n)) type_int32s.

Definition store_int (m : mem) (b : block) (offset value : Z) :=
  Mem.store Mint32 m b offset (Vint (Int.repr value)).

Definition load_int (m : mem) (b : block) (offset : Z) : option Z :=
  match Mem.load Mint32 m b offset with
  | Some (Vint value) => Some (Int.unsigned value)
  | Some (Vundef | Vlong _ | Vfloat _ | Vsingle _ | Vptr _ _) | None => None
  end.

(** These observations run unchanged through both extraction backends. *)
Fixpoint nested_expression (depth : nat) (invalid : bool) : expr :=
  match depth with
  | O => if invalid then Evalof (Evar 99%positive Tvoid) Tvoid else integer 7
  | S n => Ebinop Oadd (nested_expression n invalid) (integer (Z.of_nat n)) Tvoid
  end.

Fixpoint expression_observations (e : expr) : list nat :=
  match e with
  | Ebinop Oadd lhs (Eval (Vint n) _) (Tint I32 Signed _) =>
      Z.to_nat (Int.unsigned n) :: expression_observations lhs
  | Eval (Vint n) (Tint I32 Signed _) => [Z.to_nat (Int.unsigned n)]
  | _ => [999%nat]
  end.

Definition error_observation (e : errcode) : nat :=
  match e with
  | MSG s => String.length s
  | CTX id | POS id => Pos.to_nat id
  end.

Definition typing_observations (depth : nat) (invalid : bool) : list nat :=
  let f := mkfunction type_int32s cc_default [] []
    (Sreturn (Some (nested_expression depth invalid))) in
  match check_program [] [(1%positive, f)] with
  | Error e => 0%nat :: List.map error_observation e
  | OK p =>
      match p.(Ctypes.prog_defs) with
      | [(_, Gfun (Internal f))] =>
          match f.(fn_body) with
          | Sreturn (Some e) => 1%nat :: expression_observations e
          | _ => [998%nat]
          end
      | _ => [997%nat]
      end
  end.

Definition memory_observations (n : nat) : list nat :=
  let '(empty, b) := Mem.alloc Mem.empty 0 64 in
  let offset := 4 * Z.of_nat (n mod 8) in
  let value := Z.of_nat (n * n + 17) in
  match store_int empty b offset value with
  | None => [996%nat]
  | Some before =>
      match store_int before b offset (value + 1) with
      | None => [995%nat]
      | Some after =>
          match Mem.free after b offset (offset + 4) with
          | None => [994%nat]
          | Some freed =>
              List.map (fun m => match load_int m b offset with
                                | None => 0%nat
                                | Some x => S (Z.to_nat x)
                                end) [empty; before; after; freed; before]
          end
      end
  end.

Definition reference_results : list (list nat) :=
  List.flat_map (fun n =>
    [typing_observations n false; typing_observations n true; memory_observations n])
    [0%nat; 1%nat; 2%nat; 17%nat; 64%nat; 256%nat].
