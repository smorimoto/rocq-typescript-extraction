import {
  add,
  addc,
  addcarryc,
  addmuldiv,
  asr,
  compare,
  compares,
  div,
  diveucl,
  diveucl21,
  divs,
  eqb,
  head0,
  land,
  leb,
  lesb,
  lor,
  lsl,
  lsr,
  ltb,
  ltsb,
  lxor,
  mod,
  mods,
  mul,
  mulc,
  sub,
  subc,
  subcarryc,
  tail0,
} from "./int63.ts";
import { print } from "./observe.ts";

const max = 2n ** 63n - 1n;

const signedMin = 2n ** 62n;

const negative = (n: bigint): bigint => 2n ** 63n - n;

console.log("addition, subtraction, and multiplication wrap at 2^63");

print(add(max, 1n));

print(add(signedMin, signedMin));

print(add(5n, 7n));

print({ actual: sub(0n, 1n), expected: max });

print({ actual: sub(5n, 7n), expected: max - 1n });

print(mul(2n ** 32n, 2n ** 32n));

print(mul(max, max));

print(mul(2n ** 31n, 2n ** 31n));

console.log("unsigned division by zero gives zero and the dividend");

print(div(7n, 2n));

print(mod(7n, 2n));

print(div(7n, 0n));

print(mod(7n, 0n));

print(div(max, 2n));

print(mod(max, 2n));

print(diveucl(7n, 2n));

print(diveucl(7n, 0n));

console.log(
  "signed division truncates toward zero, the remainder keeps the dividend's sign"
);

print({ actual: divs(negative(7n), 2n), expected: negative(3n) });

print({ actual: mods(negative(7n), 2n), expected: negative(1n) });

print(divs(negative(7n), negative(2n)));

print({ actual: mods(negative(7n), negative(2n)), expected: negative(1n) });

print({ actual: divs(signedMin, negative(1n)), expected: signedMin });

print(mods(signedMin, negative(1n)));

print(divs(7n, 0n));

print(mods(7n, 0n));

console.log(
  "a shift by 63 or more gives zero, the arithmetic shift keeps the sign"
);

print(lsl(1n, 62n));

print(lsl(1n, 63n));

print({ actual: lsl(max, 1n), expected: max - 1n });

print(lsl(1n, signedMin));

print(lsr(max, 62n));

print(lsr(max, 63n));

print(lsr(8n, 2n));

print(lsr(8n, signedMin));

print({ actual: asr(negative(8n), 1n), expected: negative(4n) });

print({ actual: asr(negative(1n), 62n), expected: max });

print({ actual: asr(negative(1n), 63n), expected: max });

print(asr(4n, 63n));

print(asr(negative(1n), signedMin));

print(asr(8n, 2n));

print(asr(negative(8n), signedMin));

console.log("the bitwise operations");

print(land(12n, 10n));

print(lor(12n, 10n));

print(lxor(12n, 10n));

print({ actual: land(max, signedMin), expected: signedMin });

print({ actual: lor(max, signedMin), expected: max });

print({ actual: lxor(max, signedMin), expected: signedMin - 1n });

console.log("the comparisons, unsigned and signed");

print(eqb(3n, 3n));

print(eqb(3n, 4n));

print(ltb(3n, 4n));

print(ltb(max, 0n));

print(ltb(0n, max));

print(leb(3n, 3n));

print(leb(4n, 3n));

print(ltsb(max, 0n));

print(ltsb(0n, max));

print(lesb(signedMin, 0n));

print(lesb(0n, signedMin));

print(ltsb(negative(7n), negative(8n)));

print(lesb(3n, 3n));

print(compare(1n, 2n));

print(compare(2n, 2n));

print(compare(max, 0n));

print(compares(max, 0n));

print(compares(signedMin, 0n));

print(compares(2n, 1n));

print(compares(2n, 2n));

console.log("the operations with a carry");

print(addc(max, 1n));

print(addc(1n, 2n));

print(addcarryc(max, 0n));

print(addcarryc(1n, 2n));

print({ actual: addcarryc(max - 1n, 0n), expected: { arg0: max, tag: "C0" } });

print({ actual: subc(0n, 1n), expected: { arg0: max, tag: "C1" } });

print(subc(5n, 3n));

print(subcarryc(5n, 3n));

print({ actual: subcarryc(3n, 3n), expected: { arg0: max, tag: "C1" } });

print(subcarryc(1n, 0n));

console.log("the exact multiplication and the division of two words by one");

print({ actual: mulc(max, max), expected: [max - 1n, 1n] });

print(mulc(2n ** 32n, 2n ** 32n));

print(mulc(3n, 5n));

print(mulc(signedMin, 2n));

print(diveucl21(1n, 0n, 2n));

print(diveucl21(1n, 5n, 3n));

print(diveucl21(5n, 0n, 5n));

print(diveucl21(0n, 7n, 2n));

print(diveucl21(3n, 0n, 0n));

print({
  actual: diveucl21(signedMin - 1n, max, max),
  expected: [signedMin, signedMin - 1n],
});

print(addmuldiv(1n, 1n, max));

print(addmuldiv(63n, 5n, 7n));

print(addmuldiv(64n, 5n, 7n));

print(addmuldiv(0n, 5n, 7n));

print(addmuldiv(62n, 1n, signedMin + 1n));

print({ actual: addmuldiv(1n, max, 0n), expected: max - 1n });

console.log("the leading and trailing zeros, 63 of each for zero");

print(head0(0n));

print(head0(1n));

print(head0(max));

print(head0(signedMin));

print(head0(2n ** 31n));

print(tail0(0n));

print(tail0(1n));

print(tail0(signedMin));

print(tail0(12n));

print(tail0(max));
