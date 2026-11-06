import { boxed, built, HA } from "./aliased-applications.ts";
import type { HACʹWrapped, HAMʹB, HAYT } from "./aliased-applications.ts";
import { print } from "./observe.ts";

console.log("the types of an alias in an application are those it stands for");

{
  const b: HAMʹB = HA.M.bx(6);
  const t: HAYT = 3;
  const c: HACʹWrapped = HA.C.wrap(t);
  print(b);
  print(c);
  print(built);
  print(boxed);
}
