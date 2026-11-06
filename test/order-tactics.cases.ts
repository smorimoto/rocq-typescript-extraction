import { print } from "./observe.ts";
import { go, MakeTac, Use, used } from "./order-tactics.ts";

const strings = {
  eqb: (x: string, y: string) => x === y,
  le: (x: string, y: string) => x <= y,
  leTotal: (x: string, y: string) => x <= y,
};

console.log("a functor over module types applied to its parameter");

print(go);

print(MakeTac(strings)(strings).lt("a", "a"));

print(MakeTac(strings)(strings).cmp("a", "a"));

console.log("a functor signature whose parameter reads an applied module type");

print(used);

print(Use(MakeTac).go);
