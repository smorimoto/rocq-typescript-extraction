import type { List, Nil } from "./number/sorts.ts";

export type { List } from "./number/sorts.ts";

export const nil: Nil = { tag: "Nil" };

export const cons = <A>(arg0: A, arg1: List<A>): List<A> => ({
  arg0,
  arg1,
  tag: "Cons",
});

export const ofArray = <A>(values: readonly A[]): List<A> => {
  let result: List<A> = nil;

  for (const value of values.toReversed()) {
    result = cons(value, result);
  }

  return result;
};

export const toArray = <A>(list: List<A>): A[] => {
  const values: A[] = [];
  let rest = list;

  while (rest.tag === "Cons") {
    values.push(rest.arg0);
    rest = rest.arg1;
  }

  return values;
};
