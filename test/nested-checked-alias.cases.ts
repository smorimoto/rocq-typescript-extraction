import { go, Solver, through } from "./nested-checked-alias.ts";
import { print } from "./observe.ts";

console.log("a checked functor applied in a body reaches the outer argument");

print(go);

print(through);

print(Solver({ bot: "x" }).DS.L.bot);
