From TypeScriptExtraction Require Import Number.

Module Type LAT.
  Parameter t : Type.
  Parameter bot : t.
  Parameter lub : t -> t -> t.
End LAT.

Module Type SOLVER.
  Declare Module L : LAT.
  Parameter run : nat -> L.t.
End SOLVER.
