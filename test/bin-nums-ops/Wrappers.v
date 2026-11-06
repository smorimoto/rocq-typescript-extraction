(** One wrapper per operation of [Corelib.BinNums] that the binary number
    theories realise, so that the extractions in ../bin-nums export the
    same names under every preset. *)

From Corelib Require Import BinNums PosDef NatDef IntDef.

Module Ops.

Definition pos_succ := Pos.succ.
Definition pos_add := Pos.add.
Definition pos_add_carry := Pos.add_carry.
Definition pos_pred_double := Pos.pred_double.
Definition pos_pred_n := Pos.pred_N.
Definition pos_sub := Pos.sub.
Definition pos_mul := Pos.mul.
Definition pos_div2 := Pos.div2.
Definition pos_div2_up := Pos.div2_up.
Definition pos_compare_cont := Pos.compare_cont.
Definition pos_compare := Pos.compare.
Definition pos_eqb := Pos.eqb.
Definition pos_leb := Pos.leb.
Definition pos_sqrt := Pos.sqrt.
Definition pos_nsucc_double := Pos.Nsucc_double.
Definition pos_ndouble := Pos.Ndouble.
Definition pos_lor := Pos.lor.
Definition pos_land := Pos.land.
Definition pos_ldiff := Pos.ldiff.
Definition pos_lxor := Pos.lxor.
Definition pos_to_nat := Pos.to_nat.
Definition pos_of_succ_nat := Pos.of_succ_nat.

Definition n_succ_double := N.succ_double.
Definition n_double := N.double.
Definition n_succ_pos := N.succ_pos.
Definition n_sub := N.sub.
Definition n_compare := N.compare.
Definition n_leb := N.leb.
Definition n_pos_div_eucl := N.pos_div_eucl.
Definition n_lor := N.lor.
Definition n_land := N.land.
Definition n_ldiff := N.ldiff.
Definition n_lxor := N.lxor.

Definition z_double := Z.double.
Definition z_succ_double := Z.succ_double.
Definition z_pred_double := Z.pred_double.
Definition z_pos_sub := Z.pos_sub.
Definition z_add := Z.add.
Definition z_opp := Z.opp.
Definition z_sub := Z.sub.
Definition z_mul := Z.mul.
Definition z_pow_pos := Z.pow_pos.
Definition z_pow := Z.pow.
Definition z_compare := Z.compare.
Definition z_leb := Z.leb.
Definition z_ltb := Z.ltb.
Definition z_eqb := Z.eqb.
Definition z_max := Z.max.
Definition z_min := Z.min.
Definition z_to_nat := Z.to_nat.
Definition z_of_nat := Z.of_nat.
Definition z_of_n := Z.of_N.
Definition z_to_pos := Z.to_pos.
Definition z_pos_div_eucl := Z.pos_div_eucl.
Definition z_div_eucl := Z.div_eucl.
Definition z_div := Z.div.
Definition z_modulo := Z.modulo.
Definition z_quotrem := Z.quotrem.
Definition z_quot := Z.quot.
Definition z_rem := Z.rem.
Definition z_even := Z.even.
Definition z_div2 := Z.div2.
Definition z_sqrtrem := Z.sqrtrem.
Definition z_shiftl := Z.shiftl.
Definition z_shiftr := Z.shiftr.
Definition z_lor := Z.lor.
Definition z_land := Z.land.
Definition z_lxor := Z.lxor.

End Ops.
