import * as $Datatypes from "./datatypes.ts";
import * as $ListDef from "./list-def.ts";

const { fst, o, pair, s, snd } = $Datatypes;
const { map: map0 } = $ListDef;

export const double0 = (n: $Datatypes.Nat): $Datatypes.Nat => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: $Datatypes.Nat;

    switch (n0.tag) {
      case "O": {
        returned = o;
        break;
      }

      case "S": {
        depth += 1;
        n0 = n0.arg0;
        continue;
      }

      default: {
        returned = n0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = s(s(returned));
    }
  }
};

export const both = (
  b: $Datatypes.Bool,
  n: $Datatypes.Nat
): $Datatypes.Prod<$Datatypes.Bool, $Datatypes.Nat> => pair(b, double0(n));

export const doubles = (
  l: $Datatypes.List<$Datatypes.Nat>
): $Datatypes.List<$Datatypes.Nat> => map0(double0, l);

export const map = <A, B>(
  f: (_: A) => B,
  p: $Datatypes.Prod<A, A>
): $Datatypes.Prod<B, B> => pair(f(fst(p)), f(snd(p)));

export const twice = (
  map1: (_: $Datatypes.Nat) => $Datatypes.Nat,
  l: $Datatypes.List<$Datatypes.Nat>
): $Datatypes.List<$Datatypes.Nat> => map0(map1, map0(map1, l));

export interface GeometryDot {
  readonly tag: "Dot";
}

export interface GeometryLine {
  readonly tag: "Line";
  readonly n: $Datatypes.Nat;
}

export type GeometryFigure = GeometryDot | GeometryLine;

const Geometry$dot: GeometryDot = { tag: "Dot" };

const Geometry$line = (n: $Datatypes.Nat): GeometryFigure => ({
  n,
  tag: "Line",
});

const Geometry$figureRect = <A>(
  dot: A,
  line: (_: $Datatypes.Nat) => A,
  f: GeometryFigure
): A => {
  switch (f.tag) {
    case "Dot": {
      return dot;
    }

    case "Line": {
      return line(f.n);
    }

    default: {
      return f satisfies never;
    }
  }
};

const Geometry$figureRec = <A>(
  dot: A,
  line: (_: $Datatypes.Nat) => A,
  f: GeometryFigure
): A => {
  switch (f.tag) {
    case "Dot": {
      return dot;
    }

    case "Line": {
      return line(f.n);
    }

    default: {
      return f satisfies never;
    }
  }
};

const Geometry$len = (s0: GeometryFigure): $Datatypes.Nat => {
  switch (s0.tag) {
    case "Dot": {
      return o;
    }

    case "Line": {
      return s0.n;
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const Geometry = {
  dot: Geometry$dot,
  figureRec: Geometry$figureRec,
  figureRect: Geometry$figureRect,
  len: Geometry$len,
  line: Geometry$line,
} as const;
