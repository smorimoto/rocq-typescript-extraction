import { print } from "../observe.ts";
import { MakeTac } from "./order-tac.ts";
import { both, go, Twice } from "./separate-applied.ts";

console.log("an applied module type of another file types a parameter");

{
  print(go);
  print(both);
  const numbers = { le: (x: number, y: number) => x <= y };
  const total = { leTotal: (x: number, y: number) => x === y };
  print(MakeTac(numbers)(total).cmp(3, 3));
  print(Twice(numbers)(total).both(1, 2));
}
