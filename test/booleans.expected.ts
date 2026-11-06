const andb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a && b;

const orb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a || b;

export const xorb = (b1: boolean, b2: boolean): boolean => (b1 ? !b2 : b2);
const negb: (_0: boolean) => boolean = (b: boolean): boolean => !b;

const even = (n: number): boolean => {
  let n1 = n;

  for (;;) {
    if (n1 === 0) {
      return true;
    }

    const n0: number = n1 - 1;

    if (n0 === 0) {
      return false;
    }

    const nʹ: number = n0 - 1;
    n1 = nʹ;
  }
};

export const xor = (a: boolean, b: boolean): boolean =>
  andb(orb(a, b), negb(andb(a, b)));

export const choose = <A>(b: boolean, x: A, y: A): A => (b ? x : y);
export const decide = (n: number): boolean => n === 0;
export const isZero = (n: number): boolean => decide(n);
export const nothing = undefined;
export const forget = <A>(_unused: A): undefined => undefined;

export interface Dot {
  readonly tag: "Dot";
}

export interface Dash {
  readonly tag: "Dash";
  readonly len: number;
}

export type Token = Dot | Dash;

export const dot: Dot = { tag: "Dot" };
export const dash = (len: number): Token => ({ len, tag: "Dash" });

export const dotAnd = (t: Token, b: boolean): boolean =>
  andb(t.tag === "Dot", b);

export const dashOr = (t: Token, b: boolean): boolean =>
  orb(t.tag !== "Dot", b);

export interface Box {
  readonly flag: boolean;
  readonly count: number;
}

export const notb = (b: boolean): boolean => !b;
export const unflagged = (r: Box): boolean => !r.flag;
export const secondOff = (p: readonly [boolean, boolean]): boolean => !p[1];
export const odd = (n: number): boolean => !even(n);
export const nonzero = (n: number): boolean => !decide(n);

export const twice = (b: boolean): boolean => {
  const r = !b;

  return andb(r, r);
};
