import { Fig, total } from "./aliases.ts";
import type { FigMetricsBox, LayoutMBox } from "./aliases.ts";
import { print } from "./observe.ts";

console.log("the types of the alias are those of the module");

{
  const b: FigMetricsBox = { height: 3, width: 2 };
  const same: LayoutMBox = b;
  print(Fig.Metrics.perimeter(same));
}

console.log("a value defined through the alias");

print(total);
