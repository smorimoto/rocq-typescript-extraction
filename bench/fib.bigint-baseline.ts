export const fibIter = (n: bigint): bigint => {
  let remaining = n;
  let a = 0n;
  let b = 1n;

  while (remaining !== 0n) {
    const sum = a + b;
    remaining -= 1n;
    a = b;
    b = sum;
  }

  return a;
};
