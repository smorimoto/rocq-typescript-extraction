import * as $Datatypes from "./datatypes.ts";
import * as $Nat from "./nat.ts";

const { s } = $Datatypes;
const { mul } = $Nat;

export interface FigureCircle {
  readonly tag: "Circle";
  readonly r: number;
}

export interface FigureSquare {
  readonly tag: "Square";
  readonly side: number;
}

export type FigureT = FigureCircle | FigureSquare;

const Figure$circle = (r: number): FigureT => ({ r, tag: "Circle" });
const Figure$square = (side: number): FigureT => ({ side, tag: "Square" });

const Figure$tRect = <A>(
  circle: (_: number) => A,
  square: (_: number) => A,
  t: FigureT
): A => {
  switch (t.tag) {
    case "Circle": {
      return circle(t.r);
    }

    case "Square": {
      return square(t.side);
    }

    default: {
      return t satisfies never;
    }
  }
};

const Figure$tRec = <A>(
  circle: (_: number) => A,
  square: (_: number) => A,
  t: FigureT
): A => {
  switch (t.tag) {
    case "Circle": {
      return circle(t.r);
    }

    case "Square": {
      return square(t.side);
    }

    default: {
      return t satisfies never;
    }
  }
};

const Figure$area = (s0: FigureT): number => {
  switch (s0.tag) {
    case "Circle": {
      return mul(mul(s(s(s(0))), s0.r), s0.r);
    }

    case "Square": {
      return mul(s0.side, s0.side);
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const Figure = {
  area: Figure$area,
  circle: Figure$circle,
  square: Figure$square,
  tRec: Figure$tRec,
  tRect: Figure$tRect,
} as const;
