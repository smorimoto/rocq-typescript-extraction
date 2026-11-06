import { expect, test } from "bun:test";

import { D, Fig, Figure, G, Layout, via } from "./aliases.ts";
import type { FigT, GEMetricsBox, GET } from "./aliases.ts";

test("an alias is the object of the module it stands for", () => {
  expect(Fig).toBe(Figure);

  const c: FigT = Fig.circle(2);
  expect(c.tag).toBe("Circle");
  expect(Fig.area(c)).toBe(12);
  expect(Fig.area(Fig.unit)).toBe(1);
});

test("a nested alias is a property of the object around it", () => {
  expect(Layout.M).toBe(Figure.Metrics);
  expect(Layout.M.perimeter(Layout.frame)).toBe(10);
});

test("an alias of a module that holds an alias reaches the module at the end", () => {
  expect(G).toBe(D);
  expect(G.E).toBe(Figure);
  expect(G.E.Metrics).toBe(Figure.Metrics);

  const sq: GET = G.E.square(3);
  const b: GEMetricsBox = { height: 1, width: 4 };
  expect(G.E.area(sq)).toBe(9);
  expect(G.E.Metrics.perimeter(b)).toBe(10);
  expect(via).toBe(11);
});
