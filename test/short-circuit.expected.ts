const __fail = (message: string): never => {
  throw new Error(message);
};

const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const eqb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n === m;

const boom = (_unused: number): number =>
  __fail(
    "AXIOM TO BE REALIZED (Dune_Extraction_ShortCircuit.ShortCircuit.boom)"
  );

export const behindAnd = (p: number): number => {
  if (p > 1 && p % 2 === 1) {
    return boom(0);
  }

  if (p % 2 === 0) {
    return s(s(0));
  }

  return 0;
};

export const behindAndStmt = (p: number, b: boolean): number => {
  if (p > 1 && p % 2 === 1) {
    return b ? boom(0) : s(0);
  }

  if (p % 2 === 0) {
    return s(s(0));
  }

  return 0;
};

export const guard = (b: boolean, n: number): number => {
  if (b) {
    if (n === 0) {
      return boom(0);
    }

    const k: number = n - 1;

    return k;
  }

  return 0;
};

export const pickPos = (n: number): number => (eqb(n, 0) ? 1 : 2);

export const scrambled = (n: number): number => {
  const s0: number = pickPos(add(n, n));

  if (s0 > 1 && s0 % 2 === 1) {
    return s(0);
  }

  if (s0 % 2 === 0) {
    return s(s(0));
  }

  return 0;
};

export const bucket = (n: number): number => {
  if (n === 0) {
    const w: number = s(0);

    return add(w, w);
  }

  const k: number = n - 1;
  const w: number = add(k, k);

  return add(w, w);
};
