import { Boxes, Counter, F, Holder, Sorted } from "./functors.ts";
import type { LISTS, S } from "./functors.ts";
import { print } from "./observe.ts";
import { ofArray, toArray } from "./support.ts";

const numbers: S<number, boolean> = {
  Deep: { d: 7 },
  f: (x) => x === 0,
  g: (b) => (b ? 1 : 0),
  pick: (b, w) => (b && w.tag === "W" ? w.x : 0),
  w0: (x) => ({ tag: "W", x }),
  z: 0,
};

console.log("a functor is a generic arrow from the interface of its parameter");

{
  const m = F<number, boolean>(numbers);
  print(m.twice(0));
  print(m.w);
  print(m.both);
  print(m.deep);
}

console.log(
  "the types of a body are declared at the top level and its values are the result"
);

{
  const b = Boxes<number, boolean>(numbers);
  print(b.get0(b.some));
  print(b.get0(b.empty));
  print(b.get0(b.full(4)));
  print(b.boxRect((x) => x + 1, 9, b.full(1)));
  print(b.even(4));
  print(b.odd(4));
}

console.log(
  "a parameter member named like an array method is bound at the top of the body"
);

{
  const lists: LISTS<number> = {
    map: (f, xs) => ofArray(toArray(xs).map(f)),
    sort: (xs, x) => ofArray([...toArray(xs), x].toSorted((a, b) => a - b)),
    xs: ofArray([3, 1, 2]),
    z: 0,
  };

  print(Sorted<number>(lists).ys);
}

console.log(
  "a memberless module type is an empty record and an unread parameter is unused"
);

print(Counter({})({ count: 41 }).next0);

console.log("a functor in a module is a member of its object");

print(Holder.Id<number, boolean>(numbers).same);
