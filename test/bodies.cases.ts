import { B, F, FA, Flags, on, v } from "./bodies.ts";
import type { FInner, S } from "./bodies.ts";
import { print } from "./observe.ts";

const strings: S<string> = { next0: (x) => `${x}!`, z: "" };

console.log(
  "a module nested in a body is the object of its members, typed by its interface"
);

{
  const inner: FInner<string> = F<string>(strings).Inner;
  print(inner.first);
  print(F<string>(strings).unwrap(inner.fill("a")));
  print(F<string>(strings).twice);
  print(B.Inner.fill(2));
  print(v);
}

console.log(
  "a type of a body mapped by Extract Inductive keeps its realisers at the top level"
);

{
  const flags = Flags<string>({ z: "z" });
  print(flags.toggle(true));
  print(flags.pick(false));
  print(FA.toggle(FA.toggle(true)));
  print(on);
}
