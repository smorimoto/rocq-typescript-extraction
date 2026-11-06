import type { List } from "./data.ts";
import * as data from "./data.ts";

const { cons, nil } = data;

type Pending<A> =
  | { readonly tag: "None" }
  | { readonly tag: "Some"; readonly arg0: List<A> };

const none: Pending<never> = { tag: "None" };
const some = <A>(arg0: List<A>): Pending<A> => ({ arg0, tag: "Some" });

export const merge = (
  left: List<bigint>,
  right: List<bigint>
): List<bigint> => {
  const prefix: bigint[] = [];
  let l = left;
  let r = right;

  while (l.tag === "Cons" && r.tag === "Cons") {
    if (l.arg0 <= r.arg0) {
      prefix.push(l.arg0);
      l = l.arg1;
    } else {
      prefix.push(r.arg0);
      r = r.arg1;
    }
  }

  let result = l.tag === "Nil" ? r : l;

  for (let value = prefix.pop(); value !== undefined; value = prefix.pop()) {
    result = cons(value, result);
  }

  return result;
};

const mergeListToStack = (
  stack: List<Pending<bigint>>,
  list: List<bigint>
): List<Pending<bigint>> => {
  let rest = stack;
  let carry = list;
  let depth = 0;

  while (rest.tag === "Cons" && rest.arg0.tag === "Some") {
    carry = merge(rest.arg0.arg0, carry);
    rest = rest.arg1;
    depth += 1;
  }

  let result = cons(some(carry), rest.tag === "Nil" ? nil : rest.arg1);

  while (depth > 0) {
    result = cons(none, result);
    depth -= 1;
  }

  return result;
};

const mergeStack = (stack: List<Pending<bigint>>): List<bigint> => {
  const pending: List<bigint>[] = [];
  let rest = stack;

  while (rest.tag === "Cons") {
    if (rest.arg0.tag === "Some") {
      pending.push(rest.arg0.arg0);
    }

    rest = rest.arg1;
  }

  let result: List<bigint> = nil;

  for (let value = pending.pop(); value !== undefined; value = pending.pop()) {
    result = merge(value, result);
  }

  return result;
};

export const mergeSort = (list: List<bigint>): List<bigint> => {
  let stack: List<Pending<bigint>> = nil;
  let rest = list;

  while (rest.tag === "Cons") {
    stack = mergeListToStack(stack, cons(rest.arg0, nil));
    rest = rest.arg1;
  }

  return mergeStack(stack);
};
