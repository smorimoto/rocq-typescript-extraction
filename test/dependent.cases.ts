import {
  applied,
  dep,
  flip,
  fn,
  heavy,
  one,
  packet,
  small,
  twice,
  weigh,
  weight,
  zero,
} from "./dependent.ts";
import type { Packet } from "./dependent.ts";
import { print } from "./observe.ts";

const flag = (n: number): boolean => n > 0;

console.log("a parameter whose type depends on an earlier one follows it");

print(weigh(true, 3));

print(weigh(false, true));

print(weigh(flag(1), 3));

console.log("a packet is narrowed by the argument its payload depends on");

{
  const p: Packet = small;
  print(p.b ? p.x + 1 : p.x);
  print([weight(small), weight(packet(false, false))]);
}

console.log("a call with a constructor argument has the type of its branch");

{
  const n: number = dep(true);
  const b: boolean = dep(false);
  const either: boolean | number = dep(flag(0));
  print([n, b, either]);
  print([zero, one, flip(true), applied, heavy]);
}

console.log("a pair of dependent calls keeps the dependency of each");

{
  const numbers: readonly [number, number] = twice(true);
  const booleans: readonly [boolean, boolean] = twice(false);
  print(numbers);
  print(booleans);
}

console.log("each branch of a dependent match keeps its own function type");

{
  const id: number = fn(true)(1);
  print(id);
  print(fn(false)(1));
}
