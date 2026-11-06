import { composeN, halves } from "./loops.ts";
import { print } from "./observe.ts";

console.log("a self call that is no tail stays a call");

print([0, 1, 2, 5, 6].map(halves));

console.log(
  "a function that reads a parameter a self call changes keeps the recursion"
);

{
  const plus = composeN(3, (x) => x);
  print(plus(0));
  print(composeN(0, (x) => x * 2)(5));
}
