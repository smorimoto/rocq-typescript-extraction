import { print } from "../observe.ts";
import {
  fieldsId,
  hold,
  labelled,
  named,
  sample,
  sided,
} from "./monolithic-mentions.ts";
import type { Fields, Outline, Point } from "./monolithic-mentions.ts";

console.log("mapped code in the same file names Point and origin");

{
  const start: Point = { px: 1, py: 2 };
  const line: Outline = [start];
  const fields: Fields = { px: start, py: start };

  print(sample(2));
  print({ actual: hold(line), expected: line });
  print(labelled("Point"));
  print({ actual: named(start), expected: start });
  print({ actual: sided(start), expected: start });
  print({ actual: fieldsId(fields), expected: fields });
}
