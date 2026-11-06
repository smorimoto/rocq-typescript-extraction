import {
  cons,
  count,
  doubled,
  mconcat,
  natMonoid,
  nil,
  pick,
  picked,
  same,
  squared,
  total,
  withUnit,
} from "./monoid.ts";
import type { Monoid } from "./monoid.ts";
import { print } from "./observe.ts";

const all: Monoid<boolean> = { op: (a) => (b) => a && b, unit: true };

console.log(
  "a record generic over its field of sort Type folds at its own carrier"
);

print([total, squared(natMonoid), count(cons(natMonoid, nil))]);

print(mconcat(all, cons(true, cons(false, nil))));

console.log(
  "a function that returns such a record keeps the carrier its body gives"
);

{
  const kept: Monoid<boolean> = same(all);
  print(squared(doubled(kept)));
  const counted: Monoid<number> = withUnit(2);
  print([squared(counted), squared(doubled(withUnit(1)))]);
  const numbers: Monoid<number> = pick(true);
  const booleans: Monoid<boolean> = pick(false);
  print([squared(numbers), picked]);
  print([squared(booleans), booleans.unit]);
}
