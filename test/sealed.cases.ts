import { print } from "./observe.ts";
import { B, BA, Boxes, C, F, G, u, v, w } from "./sealed.ts";
import type { BABox, BOX, BT, CT, S } from "./sealed.ts";

console.log(
  "a sealed functor returns the interface of its module type with the members it lists"
);

{
  const strings: S<string> = { f: (x) => `${x}!`, z: "" };
  const m: S<string> = F<string>(strings);
  print(m.z);
  print(m.f("a"));
  print("helper" in m);
}

console.log(
  "a sealed application has the members of its module type, typed by the functor's result"
);

{
  const z: BT = B.z;
  print(z);
  print(w);
}

console.log(
  "an application of an unsealed functor, sealed by a module type, has the module type's members"
);

{
  const z: CT = C.z;
  print(z);
  print(u);
  print(G<number>({ f: (x) => x * 2, z: 4 }).extra);
}

console.log(
  "a body that defines the abstract type as an inductive instantiates the result with it"
);

{
  const boxes: BOX<number, BABox> = Boxes<number>({ f: (x) => x, z: 9 });
  print(BA.unwrap(boxes.wrap(1)));
  print(boxes.unwrap(boxes.wrap(3)));
  print(boxes.unwrap({ tag: "Empty" }));
  print(v);
}
