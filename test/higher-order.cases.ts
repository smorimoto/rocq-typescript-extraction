import { B, C, Double, H, Id, K, v } from "./higher-order.ts";
import type { FT, MAKE, S } from "./higher-order.ts";
import { print } from "./observe.ts";

const strings: S<string> = { next0: (x) => `${x}!`, z: "" };

console.log("a functor signature is an alias of a generic arrow type");

{
  const double: FT = Double;
  const m = double<string>(strings);
  const { map } = m;
  print(m.twice("a"));
  print(map((x) => `${x}?`, m.wrap("b")));
}

console.log("an application inside a body is a member of the result");

{
  const h = H<string>(strings)(Double);
  print(h.four);
  print(h.FX.twice("a"));
  print(h.wrapped);
  print(B.four);
  print(B.FX.twice(1));
  print(v);
}

console.log("a functor signature whose result is a constrained module type");

{
  const make: MAKE = Id;
  print(make<string>(strings).z);
  print(K<string>(strings)(Id).z);
  print(K<string>(strings)(Id).MX.next0("a"));
  print(C.z);
}
