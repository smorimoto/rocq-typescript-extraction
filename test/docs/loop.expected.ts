const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export const sumTo = (n: number, acc: number): number => {
  let n0 = n;
  let acc0 = acc;

  for (;;) {
    if (n0 === 0) {
      return acc0;
    }

    const k: number = n0 - 1;
    acc0 = add(acc0, n0);
    n0 = k;
  }
};

export const fibIter = (n: number, a: number, b: number): number => {
  let n0 = n;
  let a0 = a;
  let b0 = b;

  for (;;) {
    if (n0 === 0) {
      return a0;
    }

    const k: number = n0 - 1;
    const b1: number = add(a0, b0);
    n0 = k;
    a0 = b0;
    b0 = b1;
  }
};
