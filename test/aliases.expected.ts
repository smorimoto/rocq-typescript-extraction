const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const mul: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n * m;

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

const Figure$unit: FigureT = Figure$square(s(0));

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

export interface FigureMetricsBox {
  readonly width: number;
  readonly height: number;
}

const Figure$Metrics$width = (b: FigureMetricsBox): number => b.width;
const Figure$Metrics$height = (b: FigureMetricsBox): number => b.height;

const Figure$Metrics$perimeter = (b: FigureMetricsBox): number =>
  mul(s(s(0)), add(b.width, b.height));

export const Figure = {
  Metrics: {
    height: Figure$Metrics$height,
    perimeter: Figure$Metrics$perimeter,
    width: Figure$Metrics$width,
  },
  area: Figure$area,
  circle: Figure$circle,
  square: Figure$square,
  tRec: Figure$tRec,
  tRect: Figure$tRect,
  unit: Figure$unit,
} as const;

export type FigT = FigureT;

export type FigMetricsBox = FigureMetricsBox;

export const Fig = Figure;

export type LayoutMBox = FigureMetricsBox;

const Layout$frame: FigureMetricsBox = { height: s(s(s(0))), width: s(s(0)) };

export const Layout = {
  M: Figure.Metrics,
  frame: Layout$frame,
} as const;

const doubled: FigureT = Figure$circle(mul(s(s(0)), Figure$area(Figure$unit)));

export const total: number = add(
  Figure$area(doubled),
  Figure$Metrics$perimeter(Layout$frame)
);

export const D = {
  E: Figure,
} as const;

export type GET = FigureT;

export type GEMetricsBox = FigureMetricsBox;

export const G = D;

export const via: number = add(
  Figure$area(Figure$unit),
  Figure$Metrics$perimeter(Layout$frame)
);
