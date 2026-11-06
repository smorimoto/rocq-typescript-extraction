export const powBin = (base: number, exponent: number): number => {
  if (exponent === 0) {
    return 1;
  }

  const odd: boolean[] = [];
  let e = exponent;

  while (e > 1) {
    odd.push(e % 2 === 1);
    e = Math.floor(e / 2);
  }

  let result = base;

  for (let i = odd.length - 1; i >= 0; i -= 1) {
    const square = result * result;
    result = odd[i] ? base * square : square;
  }

  return result;
};
