import { print } from "../observe.ts";
import { B, four } from "./app.ts";
import { F } from "./fun.ts";
import type { FT } from "./fun.ts";
import { boxed, D, flipped, H, HB, v } from "./separate-functors.ts";
import { A } from "./sig.ts";
import type { S } from "./sig.ts";

console.log("the functor of another file applied to a module of this one");

print(D.twice(false));

print(D.mapped);

print(flipped);

console.log(
  "a functor over the module type and the functor signature of other files"
);

{
  const strings: S<string> = {
    map: (f, x) => f(x),
    next0: (x) => `${x}!`,
    z: "",
  };

  const twice: FT = F;
  print(H<string>(strings)(twice).step);
  print(HB.step);
  print(H<number>(A)(F).step);
}

console.log("the members and the types of an application of another file");

print(four);

print(boxed);

print(B.fill(3));

print(v);
