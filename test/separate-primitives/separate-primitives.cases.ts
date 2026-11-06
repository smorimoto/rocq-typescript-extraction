import { print } from "../observe.ts";
import { first, zeros } from "./separate-primitives.ts";

console.log(
  "the realisers of the primitive arrays through an alias of PrimArray"
);

{
  const a = zeros(3n);
  print(a);
  print(first(a));
  print(first(zeros(0n)));
}
