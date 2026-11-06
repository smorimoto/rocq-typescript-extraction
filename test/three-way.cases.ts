import { print } from "./observe.ts";
import {
  blue,
  consume,
  green,
  greenVal,
  produce,
  red,
  redVal,
  total,
} from "./three-way.ts";

console.log("each constructor of a three-way enumeration picks its own type");

{
  const n: number = produce(red);
  const b: boolean = produce(green);
  print([n, b, produce(blue)]);
  print([redVal, greenVal, total]);
}

console.log("a parameter follows the constructor before it");

print(consume(red, 5));

print(consume(green, false));
