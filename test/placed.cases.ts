import { print } from "./observe.ts";
import * as Monolithic from "./placed.ts";
import { FA } from "./separate-placed/placed.ts";
import * as Separate from "./separate-placed/separate-placed.ts";

for (const [mode, api] of [
  ["monolithic", Monolithic],
  ["separate", { ...Separate, FA }],
] as const) {
  console.log(`${mode}: a nested functor is reached through an application`);
  print(api.w);
  print(api.CN.w);
  print(api.FA({ z: 7 }).Nested({ z: false }).w);
}
