import { B, boxed, F, HA, HD, K, v, w } from "./nested.ts";
import type { S } from "./nested.ts";
import { print } from "./observe.ts";

const strings: S<string> = { next0: (x) => `${x}!`, z: "" };

console.log(
  "a functor declared in the body of another is a member of the result"
);

{
  const f = F<string>(strings);
  print(f.G<number>({ y: 4 }).pair);
  print(f.GC.pair);
  print(f.both);
  print(B.G<string>({ y: "a" }).pair);
  print(v);
}

console.log(
  "a functor defined as an application applies the other to its arguments"
);

print(HA<string>({ y: "a" }).other);

print(HA<string>({ y: "a" }).step);

print(HD.step);

print(w);

console.log(
  "a type of a nested functor takes the parameters of the outer type it names"
);

print(K<string>(strings).G<number>({ y: 4 }).both);

print(boxed);
