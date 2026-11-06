import {
  B,
  C,
  D,
  F,
  fromC,
  fromD,
  fromQ,
  fromT,
  fromU,
  K,
  P,
  Through,
  Through2,
  Use,
} from "./applied-through.ts";
import type { HAS2, S } from "./applied-through.ts";
import { print } from "./observe.ts";

console.log(
  "a functor of a body applied through applications of the outer one"
);

print(fromC);

print(fromD);

print(B.G<string>({ z: "s" }).both);

print(C.H<null>({ z: null }).three);

print({ actual: D.three, expected: fromD });

console.log("a partial application reached through an application");

print(fromQ);

print(P<string>({ z: "s" }).three);

console.log("a functor of a functor signature applied through a parameter");

print(fromU);

print(Use<string, number>(F)({ z: "a" })({ z: 2 }).both);

console.log("a functor of a parameter's module type applied through it");

{
  print(fromT);
  print(Through<string, number>(K<string>({ z: "k" }))({ z: 3 }).both);

  const inner = {
    Inner: { G: <T>(Y: S<T>) => ({ w: ["u", Y.z] }) },
  } satisfies HAS2<string>;

  print(Through2<string, number>(inner)({ z: 4 }).w);
}
