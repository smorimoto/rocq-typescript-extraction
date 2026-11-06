const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export type AT = (_: number) => number;

export type AU = boolean;

export interface AW0 {
  readonly tag: "W";
  readonly x: AT;
}

export interface ANothing {
  readonly tag: "Nothing";
}

export type AW = AW0 | ANothing;

const A$w = (x: AT): AW => ({ tag: "W", x });
const A$nothing: ANothing = { tag: "Nothing" };

const A$wRect = <A>(
  w: (_: (_: number) => number) => A,
  nothing: A,
  w0: AW
): A => {
  switch (w0.tag) {
    case "W": {
      return w(w0.x);
    }

    case "Nothing": {
      return nothing;
    }

    default: {
      return w0 satisfies never;
    }
  }
};

const A$wRec = <A>(
  w: (_: (_: number) => number) => A,
  nothing: A,
  w0: AW
): A => {
  switch (w0.tag) {
    case "W": {
      return w(w0.x);
    }

    case "Nothing": {
      return nothing;
    }

    default: {
      return w0 satisfies never;
    }
  }
};

const A$z: AW = A$w((n: number): number => n);

const A$f =
  (g: (_: number) => number): ((_: number) => number) =>
  (x: number): number =>
    g(g(x));

const A$pick = (
  b: boolean,
  x: (_: number) => number
): ((_: number) => number) =>
  (b ? A$f : (g: (_: number) => number): ((_: number) => number) => g)(x);

const A$Deep$d: (_: number) => number = (n: number): number => add(n, s(0));

export const A = {
  Deep: {
    d: A$Deep$d,
  },
  f: A$f,
  nothing: A$nothing,
  pick: A$pick,
  w: A$w,
  wRec: A$wRec,
  wRect: A$wRect,
  z: A$z,
} as const;

export const top = (g: (_: number) => number, x: number): number => g(g(x));

export const chosen: (_: number) => number =
  A$z.tag === "W" ? A$pick(true, A$f(A$z.x)) : A$Deep$d;
