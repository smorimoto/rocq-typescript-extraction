import { print } from "../observe.ts";
import { origin } from "./points.ts";
import type { Point } from "./points.ts";
import { ofOrigin, seen, text, unioned, via } from "./separate-mentions.ts";

console.log("mapped code in another file names Point and origin");

{
  const start: Point = { px: 1, py: 2 };

  print({ actual: via(2), expected: [2, origin] });
  print({ actual: ofOrigin(origin), expected: origin });
  print(text("Point"));
  print({ actual: seen([start]), expected: [start] });
  print({ actual: unioned(start), expected: start });
}
