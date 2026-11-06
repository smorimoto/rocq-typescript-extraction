import { print } from "./observe.ts";
import { Box, Point, matchNat, matchRange, range, s } from "./realisers.ts";
import type { Bounds } from "./realisers.ts";

console.log(
  "a mapped type asked for by name brings its realisers into its module"
);

print(Box.full(3));

print(
  Box.matchBox(
    () => "empty",
    (n) => `full ${n}`,
    Box.full(3)
  )
);

console.log("a module asked for brings the realisers of its mapped type");

print(Point.point(1, 2));

print(Point.matchPoint((x, y) => x + y, Point.point(1, 2)));

console.log("a mapped type asked for at the top level exports its realisers");

print(s(41));

print(
  matchNat(
    () => "zero",
    (p) => `succ ${p}`,
    3
  )
);

console.log("the type that the code of an exported realiser names is exported");

{
  const b: Bounds = { hi: 5, lo: 2 };
  print({ actual: range(b), expected: b });
  print(matchRange((r) => r.hi - r.lo, range(b)));
}
