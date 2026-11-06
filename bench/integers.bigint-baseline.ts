export const collatz = (fuel: bigint, start: bigint): bigint => {
  let steps = 0n;
  let remaining = fuel;
  let z = start;

  while (remaining !== 0n && z !== 1n) {
    remaining -= 1n;
    z = z % 2n === 0n ? z / 2n : 3n * z + 1n;
    steps += 1n;
  }

  return steps;
};

export const collatzFrom = (
  fuel: bigint,
  count: bigint,
  start: bigint
): bigint => {
  const steps: bigint[] = [];
  let remaining = count;
  let z = start;

  while (remaining !== 0n) {
    steps.push(collatz(fuel, z));
    remaining -= 1n;
    z += 1n;
  }

  let total = 0n;

  for (let step = steps.pop(); step !== undefined; step = steps.pop()) {
    total = step + total;
  }

  return total;
};

export const collatzTotal = (fuel: bigint, count: bigint): bigint =>
  collatzFrom(fuel, count, 1n);

export const modulo = (a: bigint, b: bigint): bigint => {
  if (b === 0n) {
    return a;
  }

  const r = a % b;

  return r !== 0n && r < 0n !== b < 0n ? r + b : r;
};

export const gcd = (a: bigint, b: bigint): bigint => {
  let magnitude = a < 0n ? -a : a;
  let bits = 0n;

  while (magnitude !== 0n) {
    bits += 1n;
    magnitude /= 2n;
  }

  let remaining = a === 0n ? 1n : bits + bits;
  let x = a;
  let y = b;

  while (remaining !== 0n) {
    remaining -= 1n;

    if (x === 0n) {
      return y < 0n ? -y : y;
    }

    const divisor = x < 0n ? -x : x;
    x = modulo(y, divisor);
    y = divisor;
  }

  return 1n;
};
