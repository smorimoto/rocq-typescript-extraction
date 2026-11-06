import {
  AL,
  boxed,
  cons,
  FL,
  Fixed,
  nil,
  ones,
  Pairs,
  PP,
  total,
  U,
  Use,
  xs,
} from "./higher-kinded.ts";
import type {
  CONTAINER,
  List,
  MAP,
  TypeLambda,
  UBoxed,
} from "./higher-kinded.ts";
import { print } from "./observe.ts";

interface ArrayLambda extends TypeLambda {
  readonly type: readonly this["Target"][];
}

const Arrays: CONTAINER<ArrayLambda> = {
  empty: () => [],
  map: (f, items) => items.map((x) => f(x)),
};

interface RecordLambda extends TypeLambda {
  readonly type: ReadonlyMap<this["Target"], this["Target1"]>;
}

const Records: MAP<RecordLambda> = {
  add: (k, v, m) => new Map([...m, [k, v]]),
  empty: () => new Map(),
};

console.log("an application to list instantiates the lambda of list");

{
  print({ actual: total, expected: nil });
  const one: List<number> = cons(1, nil);
  print({ actual: U.twice((n: number) => n + 1, one), expected: cons(3, nil) });

  const b: UBoxed = boxed;
  print({ actual: b, expected: nil });
  print({ actual: AL.again, expected: nil });
  print({ actual: AL.U.succs, expected: nil });
}

console.log("a type of two parameters and a constraint");

{
  print({ actual: ones, expected: cons([1, true], nil) });
  print({ actual: xs, expected: cons(2, nil) });
  print({ actual: FL.xs, expected: xs });

  const heads = Fixed({
    empty: () => nil,
    map: (f, l) => (l.tag === "Cons" ? cons(f(l.arg0), nil) : nil),
  });

  print({ actual: heads.xs, expected: cons(2, nil) });
}

console.log("a consumer declares its own lambda and applies the functor");

{
  const AU = Use<ArrayLambda>(Arrays);
  const three: readonly number[] = AU.twice((n) => n + 1, [0, 1]);

  print(three);
  print(AU.succs);

  const one: ReadonlyMap<number, boolean> = Pairs<RecordLambda>(Records).one;
  print([...one]);
  print({ actual: PP.one, expected: ones });
}
