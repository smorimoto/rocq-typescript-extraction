From Corelib Require Export extraction.Extraction.
Declare ML Module "rocq-typescript-extraction.plugin".
Declare ML Module "rocq-typescript-extraction.backend".
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import Lists.ListDef.

(* Long names push each construct past the 100 columns of Oxfmt. *)
Inductive shift := Early_morning_shift | Late_afternoon_shift | Evening_shift | Overnight_shift.

Definition combine_measurements (first_reading second_reading third_reading fourth_reading : nat) :
    nat :=
  first_reading + second_reading + third_reading + fourth_reading.

Definition combined_readings : nat :=
  combine_measurements (combine_measurements 1 2 3 4) (combine_measurements 4 3 2 1) 1 1.

Definition apply_twice {A} (f : A -> A) (x : A) : A := f (f x).

Definition pairwise_combinations : list (nat -> nat) :=
  map (fun first_reading second_reading => combine_measurements first_reading second_reading 1 1)
    (1 :: 2 :: nil).

Definition twice_combined : nat -> nat := apply_twice (combine_measurements 1 1 1).

Definition shift_weight (s : shift) (bonus : nat) : nat :=
  combine_measurements
    (match s with
     | Early_morning_shift => 1
     | Late_afternoon_shift => 2
     | Evening_shift => 3
     | Overnight_shift => 4
     end)
    bonus 0 0.

Definition empty_schedule :
    prod (list (option nat)) (prod (list (option shift)) (list (option nat))) :=
  (nil, (nil, nil)).

(* Exactly 100 columns wide but 102 bytes long: widths count characters. *)
Definition durée_totale_des_relevé : nat := combine_measurements 3 3 2 1.

TypeScript Extraction "layout.ts"
  combine_measurements combined_readings apply_twice pairwise_combinations twice_combined
  shift_weight empty_schedule durée_totale_des_relevé.
