import * as bigIntThenNumber from "./big-int-number.ts";
import * as numberThenBigInt from "./number-big-int.ts";
import { print } from "./observe.ts";

const presets = [
  ["BigInt then Number", bigIntThenNumber],
  ["Number then BigInt", numberThenBigInt],
] as const;

for (const [name, preset] of presets) {
  console.log(`${name} keeps exact mappings in a fresh compilation unit`);
  const large = 9_007_199_254_740_993n;
  print({ actual: preset.fromPositive(large), expected: large });
  print({ actual: preset.fromInteger(large), expected: large });
  print(preset.fromInteger(-large));
  print({ actual: preset.toPositive(large), expected: large + 1n });
  print({ actual: preset.toInteger(large), expected: large });
  print({ actual: preset.add0(large, 2n), expected: large + 2n });
  print(preset.natEven(large));
  print(preset.natEven(large + 1n));
  print(preset.natOdd(large));
  print(preset.natOdd(large + 1n));
  print(preset.natDiv2(large));
  print(preset.natPow(large, 2n));
}
