import { go, Solver } from "./applied-to-alias.ts";
import { print } from "./observe.ts";

console.log(
  "a functor applied to the alias of a parameter reads the parameter"
);

print(go);

print(Solver({ bot: true }).run(1));

print(Solver({ bot: true }).DS.get0(2));
