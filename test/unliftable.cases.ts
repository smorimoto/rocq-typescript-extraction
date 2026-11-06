import { print } from "./observe.ts";
import { inlineNeg, natDep, weighNeg } from "./unliftable.ts";

console.log("a dependency on a term that is no binder is the union");

{
  print([weighNeg(false, 3), weighNeg(true, true)]);
  const either: boolean | number = inlineNeg(true);
  print([either, inlineNeg(false), natDep(0), natDep(2)]);
}
