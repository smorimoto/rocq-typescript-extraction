export const powBin = (base: bigint, exponent: bigint): bigint => {
  if (exponent === 0n) {
    return 1n;
  }

  const odd: boolean[] = [];
  let e = exponent;

  while (e > 1n) {
    odd.push(e % 2n === 1n);
    e /= 2n;
  }

  let result = base;

  for (let i = odd.length - 1; i >= 0; i -= 1) {
    const square = result * result;
    result = odd[i] ? base * square : square;
  }

  return result;
};
