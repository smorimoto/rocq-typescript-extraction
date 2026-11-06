const Box$full = (n: number): number => n;

const Box$matchBox = <R>(
  empty: () => R,
  full: (n: number) => R,
  b: number
): R => (b < 0 ? empty() : full(b));

const Box$zero = 0;

export const Box = {
  full: Box$full,
  matchBox: Box$matchBox,
  zero: Box$zero,
} as const;
