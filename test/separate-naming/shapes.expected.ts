import * as $Datatypes from "./datatypes.ts";

const { s } = $Datatypes;

export interface Triangle {
  readonly tag: "Triangle";
}

export interface Square {
  readonly tag: "Square";
}

export type Polygon = Triangle | Square;

export const triangle: Triangle = { tag: "Triangle" };
export const square: Square = { tag: "Square" };

export const sides = (p: Polygon): number => {
  switch (p.tag) {
    case "Triangle": {
      return s(s(s(0)));
    }

    case "Square": {
      return s(s(s(s(0))));
    }

    default: {
      return p satisfies never;
    }
  }
};
