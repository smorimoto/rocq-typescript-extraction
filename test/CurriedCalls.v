From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Corelib Require Import Lists.ListDef.

(* Each staged function computes from its first argument once, when it gets
   it, so a use with every argument is a call of a call, f(g(x))(y). Each
   shape comes with short names that fit on the line and with long ones
   that push it past the 80 columns of oxfmt. *)
Definition staged (n : nat) : nat -> nat := let t := n * n in fun m => t + m.
Definition staged_product (n p : nat) : nat -> nat := let t := n * p in fun m => t + m.
Definition staged_sum (n : nat) : nat -> nat -> nat := let t := n * n in fun m k => t + m + k.
Definition staged_length {A} (n : nat) : list A -> nat := let t := n * n in fun l => t + length l.
Definition staged_apply (n : nat) : (nat -> nat) -> nat := let t := n * n in fun f => f t.
Definition triple (n : nat) : nat := n * 3.
Definition sum (a b : nat) : nat := a + b.
Definition five (_ : True) : nat := 5.

Definition base : nat := 2.
Definition morning_temperature_reading_in_tenths : nat := 4.

Definition initialiser : nat := staged (triple base) base.
Definition long_initialiser : nat :=
  staged
    (triple (sum morning_temperature_reading_in_tenths morning_temperature_reading_in_tenths))
    (triple morning_temperature_reading_in_tenths).

Definition returned (n m : nat) : nat := staged (triple n) m.
Definition long_returned (first_measurement_of_the_day second_measurement_of_the_day : nat) :
    nat :=
  staged (triple first_measurement_of_the_day) second_measurement_of_the_day.
Definition longest_returned
    (first_measurement_of_the_day_in_tenths_of_a_degree_at_the_weather_station
     second_measurement : nat) : nat :=
  staged (triple first_measurement_of_the_day_in_tenths_of_a_degree_at_the_weather_station)
    second_measurement.
Definition broken_returned
    (first_measurement_of_the_day_in_tenths_of_a_degree_at_the_weather_station_one
     second_measurement : nat) : nat :=
  staged (triple first_measurement_of_the_day_in_tenths_of_a_degree_at_the_weather_station_one)
    second_measurement.

Definition in_block (n m : nat) : nat := let k := n + m in staged (triple k) (staged k m).
Definition long_in_block (first_measurement_of_the_day second_measurement_of_the_day : nat) :
    nat :=
  let total := first_measurement_of_the_day + second_measurement_of_the_day in
  staged (triple total) (staged total second_measurement_of_the_day).

Definition nested (n m : nat) : nat := sum (staged (triple n) m) n.
Definition long_nested (first_measurement_of_the_day second_measurement_of_the_day : nat) :
    nat :=
  sum (staged (triple first_measurement_of_the_day) second_measurement_of_the_day)
    first_measurement_of_the_day.

Definition with_type_arguments (n : nat) : nat := staged_length (triple n) (n :: nil).
Definition long_with_type_arguments (first_measurement_of_the_day_in_tenths : nat) : nat :=
  staged_length (triple first_measurement_of_the_day_in_tenths)
    (first_measurement_of_the_day_in_tenths :: nil).

Definition with_arrow (n : nat) : nat := staged_apply (triple n) (fun z => z + n).
Definition long_with_arrow (first_measurement_of_the_day_in_tenths : nat) : nat :=
  staged_apply (triple first_measurement_of_the_day_in_tenths)
    (fun z => z + first_measurement_of_the_day_in_tenths).

Definition three_links (n m : nat) : nat := staged_sum (triple n) m n.
Definition long_three_links (first_measurement_of_the_day second_measurement_of_the_day : nat) :
    nat :=
  staged_sum (triple first_measurement_of_the_day) second_measurement_of_the_day
    first_measurement_of_the_day.

Definition wide_callee (n m : nat) : nat := staged_product (triple n) m n.
Definition long_wide_callee (first_measurement_of_the_day second_measurement_of_the_day : nat) :
    nat :=
  staged_product (triple first_measurement_of_the_day) second_measurement_of_the_day
    first_measurement_of_the_day.

Definition nullary (m : nat) : nat := staged (five I) m.
Definition long_nullary (second_measurement_of_the_day_in_tenths_of_a_degree : nat) : nat :=
  staged (five I) second_measurement_of_the_day_in_tenths_of_a_degree.

Definition fn := nat -> nat.

Module Type Staging.
  Parameter staged : nat -> fn.
  Parameter triple : nat -> nat.
End Staging.

Module Through (X : Staging).
  Definition member (n m : nat) : nat := X.staged (X.triple n) m.
  Definition long_member (first_measurement_of_the_day second_measurement_of_the_day : nat) :
      nat :=
    X.staged (X.triple first_measurement_of_the_day) second_measurement_of_the_day.
  Definition longest_member
      (first_measurement_of_the_day_in_tenths_of_a_degree_at_the_weather_station
       second_measurement : nat) : nat :=
    X.staged (X.triple first_measurement_of_the_day_in_tenths_of_a_degree_at_the_weather_station)
      second_measurement.
End Through.

TypeScript Extraction "curried-calls.ts"
  staged initialiser long_initialiser returned long_returned longest_returned broken_returned
  in_block long_in_block nested
  long_nested with_type_arguments long_with_type_arguments with_arrow long_with_arrow three_links
  long_three_links wide_callee long_wide_callee nullary long_nullary Through.
