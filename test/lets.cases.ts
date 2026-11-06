import {
  adder,
  countdown,
  doublePlus,
  parity,
  sumTo,
  twicePlus,
} from "./lets.ts";
import { print } from "./observe.ts";
import { ofNumber, toArray, toNumber } from "./support.ts";

console.log("a local fix with an accumulator");

print(toNumber(sumTo(ofNumber(4))));

print(toNumber(sumTo(ofNumber(0))));

console.log("a local mutual fix");

print(parity(ofNumber(4)).tag);

print(parity(ofNumber(7)).tag);

console.log("a let-bound lambda chain is a local function called uncurried");

print(toNumber(twicePlus(ofNumber(2))));

console.log("a let in argument position");

print(toNumber(doublePlus(ofNumber(1), ofNumber(1))));

console.log("a local fix reads a field of the narrowed scrutinee");

print(toArray(countdown(ofNumber(3))).map(toNumber));

print(countdown(ofNumber(0)));

console.log("a let before a returned lambda");

print(toNumber(adder(ofNumber(3))(ofNumber(4))));
