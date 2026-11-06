import { Applied, Made, Make, three, Use } from "./functor-dep.ts";
import type { DEP } from "./functor-dep.ts";
import { print } from "./observe.ts";

const flags: DEP = { dep: Made.dep };

console.log("a dependent member of a functor body keeps its signature");

{
  const n: number = Make({ n: 4 }).dep(true);
  const b: boolean = Made.dep(false);
  print([n, three, Made.zero]);
  print(b);
}

console.log("a dependent specification of a module type types the parameter");

print([Applied.amount, Applied.flag]);

print(Use(flags).amount);
