import { print } from "../observe.ts";
import { cons, nil } from "./datatypes.ts";
import { Use } from "./kinds.ts";
import type { CONTAINER, TypeLambda } from "./kinds.ts";
import { total, U, W, Wrap } from "./separate-kinds.ts";

interface ArrayLambda extends TypeLambda {
  readonly type: readonly this["Target"][];
}

const Arrays: CONTAINER<ArrayLambda> = {
  empty: () => [],
  map: (f, items) => items.map((x) => f(x)),
};

console.log("applications to a module of another file");

print({ actual: total, expected: cons(3, nil) });

print({ actual: U.e, expected: nil });

print({ actual: W.zeros, expected: nil });

console.log(
  "a consumer lambda extends the TypeLambda of the module type's file"
);

print(Use<ArrayLambda>(Arrays).twice((n) => n * 2, [1, 2]));

print(Wrap<ArrayLambda>(Arrays).zeros);
