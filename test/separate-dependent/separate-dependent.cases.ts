import { print } from "../observe.ts";
import { Make } from "./dependent.ts";
import { Applied, Made, no, three } from "./separate-dependent.ts";

console.log("an application of a functor of another file keeps the dependency");

{
  const n: number = Made.dep(true);
  const b: boolean = Made.dep(false);
  print([n, b, three, no, Applied.amount]);
  print(Make({ n: 5 }).dep(true));
}
