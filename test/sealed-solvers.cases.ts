import { print } from "./observe.ts";
import * as Monolithic from "./sealed-solvers.ts";
import * as Separate from "./separate-sealed/separate-sealed.ts";
import { Outer } from "./separate-sealed/solvers.ts";

for (const [mode, api] of [
  ["monolithic", Monolithic],
  ["separate", { ...Separate, Outer }],
] as const) {
  console.log(
    `${mode}: sealed solvers applied to aliases compute what Rocq computes`
  );
  print(api.go);
  print(api.twice);
  print(api.through);

  console.log(
    `${mode}: a consumer applies the sealed solvers to a lattice of its own`
  );
  const strings = { bot: "b", lub: (a: string, b: string) => a + b };
  print(api.Outer(strings).run(0));
  print(api.Outer(strings).run(1));
  print(api.Outer(strings).L.bot);
  print(api.Nested(strings).twice(0));
  print(api.Nested(strings).twice(1));
}
