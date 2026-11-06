const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const mul: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n * m;

interface Dot {
  readonly tag: "Dot";
}

interface Line {
  readonly tag: "Line";
  readonly n: number;
}

interface Box {
  readonly tag: "Box";
  readonly w: number;
  readonly h: number;
}

type Figure = Dot | Line | Box;

const dot: Dot = { tag: "Dot" };
const line = (n: number): Figure => ({ n, tag: "Line" });
const double0 = (n: number): number => add(n, n);

const classify = (n: number): Figure => {
  if (n === 0) {
    return dot;
  }

  const k: number = n - 1;

  return line(k);
};

export const measure = (n: number): number => {
  const s0: Figure = classify(n);

  switch (s0.tag) {
    case "Dot": {
      return 0;
    }

    case "Line": {
      return double0(s0.n);
    }

    case "Box": {
      return mul(s0.w, s0.h);
    }

    default: {
      return s0 satisfies never;
    }
  }
};
