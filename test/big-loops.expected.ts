const add: (_0: bigint, _1: bigint) => bigint = (
  n: bigint,
  m: bigint
): bigint => n + m;

export const sumTo = (n: bigint, acc: bigint): bigint => {
  let n0 = n;
  let acc0 = acc;

  for (;;) {
    if (n0 === 0n) {
      return acc0;
    }

    const k: bigint = n0 - 1n;
    acc0 = add(acc0, n0);
    n0 = k;
  }
};

export const fibIter = (n: bigint, a: bigint, b: bigint): bigint => {
  let n0 = n;
  let a0 = a;
  let b0 = b;

  for (;;) {
    if (n0 === 0n) {
      return a0;
    }

    const k: bigint = n0 - 1n;
    const b1: bigint = add(a0, b0);
    n0 = k;
    a0 = b0;
    b0 = b1;
  }
};
