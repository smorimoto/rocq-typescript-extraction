export const s = (n: bigint): bigint => n + 1n;
export const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export const fst: <A, B>(_0: readonly [A, B]) => A = <A, B>(
  p: readonly [A, B]
): A => p[0];

export const snd: <A, B>(_0: readonly [A, B]) => B = <A, B>(
  p: readonly [A, B]
): B => p[1];
