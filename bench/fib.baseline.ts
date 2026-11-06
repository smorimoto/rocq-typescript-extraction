export const fibIter = (n: number): number => {
  let remaining = n;
  let a = 0;
  let b = 1;

  while (remaining !== 0) {
    const sum = a + b;
    remaining -= 1;
    a = b;
    b = sum;
  }

  return a;
};
