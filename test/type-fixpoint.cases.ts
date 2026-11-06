import { print } from "./observe.ts";
import { six, sum, top } from "./type-fixpoint.ts";

console.log("a type computed by Fixpoint is the recursive union of its arms");

{
  print([six, sum(0, 5)]);
  const b: boolean = top(3);
  print(b);
}
