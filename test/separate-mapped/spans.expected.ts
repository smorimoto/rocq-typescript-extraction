export interface Bounds {
  readonly lo: number;
  readonly hi: number;
}

export interface Cell<A> {
  readonly content: A;
  readonly size: number;
}

export const span = (b: Bounds): Bounds => b;
export const matchSpan = <R>(f: (b: Bounds) => R, s: Bounds): R => f(s);
export const wrap = <A>(x: A): Cell<A> => ({ content: x, size: 1 });

export const matchWrapped = <A, R>(f: (x: A) => R, w: Cell<A>): R =>
  f(w.content);
