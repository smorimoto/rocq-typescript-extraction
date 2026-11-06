const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

export interface SEED {
  readonly n: number;
}

export interface MakeResult {
  readonly dep: <B extends boolean>(b: B) => B extends true ? number : boolean;
}

export const Make = (S: SEED): MakeResult => {
  const dep = <B extends boolean>(b: B): B extends true ? number : boolean =>
    b
      ? __magic<number, B extends true ? number : boolean>(S.n)
      : __magic<boolean, B extends true ? number : boolean>(false);

  return { dep };
};

export interface DEP {
  readonly dep: <B extends boolean>(_0: B) => B extends true ? number : boolean;
}

export interface UseResult {
  readonly amount: number;
}

export const Use = (D: DEP): UseResult => {
  const amount: number = D.dep(true);

  return { amount };
};
