const s = (n: number): number => n + 1;

export type SIG = Record<never, never>;

export interface FC {
  readonly tag: "C";
  readonly n: number;
}

export interface FStop {
  readonly tag: "Stop";
}

export type FRaw = FC | FStop;

const F$c = (n: number): FRaw => ({ n, tag: "C" });

const F$rawRect = <A>(c: (_: number) => A, stop0: A, r: FRaw): A => {
  switch (r.tag) {
    case "C": {
      return c(r.n);
    }

    case "Stop": {
      return stop0;
    }

    default: {
      return r satisfies never;
    }
  }
};

const F$rawRec = <A>(c: (_: number) => A, stop0: A, r: FRaw): A => {
  switch (r.tag) {
    case "C": {
      return c(r.n);
    }

    case "Stop": {
      return stop0;
    }

    default: {
      return r satisfies never;
    }
  }
};

export interface FResult {
  readonly c: (n: number) => FRaw;
  readonly stop: FStop;
  readonly rawRect: <A>(c: (_: number) => A, stop0: A, r: FRaw) => A;
  readonly rawRec: <A>(c: (_: number) => A, stop0: A, r: FRaw) => A;
  readonly z: FRaw;
}

export const F = (_X: SIG): FResult => {
  const stop: FStop = { tag: "Stop" };
  const z: FRaw = F$c(s(0));

  return { c: F$c, rawRec: F$rawRec, rawRect: F$rawRect, stop, z };
};

const A = {} as const;

export type BC = FC;

export type BStop = FStop;

export type BRaw = FRaw;

export const B = F(A);
export const got: BRaw = B.z;
