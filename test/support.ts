type Nat = { readonly tag: "O" } | { readonly arg0: Nat; readonly tag: "S" };

type List<A> =
  | { readonly tag: "Nil" }
  | { readonly arg0: A; readonly arg1: List<A>; readonly tag: "Cons" };

export const toNumber = (n: Nat): number => {
  let k = 0;
  let rest = n;

  while (rest.tag === "S") {
    k += 1;
    rest = rest.arg0;
  }

  return k;
};

export const ofNumber = (k: number): Nat => {
  let n: Nat = { tag: "O" };

  for (let i = 0; i < k; i += 1) {
    n = { arg0: n, tag: "S" };
  }

  return n;
};

export const toArray = <A>(l: List<A>): A[] => {
  const out: A[] = [];
  let rest = l;

  while (rest.tag === "Cons") {
    out.push(rest.arg0);
    rest = rest.arg1;
  }

  return out;
};

export const ofArray = <A>(xs: readonly A[]): List<A> => {
  let l: List<A> = { tag: "Nil" };

  for (const x of xs.toReversed()) {
    l = { arg0: x, arg1: l, tag: "Cons" };
  }

  return l;
};
