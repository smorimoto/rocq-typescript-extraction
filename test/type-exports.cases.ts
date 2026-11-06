import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";
import * as exports from "./type-exports.ts";
import type { Figure, Nat } from "./type-exports.ts";

console.log("a requested type exports its constructors and the types it names");

print(Object.keys(exports).toSorted());

console.log("the constructors build values of the type");

{
  const n: Nat = ofNumber(2);
  const figures: Figure[] = [exports.dot, exports.line(n), exports.box(n, n)];
  print(figures.map((figure) => figure.tag));
  print(toNumber(exports.s(exports.o)));
}
