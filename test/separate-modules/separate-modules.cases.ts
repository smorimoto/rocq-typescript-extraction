import { print } from "../observe.ts";
import { ordered, succBoth, total } from "./separate-modules.ts";

console.log("a module member of another file named map is called by a binding");

print(succBoth([1, 2]));

console.log(
  "a module member of another file named sort is called by a binding"
);

print(ordered([2, 1]));

print(ordered([1, 2]));

console.log(
  "a module member of another file named reduce is called by a binding"
);

print(total([1, 2]));
