import { print } from "./observe.ts";
import * as Monolithic from "./plain-nest.ts";
import { F } from "./separate-plain/plain-nest.ts";
import * as Separate from "./separate-plain/separate-plain.ts";

for (const [mode, api] of [
  ["monolithic", Monolithic],
  ["separate", { ...Separate, F }],
] as const) {
  console.log(`${mode}: the outer functor does not expose hoisted functions`);
  print(Object.keys(api.B).toSorted());
  print(api.B.Nested({}).twice(3));
  print(api.F({}).Nested({}).twice(4));
}
