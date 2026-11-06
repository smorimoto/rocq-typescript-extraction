import {
  afterNat,
  callAfter,
  callPoly,
  callTwo,
  collide,
  polyDep,
  snake,
  twoFlags,
} from "./lifting.ts";
import { print } from "./observe.ts";

console.log("a lifted binder keeps its dependency wherever it stands");

{
  const n: number = collide(true);
  const m: number = snake(true);
  const b: boolean = collide(false);
  print([n, m, b]);
  const text: string = polyDep("x", true);
  print([afterNat(2, true), callAfter, callPoly]);
  print([text, polyDep("x", false)]);
}

console.log("two binders, one tested in the other's branch");

{
  const b: boolean = twoFlags(false, true);
  print([twoFlags(true, false), b]);
  print({ actual: callTwo, expected: twoFlags(false, false) });
}
