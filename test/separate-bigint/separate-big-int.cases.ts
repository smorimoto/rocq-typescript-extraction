import { print } from "../observe.ts";
import { Pair } from "./api.ts";
import { pair, s } from "./datatypes.ts";
import { add } from "./nat.ts";
import { Made, predOr, total } from "./separate-big-int.ts";

console.log("BigInt realisers and tuple signatures cross generated imports");

{
  const large = 9_007_199_254_740_993n;
  print({ actual: s(large), expected: large + 1n });
  print({ actual: pair(large, true), expected: [large, true] });
  print({ actual: add(large, 2n), expected: large + 2n });
  print({ actual: total([large, 2n]), expected: large + 2n });
  print({ actual: predOr(large, 0n), expected: large });
  print({ actual: predOr(0n, large), expected: large - 1n });
}

console.log("BigInt functor input and result signatures accept bigint values");

{
  const result = Pair({ value: 9_007_199_254_740_993n });
  print(result.values);
  print(result.total);
  print(Made.values);
}
