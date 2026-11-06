import {
  combinedReadings,
  combineMeasurements,
  duréeTotaleDesRelevé,
  earlyMorningShift,
  overnightShift,
  pairwiseCombinations,
  shiftWeight,
  twiceCombined,
} from "./layout.ts";
import { print } from "./observe.ts";
import { ofNumber, toArray, toNumber } from "./support.ts";

console.log("a long parameter list and nested calls past the line width");

{
  const n = combineMeasurements(
    ofNumber(1),
    ofNumber(2),
    ofNumber(3),
    ofNumber(4)
  );

  print(toNumber(n));
  print(toNumber(combinedReadings));
  print(toNumber(duréeTotaleDesRelevé));
}

console.log("arrow chains as an argument and as a callee");

{
  const [first, second] = toArray(pairwiseCombinations);
  print(first && toNumber(first(ofNumber(5))));
  print(second && toNumber(second(ofNumber(5))));
  print(toNumber(twiceCombined(ofNumber(1))));
}

console.log("a four-branch conditional chain as an argument");

print(toNumber(shiftWeight(earlyMorningShift, ofNumber(2))));

print(toNumber(shiftWeight(overnightShift, ofNumber(2))));
