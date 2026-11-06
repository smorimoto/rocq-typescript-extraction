export const isEven = (n: number): boolean => {
  let remaining = n;

  while (remaining !== 0) {
    remaining -= 1;

    if (remaining === 0) {
      return false;
    }

    remaining -= 1;
  }

  return true;
};

export const isOdd = (n: number): boolean => !isEven(n);
