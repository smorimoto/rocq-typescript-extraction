const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];
const fst = <A, B>(p: readonly [A, B]): A => p[0];
const snd = <A, B>(p: readonly [A, B]): B => p[1];

const add = (n: number, m: number): number => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = m;
    } else {
      const p: number = n0 - 1;
      depth += 1;
      n0 = p;
      continue;
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = s(returned);
    }
  }
};

const swapSum = (p: readonly [number, number]): readonly [number, number] =>
  pair(snd(p), fst(p));

export const bucket = (n: number): number => {
  if (n === 0) {
    const w: number = s(s(s(s(s(s(s(s(s(s(0))))))))));

    return add(w, w);
  }

  const n0: number = n - 1;

  if (n0 === 0) {
    const w: number = s(
      s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))))))
    );

    return add(w, w);
  }

  const k: number = n0 - 1;
  const w: number = add(k, k);

  return add(w, w);
};

export const bucketWide = (n: number, m: number): number => {
  let result: number;

  if (n === 0) {
    result = s(s(s(s(s(s(s(s(s(s(0))))))))));
  } else {
    const n0: number = n - 1;

    if (n0 === 0) {
      result = s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0))))))))))))))))))));
    } else {
      const k: number = n0 - 1;
      result = k;
    }
  }

  return add(add(m, m), result);
};

export const predecessorInCond = (b: boolean, n: number): number => {
  if (b) {
    if (n === 0) {
      return s(0);
    }

    const p: number = n - 1;

    return s(p);
  }

  return n;
};

export const pairInPartial = (n: number): ((_: number) => number) => {
  const s0: readonly [number, number] = swapSum(pair(n, s(n)));
  const x: number = add(s0[0], s0[1]);

  return (x0: number): number => add(x, x0);
};
