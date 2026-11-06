import { D, D3, G, isW, M, n, P, Pick0, PT } from "./left-out.ts";
import type { DW, TAGGED } from "./left-out.ts";
import { print } from "./observe.ts";

console.log(
  "a partial application is a generic arrow over the parameters left"
);

print(P({ y: "a" }).other);

print(P<boolean>({ y: true }).step);

print(D.step);

print(D.other);

print(G<string, number>({ next0: (x) => `${x}!`, z: "" })({ y: 2 }).step);

console.log(
  "an application headed by a partial application aliases the types of the body"
);

{
  const w: DW = D.wrapped;
  print(w);
  print(isW(w));
  print(isW(D.v0(false)));
  print(D3.last);
}

console.log(
  "an application in a module to a module nested in it reads its flat object"
);

print(M.B.twice(M.Inner.z));

print(M.three);

print(n);

console.log(
  "a module and its module type tag a constructor the same whatever the order"
);

{
  const tagged: TAGGED<string> = { z: { tag: "Wrap", x: "w" } };
  print(Pick0<string>(tagged).v);
  print(PT.v);
}
