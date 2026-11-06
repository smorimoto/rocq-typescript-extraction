import {
  abs,
  add,
  classify,
  compare,
  div,
  eqb,
  frshiftexp,
  getSign,
  infinity,
  isFinite0,
  isInfinity,
  isNan,
  isNanAppliedWhereTheArgumentAloneOverflows,
  isZero,
  ldshiftexp,
  leb,
  Leibniz,
  ltb,
  mul,
  nan,
  negInfinity,
  negZero,
  nextDown,
  nextUp,
  normfrMantissa,
  ofUint63,
  one,
  opp,
  sqrt,
  sub,
  two,
  zero,
} from "./floats.ts";
import { print } from "./observe.ts";

const max = Number.MAX_VALUE;

const minSubnormal = Number.MIN_VALUE;

const minNormal = 2 ** -1022;

console.log("the constants of PrimFloat");

print(infinity);

print(negInfinity);

print(nan);

print(one);

print(zero);

print(negZero);

print(two);

console.log("classify tells the nine classes apart");

print(classify(1));

print(classify(-1));

print(classify(minSubnormal));

print(classify(-minSubnormal));

print(classify(2 ** -1023));

print(classify(-(2 ** -1023)));

print(classify(max));

print(classify(0));

print(classify(-0));

print(classify(Infinity));

print(classify(-Infinity));

print(classify(Number.NaN));

console.log("the comparisons, with NaN not comparable and the zeros equal");

print(compare(1, 2));

print(compare(2, 1));

print(compare(1, 1));

print(compare(Number.NaN, 1));

print(compare(1, Number.NaN));

print(compare(0, -0));

print(compare(Infinity, Infinity));

print(compare(-Infinity, Infinity));

print(eqb(0, -0));

print(eqb(Number.NaN, Number.NaN));

print(ltb(-0, 0));

print(leb(-0, 0));

print(ltb(1, Number.NaN));

print(leb(Number.NaN, Number.NaN));

console.log("the Leibniz equality tells the zeros apart and the NaNs not");

print(Leibniz.eqb(0, -0));

print(Leibniz.eqb(Number.NaN, Number.NaN));

print(Leibniz.eqb(1, 1));

print(Leibniz.eqb(Number.NaN, 1));

print(Leibniz.eqb(-Number.NaN, Number.NaN));

console.log(
  "next_up and next_down step through the zeros, the extremes, and NaN"
);

print({ actual: nextUp(0), expected: minSubnormal });

print({ actual: nextUp(-0), expected: minSubnormal });

print({ actual: nextDown(0), expected: -minSubnormal });

print({ actual: nextDown(-0), expected: -minSubnormal });

print(nextUp(-minSubnormal));

print(nextDown(minSubnormal));

print(nextUp(max));

print(nextDown(-max));

print(nextUp(-max));

print(nextDown(max));

print(nextUp(Infinity));

print({ actual: nextUp(-Infinity), expected: -max });

print(nextDown(-Infinity));

print({ actual: nextDown(Infinity), expected: max });

print(nextUp(1));

print(nextDown(1));

print(nextUp(-1));

print(nextDown(-1));

print(nextUp(minNormal));

print(nextDown(minNormal));

print(nextUp(Number.NaN));

print(nextDown(Number.NaN));

console.log(
  "frshiftexp splits a float into a mantissa in [0.5, 1) and a shifted exponent"
);

{
  print(frshiftexp(1));
  print(frshiftexp(3));
  print(frshiftexp(-3));
  print(frshiftexp(minSubnormal));
  print(frshiftexp(minNormal));
  print(frshiftexp(max));
  print(frshiftexp(0));
  print(frshiftexp(Infinity));
  print(frshiftexp(-Infinity));

  const [negZeroMantissa, negZeroExponent] = frshiftexp(-0);
  print(negZeroMantissa);
  print(negZeroExponent);

  const [nanMantissa, nanExponent] = frshiftexp(Number.NaN);
  print(nanMantissa);
  print(nanExponent);
}

console.log(
  "ldshiftexp scales by a power of two, rounding once in the subnormal range"
);

print(ldshiftexp(1, 2101n));

print(ldshiftexp(1, 2102n));

print(ldshiftexp(1, 2100n));

print(ldshiftexp(1, 0n));

print(ldshiftexp(1, 4202n));

print(ldshiftexp(1, 9_000_000n));

print(ldshiftexp(3, 2106n));

print(ldshiftexp(1, 3124n));

print(ldshiftexp(1, 3125n));

print(ldshiftexp(max, 2102n));

print(ldshiftexp(minSubnormal, 2100n));

print(ldshiftexp(minSubnormal, 4202n));

print({ actual: ldshiftexp(5, 1024n), expected: minSubnormal });

print({ actual: ldshiftexp(7, 1024n), expected: minSubnormal });

print({ actual: ldshiftexp(3, 1025n), expected: minSubnormal });

print(ldshiftexp(ldshiftexp(1, 1027n), 3100n));

print(ldshiftexp(ldshiftexp(7, 1026n), 3176n));

console.log(
  "normfr_mantissa reads the mantissa of a float in [0.5, 1) and gives 0 elsewhere"
);

print(normfrMantissa(0.75));

print(normfrMantissa(0.5));

print(normfrMantissa(1));

print(normfrMantissa(-0.75));

print(normfrMantissa(0.3));

print(normfrMantissa(0));

print(normfrMantissa(Number.NaN));

console.log("of_uint63 rounds to the nearest float, ties to even");

print(ofUint63(2n ** 63n - 1n));

print(ofUint63(9_007_199_254_740_993n));

print(ofUint63(9_007_199_254_740_995n));

print(ofUint63(0n));

print(ofUint63(2n ** 62n));

console.log("the arithmetic is IEEE 754 arithmetic");

print({ actual: sqrt(2), expected: Math.SQRT2 });

print(sqrt(-1));

print(abs(-1));

print(abs(-0));

print(opp(0));

print(opp(Number.NaN));

print(add(1, 2));

print(sub(1, 2));

print(mul(2, 2));

print(div(1, 0));

print(div(0, 0));

print(div(-1, 0));

console.log("the predicates of PrimFloat extract through the realisers");

print(isNan(Number.NaN));

print(isNan(1));

print(isZero(-0));

print(isInfinity(-Infinity));

print(isFinite0(Number.NaN));

print(isFinite0(1));

print(getSign(-0));

print(getSign(0));

print(getSign(-1));

console.log("a float literal is the lone argument of a call");

print(isNanAppliedWhereTheArgumentAloneOverflows);
