import * as Monolithic from "./mapped-types.ts";
import type { Point } from "./mapped-types.ts";
import { print } from "./observe.ts";
import type { Polyline } from "./separate-shapes/paths.ts";
import type { Point as SeparatePoint } from "./separate-shapes/points.ts";
import * as Separate from "./separate-shapes/separate-shapes.ts";

const segment: readonly [Point, Point] = [
  { px: 1, py: 2 },
  { px: 4, py: 6 },
];

const separateSegment: readonly [SeparatePoint, SeparatePoint] = segment;

for (const [mode, api, input] of [
  ["monolithic", Monolithic, segment],
  ["separate", Separate, separateSegment],
] as const) {
  console.log(`${mode}: a consumer names a type mentioned only by mapped code`);
  print(api.width(input));
  print({ actual: api.ends(input), expected: input });
  print(api.diagonal);
}

console.log("a separate mapped result retains its named type");

const path: Polyline = Separate.traced(separateSegment);

print({ actual: path, expected: separateSegment });
