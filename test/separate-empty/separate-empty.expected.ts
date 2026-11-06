export const twice = (f: (_: number) => number, n: number): number => f(f(n));
export const pick = (f: (_: boolean) => number): ((_: boolean) => number) => f;
