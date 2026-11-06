import { F, G } from "./body-statements.ts";
import { print } from "./observe.ts";

console.log("a member of a functor body computes from its parameter");

print(G);

print(F({ b: false, n: 0 }));

print(F({ b: true, n: 0 }));
