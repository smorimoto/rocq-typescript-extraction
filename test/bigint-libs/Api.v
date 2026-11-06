Module Type INPUT.
  Parameter value : nat.
End INPUT.

Module Pair (X : INPUT).
  Definition values : nat * nat := (X.value, S X.value).
  Definition total : nat := X.value + S X.value.
End Pair.
