const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

const s = (n: number): number => n + 1;

export interface SEED {
  readonly n: number;
}

export interface MakeResult {
  readonly dep: <B extends boolean>(b: B) => B extends true ? number : boolean;
  readonly zero: number;
}

export const Make = (S: SEED): MakeResult => {
  const dep = <B extends boolean>(b: B): B extends true ? number : boolean =>
    b
      ? __magic<number, B extends true ? number : boolean>(S.n)
      : __magic<boolean, B extends true ? number : boolean>(false);

  const zero: number = dep(true);

  return { dep, zero };
};

export interface DEP {
  readonly dep: <B extends boolean>(_0: B) => B extends true ? number : boolean;
}

export interface UseResult {
  readonly amount: number;
  readonly flag: boolean;
}

export const Use = (D: DEP): UseResult => {
  const amount: number = D.dep(true);
  const flag: boolean = D.dep(false);

  return { amount, flag };
};

const Seed$n: number = s(s(s(0)));

const Seed = {
  n: Seed$n,
} as const;

export const Made = Make(Seed);
export const Applied = Use(Made);
export const three: number = Made.dep(true);
