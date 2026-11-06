import {
  functionResult,
  higherRankResult,
  noInputs,
  runFlag,
  runNumber,
  selected,
} from "./curried-type-family.ts";
import { print } from "./observe.ts";

console.log(
  "heterogeneous curried actions retain their runtime arguments and result"
);

print([
  selected,
  runNumber(true, 7),
  runNumber(false, 7),
  runFlag(4, true),
  runFlag(3, true),
  runFlag(4, false),
  noInputs,
]);

console.log("the final result can itself be a function");

print([
  functionResult(true, false, 6),
  functionResult(true, true, 5),
  functionResult(false, true, 6),
  functionResult(false, false, 6),
]);

console.log(
  "a quantified callback retains the result parameter of the action family"
);

print([higherRankResult(0), higherRankResult(13)]);
