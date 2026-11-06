import { blue, force0, localCofix, red, wrap } from "./local-cofix.ts";
import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";

console.log("a local cofix reads its match when the cell is forced");

print(toNumber(force0(localCofix(ofNumber(2), red))));

print(toNumber(force0(localCofix(ofNumber(3), blue))));

console.log("a local cofix stored in a pair reads its match when forced");

print(toNumber(force0(wrap(ofNumber(2), red).arg1)));

print(toNumber(force0(wrap(ofNumber(3), blue).arg1)));

print(toNumber(wrap(ofNumber(3), blue).arg0));
