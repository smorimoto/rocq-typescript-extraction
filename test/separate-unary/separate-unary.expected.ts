import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { false0 } = $Datatypes;
const { leb } = $Nat;

export const below = (x: $Datatypes.Nat, x0: $Datatypes.Nat): $Datatypes.Bool =>
  leb(x, x0);

export const strictlyBelow = (
  left: $Datatypes.Nat,
  right: $Datatypes.Nat
): $Datatypes.Bool => {
  switch (right.tag) {
    case "O": {
      return false0;
    }

    case "S": {
      return leb(left, right.arg0);
    }

    default: {
      return right satisfies never;
    }
  }
};
