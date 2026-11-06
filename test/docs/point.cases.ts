import { print } from "../observe.ts";
import type { Point } from "./point.ts";
import { swap } from "./point.ts";

console.log("swap exchanges the coordinates");

{
  const p: Point = { px: 1, py: 2 };

  print(swap(p));
}
