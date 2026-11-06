import { differences, ticks } from "./big-int-accumulators.ts";
import { sumRight } from "./number-accumulators.ts";
import { print } from "./observe.ts";
import { ofArray } from "./support.ts";

console.log(
  "number rounding and different custom realisers keep their evaluation"
);

{
  const large = Number.MAX_SAFE_INTEGER;
  print(sumRight(ofArray([large, 2, -large])));
  print({ actual: sumRight(ofArray([large, 1, 1, 1])), expected: 2 ** 53 + 2 });
  print(differences(ofArray([10n, 3n, 1n])));
  print(ticks(8n));
}
