From TypeScriptExtraction Require Import Number.

Module Type EqLe. Parameter t : Type. Parameter le : t -> t -> bool. End EqLe.
Module Type IsTotal (O : EqLe). Parameter le_total : O.t -> O.t -> bool. End IsTotal.
