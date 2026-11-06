import { B, C, G, I, IA, sum, ten } from "./body-directives.ts";
import { print } from "./observe.ts";

console.log(
  "an Extract Constant in a functor body replaces the body's definition"
);

print(B.double0(21));

print(B.four);

print(ten);

console.log(
  "a directive typed by a parameter's abstract type, and one in a nested module"
);

{
  const g = G<string>({ z: "a" });
  print(g.chosen);
  print(g.pick("x", "y"));
  print(g.four);
  print(g.Inner.half(7));
}

console.log(
  "the directives of a functor applied by another and of an included one"
);

print(C.double0(5));

print(I<string>({ z: "a" }).triple(2));

print(IA.nine);

print(sum);
