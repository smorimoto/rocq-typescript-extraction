export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

const matchProd = <A, B, R>(f: (a: A, b: B) => R, p: readonly [A, B]): R =>
  f(p[0], p[1]);

const cons = <A>(x: A, xs: readonly A[]): readonly A[] => [x, ...xs];

const matchList = <A, R>(
  onNil: () => R,
  onCons: (x: A, xs: readonly A[]) => R,
  l: readonly A[]
): R => {
  const first = l.values().next();

  return first.done ? onNil() : onCons(first.value, l.slice(1));
};

const add = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: Nat;

    switch (n0.tag) {
      case "O": {
        returned = m;
        break;
      }

      case "S": {
        depth += 1;
        n0 = n0.arg0;
        continue;
      }

      default: {
        returned = n0 satisfies never;
      }
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

const weight: (_0: Nat) => Nat = (n: Nat): Nat => n;
export const dup = <A>(x: A): readonly A[] => cons(x, cons(x, []));

const pick: <A>(_0: readonly A[], _1: A) => A = <A>(
  xs: readonly A[],
  d: A
): A => {
  const first = xs.values().next();

  return first.done ? d : first.value;
};

export const firstOr = <A>(l: readonly A[], d: A): A =>
  matchList(
    (): A => d,
    (x: A, _unused: readonly A[]): A => x,
    l
  );

export const applyPair = <A, B>(p: readonly [(_: A) => B, A]): B =>
  matchProd((f: (_: A) => B, x: A): B => f(x), p);

export const diagonal = <A>(x: A): readonly (readonly [A, A])[] =>
  cons(pair(x, x), []);

export const chosen: Nat = pick(dup<Nat>(s(s(s(o)))), o);
export const heavy: Nat = weight(s(s(o)));
const x: Nat = weight(s(o));
export const plusSeed: (_: Nat) => Nat = (x0: Nat): Nat => add(x, x0);
const span = (lo: Nat, hi: Nat): readonly [Nat, Nat] => [lo, hi];

const matchSpan = <R>(f: (lo: Nat, hi: Nat) => R, p: readonly [Nat, Nat]): R =>
  f(p[0], p[1]);

export const unitSpan: readonly [Nat, Nat] = [o, s(o)];
export const ends: readonly Nat[] = [...span(o, s(o))];
export const summary = `${matchSpan((_lo: Nat, hi: Nat): Nat => hi, unitSpan).tag} on top`;

export const route: (
  request: string,
  response: string,
  context: string
) => "accepted" | "rejected" | "deferred" = (
  request: string,
  response: string,
  context: string
): "accepted" | "rejected" | "deferred" =>
  request === response && context === "" ? "accepted" : "rejected";
