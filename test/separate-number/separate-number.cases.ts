import { print } from "../observe.ts";
import { matchNat, pair, s } from "./datatypes.ts";
import { add } from "./nat.ts";
import {
  Box,
  describe as describeNat,
  filled,
  pairUp,
  predOr,
  total,
} from "./separate-number.ts";

console.log("a module calls the realisers that another file declares");

print(predOr(7, 0));

print(predOr(7, 5));

print(pairUp(3));

print(total([3, 4]));

print(add(3, 4));

console.log("the realisers of a type are exported with it");

print(s(41));

print(pair("a", 1));

print(
  matchNat(
    () => "zero",
    (p) => `succ ${p}`,
    3
  )
);

print(describeNat(0));

print(describeNat(3));

console.log(
  "the realisers of a module type are properties of the module object"
);

print(Box.open(filled(3), 0));

print(Box.open(-1, 9));

print(
  Box.matchBox(
    () => 0,
    (n) => n + 1,
    Box.full(4)
  )
);

print(Box.matchLabel((n) => n * 2, Box.label(4)));
