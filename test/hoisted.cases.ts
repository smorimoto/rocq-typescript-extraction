import { F, G, H, N, Only } from "./hoisted.ts";
import { print } from "./observe.ts";

const counted = { count: (xs: readonly number[]) => xs.length, z: [1, 2, 3] };

console.log(
  "a member of the body calls a hoisted function by its top-level name"
);

{
  const f = F<readonly number[]>(counted);
  print(f.total);
  print(f.bump(1));
}

console.log(
  "a sealed body calls a hoisted function the module type leaves out"
);

print(H<readonly number[]>(counted).total);

console.log("a member of the body calls a member of a hoisted group");

{
  const g = G<readonly number[]>(counted);
  print(g.balanced);
  print(g.even(4));
  print(g.odd(4));
}

console.log("a module nested in the body holds its hoisted functions");

{
  const n = N<readonly number[]>(counted);
  print(n.total);
  print(n.Inner.twice(5));
  print(n.Inner.Deep.thrice(5));
}

console.log("a body whose members are all hoisted returns them");

print(Only<readonly number[]>(counted).double0(4));
