From Stdlib Require Import MSets.MSetRBT Structures.OrdersEx.

Module Tree_set.
  Include MSetRBT.Make N_as_OT.
End Tree_set.

Definition empty := Tree_set.empty.
Definition insert := Tree_set.add.
Definition member := Tree_set.mem.
