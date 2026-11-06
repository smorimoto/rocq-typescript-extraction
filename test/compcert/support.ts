import type { Errmsg, List, Option, Res, String0 } from "./typing.ts";
import { cons, nil } from "./typing.ts";

export const list = <A>(values: readonly A[]): List<A> => {
  let result: List<A> = nil;

  for (const value of values.toReversed()) {
    result = cons(value, result);
  }

  return result;
};

export const array = <A>(values: List<A>): A[] => {
  const result: A[] = [];
  let rest = values;

  while (rest.tag === "Cons") {
    result.push(rest.arg0);
    rest = rest.arg1;
  }

  return result;
};

const string = (value: String0): string => {
  let result = "";
  let rest = value;

  while (rest.tag === "String") {
    const c = rest.arg0;

    const bits = [
      c.arg0,
      c.arg1,
      c.arg2,
      c.arg3,
      c.arg4,
      c.arg5,
      c.arg6,
      c.arg7,
    ];

    const code = bits.reduce((n, bit, i) => n + Number(bit) * 2 ** i, 0);
    result += String.fromCodePoint(code);
    rest = rest.arg1;
  }

  return result;
};

export const messages = (error: Errmsg): (string | bigint)[] =>
  array(error).map((code) =>
    code.tag === "MSG" ? string(code.arg0) : code.arg0
  );

export const success = <A>(result: Res<A>): A => {
  if (result.tag === "Error") {
    throw new Error(
      `Unexpected CompCert error: ${messages(result.arg0).join("")}`
    );
  }

  return result.arg0;
};

export const present = <A>(value: Option<A>): A => {
  if (value.tag === "None") {
    throw new Error("Expected Some from CompCert");
  }

  return value.arg0;
};
