const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export type Nary = ((_: number) => Nary) | number;

export const sum = (n: number, acc: number): Nary => {
  if (n === 0) {
    return acc;
  }

  const m: number = n - 1;

  return (x: number): Nary => sum(m, add(acc, x));
};

export const six: number = __magic<
  Nary,
  (_: number) => (_: number) => (_: number) => number
>(sum(s(s(s(0))), 0))(s(0))(s(s(0)))(s(s(s(0))));

export type Tower = boolean;

export const top = (n: number): Tower => {
  let n0 = n;

  for (;;) {
    if (n0 === 0) {
      return true;
    }

    const m: number = n0 - 1;
    n0 = m;
  }
};
