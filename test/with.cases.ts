import { print } from "./observe.ts";
import { B, D, F, G, H, HM, K, KA, n } from "./with.ts";
import type { SN } from "./with.ts";

console.log(
  "a constraint on a parameter fixes its type parameter, so the functor takes none"
);

print(B.twice(1));

print(F({ next0: (x) => x * 2, z: 3 }).zero);

console.log("a constraint can name the abstract type of an earlier parameter");

print(D.step);

print(G<string>({ next0: (x) => `${x}!`, z: "" })({ y: "a" }).step);

console.log(
  "a module type defined with a constraint is an alias of the instantiated interface"
);

{
  const m: SN = { next0: (x) => x + 10, z: 5 };
  print(K(m).q);
  print(KA.q);
}

console.log(
  "a module constraint fixes the nested module's types and the body reads the named module"
);

print(HM.w);

print(H({ k: 5 }).w);

print(n);
