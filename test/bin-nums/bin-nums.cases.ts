import { print } from "../observe.ts";
import { Ops as AsNumber } from "./as-number.ts";
import type { N, Positive, Z } from "./reference.ts";
import {
  n0,
  npos,
  Ops as Reference,
  xH,
  xI,
  xO,
  z0,
  zneg,
  zpos,
} from "./reference.ts";

const toPositive = (v: bigint): Positive => {
  if (v === 1n) {
    return xH;
  }

  return v % 2n === 0n ? xO(toPositive(v / 2n)) : xI(toPositive(v / 2n));
};

const ofPositive = (p: Positive): bigint => {
  switch (p.tag) {
    case "XH": {
      return 1n;
    }

    case "XO": {
      return 2n * ofPositive(p.arg0);
    }

    case "XI": {
      return 2n * ofPositive(p.arg0) + 1n;
    }

    default: {
      return p satisfies never;
    }
  }
};

const ofN = (n: N): bigint => (n.tag === "N0" ? 0n : ofPositive(n.arg0));

const ofZ = (z: Z): bigint => {
  switch (z.tag) {
    case "Z0": {
      return 0n;
    }

    case "Zpos": {
      return ofPositive(z.arg0);
    }

    case "Zneg": {
      return -ofPositive(z.arg0);
    }

    default: {
      return z satisfies never;
    }
  }
};

const toNatural = (v: bigint): N => (v === 0n ? n0 : npos(toPositive(v)));

const toInteger = (v: bigint): Z => {
  if (v === 0n) {
    return z0;
  }

  return v > 0n ? zpos(toPositive(v)) : zneg(toPositive(-v));
};

console.log("the reference rounds and divides by zero as Rocq does");

{
  const z = toInteger;

  print(ofZ(Reference.zDiv(z(-7n), z(2n))));
  print(ofZ(Reference.zModulo(z(-7n), z(2n))));
  print(ofZ(Reference.zModulo(z(7n), z(-2n))));
  print(ofZ(Reference.zQuot(z(-7n), z(2n))));
  print(ofZ(Reference.zRem(z(-7n), z(2n))));
  print(ofZ(Reference.zDiv(z(5n), z0)));
  print(ofZ(Reference.zModulo(z(5n), z0)));
  print(ofPositive(Reference.posSub(toPositive(3n), toPositive(5n))));
  print(ofN(Reference.nSub(toNatural(3n), toNatural(5n))));
}

console.log("the number realisers never return -0");

print(AsNumber.zMul(0, -3));

print(AsNumber.zOpp(0));

print(AsNumber.zQuot(-1, 5));

print(AsNumber.zRem(-10, 5));

print(AsNumber.zDiv(0, -5));

print(AsNumber.zModulo(-10, 5));

print(AsNumber.zDivEucl(0, -5));
