const s = (n: number): number => n + 1;

export interface SIG<T> {
  readonly z: T;
}

export interface MC {
  readonly tag: "C";
  readonly n: number;
}

export interface MZ {
  readonly tag: "Z";
}

export type MRaw = MC | MZ;

const M$c = (n: number): MRaw => ({ n, tag: "C" });
const M$z0: MZ = { tag: "Z" };

const M$rawRect = <A>(c: (_: number) => A, z: A, r: MRaw): A => {
  switch (r.tag) {
    case "C": {
      return c(r.n);
    }

    case "Z": {
      return z;
    }

    default: {
      return r satisfies never;
    }
  }
};

const M$rawRec = <A>(c: (_: number) => A, z: A, r: MRaw): A => {
  switch (r.tag) {
    case "C": {
      return c(r.n);
    }

    case "Z": {
      return z;
    }

    default: {
      return r satisfies never;
    }
  }
};

const M$z: MRaw = M$c(s(s(s(s(0)))));

export const M = {
  c: M$c,
  rawRec: M$rawRec,
  rawRect: M$rawRect,
  z: M$z,
  z0: M$z0,
} as const;

export interface FResult<T> {
  readonly z: T;
}

export const F = <T>(X: SIG<T>): FResult<T> => {
  const z: T = X.z;

  return { z };
};

export const B = F<MRaw>(M);
export const got: MRaw = B.z;
