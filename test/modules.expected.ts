export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });

const add = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: Nat;

    switch (n0.tag) {
      case "O": {
        returned = m;
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
      returned = s(returned);
    }
  }
};

const mul = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: Nat;

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
      returned = add(m, returned);
    }
  }
};

export interface GeometryCircle {
  readonly tag: "Circle";
  readonly r: Nat;
}

export interface GeometrySquare {
  readonly tag: "Square";
  readonly s: Nat;
}

export type GeometryFigure = GeometryCircle | GeometrySquare;

const Geometry$circle = (r: Nat): GeometryFigure => ({ r, tag: "Circle" });
const Geometry$square = (s0: Nat): GeometryFigure => ({ s: s0, tag: "Square" });

const Geometry$figureRect = <A>(
  circle: (_: Nat) => A,
  square: (_: Nat) => A,
  f: GeometryFigure
): A => {
  switch (f.tag) {
    case "Circle": {
      return circle(f.r);
    }

    case "Square": {
      return square(f.s);
    }

    default: {
      return f satisfies never;
    }
  }
};

const Geometry$figureRec = <A>(
  circle: (_: Nat) => A,
  square: (_: Nat) => A,
  f: GeometryFigure
): A => {
  switch (f.tag) {
    case "Circle": {
      return circle(f.r);
    }

    case "Square": {
      return square(f.s);
    }

    default: {
      return f satisfies never;
    }
  }
};

const Geometry$scale = (k: Nat, s0: GeometryFigure): GeometryFigure => {
  switch (s0.tag) {
    case "Circle": {
      return Geometry$circle(mul(k, s0.r));
    }

    case "Square": {
      return Geometry$square(mul(k, s0.s));
    }

    default: {
      return s0 satisfies never;
    }
  }
};

const Geometry$Units$unitCircle: GeometryFigure = Geometry$circle(s(o));

export interface GeometryUnitsBox {
  readonly width: Nat;
  readonly height: Nat;
}

const Geometry$Units$width = (b: GeometryUnitsBox): Nat => b.width;
const Geometry$Units$height = (b: GeometryUnitsBox): Nat => b.height;

const Geometry$Units$unitBox: GeometryUnitsBox = {
  height: s(s(o)),
  width: s(o),
};

export const Geometry = {
  Units: {
    height: Geometry$Units$height,
    unitBox: Geometry$Units$unitBox,
    unitCircle: Geometry$Units$unitCircle,
    width: Geometry$Units$width,
  },
  circle: Geometry$circle,
  figureRec: Geometry$figureRec,
  figureRect: Geometry$figureRect,
  scale: Geometry$scale,
  square: Geometry$square,
} as const;

const Areas$side = (s0: GeometryFigure): Nat => {
  switch (s0.tag) {
    case "Circle": {
      return s0.r;
    }

    case "Square": {
      return s0.s;
    }

    default: {
      return s0 satisfies never;
    }
  }
};

const Areas$doubled: GeometryFigure = Geometry$scale(
  s(s(o)),
  Geometry$Units$unitCircle
);

const Areas$boxArea = (b: GeometryUnitsBox): Nat => mul(b.width, b.height);

export const Areas = {
  boxArea: Areas$boxArea,
  doubled: Areas$doubled,
  side: Areas$side,
} as const;

const Ten$size: Nat = s(s(s(s(s(s(s(s(s(s(o))))))))));

export const Ten = {
  size: Ten$size,
} as const;

export const total: Nat = add(
  add(Areas$side(Areas$doubled), Areas$boxArea(Geometry$Units$unitBox)),
  Ten$size
);
