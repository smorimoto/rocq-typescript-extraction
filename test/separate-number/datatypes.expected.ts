export const s = (n: number): number => n + 1;

export const matchNat = <R>(fO: () => R, fS: (p: number) => R, n: number): R =>
  n === 0 ? fO() : fS(n - 1);

export const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export const fst: <A, B>(_0: readonly [A, B]) => A = <A, B>(
  p: readonly [A, B]
): A => p[0];

export const snd: <A, B>(_0: readonly [A, B]) => B = <A, B>(
  p: readonly [A, B]
): B => p[1];
