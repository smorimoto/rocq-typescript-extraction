export const collatz = (fuel: number, start: number): number => {
  let steps = 0;
  let remaining = fuel;
  let z = start;

  while (remaining !== 0 && z !== 1) {
    remaining -= 1;
    z = z % 2 === 0 ? Math.floor(z / 2) : 3 * z + 1;
    steps += 1;
  }

  return steps;
};

export const collatzFrom = (
  fuel: number,
  count: number,
  start: number
): number => {
  const steps: number[] = [];
  let remaining = count;
  let z = start;

  while (remaining !== 0) {
    steps.push(collatz(fuel, z));
    remaining -= 1;
    z += 1;
  }

  let total = 0;

  for (let step = steps.pop(); step !== undefined; step = steps.pop()) {
    total = step + total;
  }

  return total;
};

export const collatzTotal = (fuel: number, count: number): number =>
  collatzFrom(fuel, count, 1);

export const modulo = (a: number, b: number): number => {
  if (b === 0) {
    return a;
  }

  const r = a % b;

  if (r === 0) {
    return 0;
  }

  return r < 0 === b < 0 ? r : r + b;
};

export const gcd = (a: number, b: number): number => {
  let magnitude = Math.abs(a);
  let bits = 0;

  while (magnitude !== 0) {
    bits += 1;
    magnitude = Math.floor(magnitude / 2);
  }

  let remaining = a === 0 ? 1 : bits + bits;
  let x = a;
  let y = b;

  while (remaining !== 0) {
    remaining -= 1;

    if (x === 0) {
      return Math.abs(y);
    }

    const divisor = Math.abs(x);
    x = modulo(y, divisor);
    y = divisor;
  }

  return 1;
};
