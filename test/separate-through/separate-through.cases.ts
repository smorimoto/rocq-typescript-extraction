import { print } from "../observe.ts";
import { F } from "./outer.ts";
import { fromC, fromQ, fromU, P, Use } from "./separate-through.ts";

console.log(
  "a functor of a body applied through an application of another file"
);

print(fromC);

print(fromQ);

print(P<string>({ z: "s" }).three);

console.log(
  "a functor of a functor signature of another file applied through a parameter"
);

print(fromU);

print(Use<string, number>(F)({ z: "a" })({ z: 2 }).both);
