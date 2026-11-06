import { expect, test } from "bun:test";

import { Ops as AsBigInt } from "./as-big-int.ts";
import { Ops as AsNumber } from "./as-number.ts";
import { Ops as BinNumsAsBigInt } from "./bin-nums-as-big-int.ts";
import { Ops as NatAsBigInt } from "./nat-as-big-int.ts";
import type {
  Bool,
  Comparison,
  N,
  Nat,
  Positive,
  Prod,
  Z,
} from "./reference.ts";
import {
  eq,
  gt,
  lt,
  n0,
  npos,
  o,
  Ops as Reference,
  s,
  xH,
  xI,
  xO,
  z0,
  zneg,
  zpos,
} from "./reference.ts";

type Inputs = readonly (readonly bigint[])[];

interface Codec<G> {
  readonly encode: (v: bigint) => G;
  readonly edges: readonly bigint[];
  readonly draw: () => bigint;
}

interface Output<R, M, B> {
  readonly decode: (r: R) => string;
  readonly fits: (r: R) => boolean;
  readonly ofNumber: (m: M) => string;
  readonly ofBigInt: (b: B) => string;
}

let seed = 88_172_645_463_325_252n;

const random64 = (): bigint => {
  seed =
    (seed * 6_364_136_223_846_793_005n + 1_442_695_040_888_963_407n) %
    2n ** 64n;

  return seed;
};

const drawPositive = (): bigint => {
  const bits =
    random64() % 4n === 0n
      ? 54n + (random64() % 107n)
      : 1n + (random64() % 53n);

  const noise = (random64() * 2n ** 64n + random64()) * 2n ** 64n + random64();

  return 2n ** (bits - 1n) + (noise % 2n ** (bits - 1n));
};

const drawNatural = (): bigint =>
  random64() % 16n === 0n ? 0n : drawPositive();

const drawInteger = (): bigint =>
  random64() % 2n === 0n ? drawNatural() : -drawPositive();

const around = (k: bigint): bigint[] => [2n ** k - 1n, 2n ** k, 2n ** k + 1n];

const edgePositives = [
  1n,
  2n,
  3n,
  4n,
  7n,
  8n,
  255n,
  256n,
  ...around(31n),
  ...around(32n),
  2n ** 52n,
  ...around(53n),
  ...around(64n),
  3n ** 50n,
  2n ** 127n - 1n,
];

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

const positive: Codec<Positive> = {
  draw: drawPositive,
  edges: edgePositives,
  encode: toPositive,
};

const natural: Codec<N> = {
  draw: drawNatural,
  edges: [0n, ...edgePositives],
  encode: (v) => (v === 0n ? n0 : npos(toPositive(v))),
};

const integer: Codec<Z> = {
  draw: drawInteger,
  edges: [0n, ...edgePositives, ...edgePositives.map((v) => -v)],
  encode: (v) => {
    if (v === 0n) {
      return z0;
    }

    return v > 0n ? zpos(toPositive(v)) : zneg(toPositive(-v));
  },
};

const exact = 2n ** 53n;

const fits = (v: bigint): boolean => v <= exact && v >= -exact;

const numeral = (m: number): string => (Object.is(m, -0) ? "-0" : String(m));

const numeric = <R>(decode: (r: R) => bigint): Output<R, number, bigint> => ({
  decode: (r) => String(decode(r)),
  fits: (r) => fits(decode(r)),
  ofBigInt: String,
  ofNumber: numeral,
});

const pairOf = <A>(
  decode: (a: A) => bigint
): Output<
  Prod<A, A>,
  readonly [number, number],
  readonly [bigint, bigint]
> => ({
  decode: (p) => `(${String(decode(p.arg0))}, ${String(decode(p.arg1))})`,
  fits: (p) => fits(decode(p.arg0)) && fits(decode(p.arg1)),
  ofBigInt: ([a, b]) => `(${String(a)}, ${String(b)})`,
  ofNumber: ([a, b]) => `(${numeral(a)}, ${numeral(b)})`,
});

const positiveResult = numeric(ofPositive);

const naturalResult = numeric(ofN);

const integerResult = numeric(ofZ);

const naturalPair = pairOf(ofN);

const integerPair = pairOf(ofZ);

const truth: Output<Bool, boolean, boolean> = {
  decode: (b) => String(b.tag === "True"),
  fits: () => true,
  ofBigInt: String,
  ofNumber: String,
};

type Order = "Eq" | "Lt" | "Gt";

const order: Output<Comparison, Order, Order> = {
  decode: (c) => c.tag,
  fits: () => true,
  ofBigInt: (c) => c,
  ofNumber: (c) => c,
};

const drawn = 300;

const cross = (
  first: readonly bigint[],
  second: readonly bigint[]
): bigint[][] => first.flatMap((a) => second.map((b) => [a, b]));

interface Expected {
  readonly text: string;
  readonly fits: boolean;
}

interface Side {
  readonly label: string;
  readonly bounded: boolean;
  readonly run: (xs: readonly bigint[]) => string;
}

interface Case {
  readonly name: string;
  readonly inputs: Inputs;
  readonly reference: (xs: readonly bigint[]) => Expected;
  readonly sides: readonly Side[];
}

const expected = <R, M, B>(output: Output<R, M, B>, r: R): Expected => ({
  fits: output.fits(r),
  text: output.decode(r),
});

const unary = <A, R, M, B>(spec: {
  readonly name: string;
  readonly input: Codec<A>;
  readonly output: Output<R, M, B>;
  readonly reference: (a: A) => R;
  readonly asNumber: (a: number) => M;
  readonly asBigInt: (a: bigint) => B;
}): Case => ({
  inputs: [
    ...spec.input.edges,
    ...Array.from({ length: drawn }, spec.input.draw),
  ].map((a) => [a]),
  name: spec.name,
  reference: ([a = 0n]) =>
    expected(spec.output, spec.reference(spec.input.encode(a))),
  sides: [
    {
      bounded: true,
      label: "number",
      run: ([a = 0n]) => spec.output.ofNumber(spec.asNumber(Number(a))),
    },
    {
      bounded: false,
      label: "bigint",
      run: ([a = 0n]) => spec.output.ofBigInt(spec.asBigInt(a)),
    },
  ],
});

const binary = <A, B, R, M, BR>(spec: {
  readonly name: string;
  readonly inputs: readonly [Codec<A>, Codec<B>];
  readonly domains?: Inputs;
  readonly output: Output<R, M, BR>;
  readonly reference: (a: A, b: B) => R;
  readonly asNumber: (a: number, b: number) => M;
  readonly asBigInt: (a: bigint, b: bigint) => BR;
}): Case => {
  const [first, second] = spec.inputs;

  return {
    inputs: spec.domains ?? [
      ...cross(first.edges, second.edges),
      ...Array.from({ length: drawn }, () => [first.draw(), second.draw()]),
    ],
    name: spec.name,
    reference: ([a = 0n, b = 0n]) =>
      expected(spec.output, spec.reference(first.encode(a), second.encode(b))),
    sides: [
      {
        bounded: true,
        label: "number",
        run: ([a = 0n, b = 0n]) =>
          spec.output.ofNumber(spec.asNumber(Number(a), Number(b))),
      },
      {
        bounded: false,
        label: "bigint",
        run: ([a = 0n, b = 0n]) => spec.output.ofBigInt(spec.asBigInt(a, b)),
      },
    ],
  };
};

const toNat = (v: bigint): Nat => {
  let n: Nat = o;

  for (let i = 0n; i < v; i += 1n) {
    n = s(n);
  }

  return n;
};

const ofNat = (n: Nat): bigint => {
  let k = 0n;
  let rest = n;

  while (rest.tag === "S") {
    k += 1n;
    rest = rest.arg0;
  }

  return k;
};

const fewNaturals = [0n, 1n, 2n, 3n, 4n, 7n, 8n, 31n, 32n, 33n, 255n, 256n];

const peanoSized = [...fewNaturals, 1000n, 2047n, 2048n, 2049n, 3000n];

const numberToNumber = (f: (a: number) => number): Side => ({
  bounded: true,
  label: "number to number",
  run: ([a = 0n]) => numeral(f(Number(a))),
});

const bigIntToBigInt = (f: (a: bigint) => bigint): Side => ({
  bounded: false,
  label: "bigint to bigint",
  run: ([a = 0n]) => String(f(a)),
});

const numberToBigInt = (f: (a: number) => bigint): Side => ({
  bounded: true,
  label: "number to bigint",
  run: ([a = 0n]) => String(f(Number(a))),
});

const bigIntToNumber = (f: (a: bigint) => number): Side => ({
  bounded: true,
  label: "bigint to number",
  run: ([a = 0n]) => numeral(f(a)),
});

const conversion = <A, R>(spec: {
  readonly name: string;
  readonly domain: readonly bigint[];
  readonly input: (v: bigint) => A;
  readonly output: (r: R) => bigint;
  readonly reference: (a: A) => R;
  readonly sides: readonly Side[];
}): Case => ({
  inputs: spec.domain.map((a) => [a]),
  name: spec.name,
  reference: ([a = 0n]) => {
    const r = spec.output(spec.reference(spec.input(a)));

    return { fits: fits(r), text: String(r) };
  },
  sides: spec.sides,
});

const bitLength = (v: bigint): bigint =>
  BigInt((v < 0n ? -v : v).toString(2).length);

const powers = cross(
  [-(2n ** 32n), -10n, -3n, -2n, -1n, 0n, 1n, 2n, 3n, 2n ** 31n, 2n ** 53n],
  [-5n, -1n, 0n, 1n, 2n, 3n, 5n, 7n, 8n, 16n, 31n, 32n, 52n, 53n, 64n]
).filter(([a = 0n, p = 0n]) => bitLength(a) * p <= 300n);

const offsets = [0n, 1n, 2n, 31n, 32n, 33n, 52n, 53n, 54n, 64n, 100n, 1022n];

const far = [1023n, 1024n, 1100n, 5000n];

const wide = [
  0n,
  1n,
  -1n,
  2n ** 53n,
  -(2n ** 53n),
  3n ** 50n,
  2n ** 127n - 1n,
  -(2n ** 127n - 1n),
];

const shifts = [
  ...cross(integer.edges, [...offsets, ...offsets.map((v) => -v)]),
  ...cross(wide, [...far, ...far.map((v) => -v)]),
];

const compareCont = (r: Order, c: Comparison): Case =>
  binary({
    asBigInt: (a, b) => AsBigInt.posCompareCont(r, a, b),
    asNumber: (a, b) => AsNumber.posCompareCont(r, a, b),
    inputs: [positive, positive],
    name: `Pos.compare_cont ${r}`,
    output: order,
    reference: (a, b) => Reference.posCompareCont(c, a, b),
  });

const cases: readonly Case[] = [
  unary({
    asBigInt: AsBigInt.posSucc,
    asNumber: AsNumber.posSucc,
    input: positive,
    name: "Pos.succ",
    output: positiveResult,
    reference: Reference.posSucc,
  }),
  binary({
    asBigInt: AsBigInt.posAdd,
    asNumber: AsNumber.posAdd,
    inputs: [positive, positive],
    name: "Pos.add",
    output: positiveResult,
    reference: Reference.posAdd,
  }),
  binary({
    asBigInt: AsBigInt.posAddCarry,
    asNumber: AsNumber.posAddCarry,
    inputs: [positive, positive],
    name: "Pos.add_carry",
    output: positiveResult,
    reference: Reference.posAddCarry,
  }),
  unary({
    asBigInt: AsBigInt.posPredDouble,
    asNumber: AsNumber.posPredDouble,
    input: positive,
    name: "Pos.pred_double",
    output: positiveResult,
    reference: Reference.posPredDouble,
  }),
  unary({
    asBigInt: AsBigInt.posPredN,
    asNumber: AsNumber.posPredN,
    input: positive,
    name: "Pos.pred_N",
    output: naturalResult,
    reference: Reference.posPredN,
  }),
  binary({
    asBigInt: AsBigInt.posSub,
    asNumber: AsNumber.posSub,
    inputs: [positive, positive],
    name: "Pos.sub",
    output: positiveResult,
    reference: Reference.posSub,
  }),
  binary({
    asBigInt: AsBigInt.posMul,
    asNumber: AsNumber.posMul,
    inputs: [positive, positive],
    name: "Pos.mul",
    output: positiveResult,
    reference: Reference.posMul,
  }),
  unary({
    asBigInt: AsBigInt.posDiv2,
    asNumber: AsNumber.posDiv2,
    input: positive,
    name: "Pos.div2",
    output: positiveResult,
    reference: Reference.posDiv2,
  }),
  unary({
    asBigInt: AsBigInt.posDiv2Up,
    asNumber: AsNumber.posDiv2Up,
    input: positive,
    name: "Pos.div2_up",
    output: positiveResult,
    reference: Reference.posDiv2Up,
  }),
  compareCont("Eq", eq),
  compareCont("Lt", lt),
  compareCont("Gt", gt),
  binary({
    asBigInt: AsBigInt.posCompare,
    asNumber: AsNumber.posCompare,
    inputs: [positive, positive],
    name: "Pos.compare",
    output: order,
    reference: Reference.posCompare,
  }),
  binary({
    asBigInt: AsBigInt.posEqb,
    asNumber: AsNumber.posEqb,
    inputs: [positive, positive],
    name: "Pos.eqb",
    output: truth,
    reference: Reference.posEqb,
  }),
  binary({
    asBigInt: AsBigInt.posLeb,
    asNumber: AsNumber.posLeb,
    inputs: [positive, positive],
    name: "Pos.leb",
    output: truth,
    reference: Reference.posLeb,
  }),
  unary({
    asBigInt: AsBigInt.posSqrt,
    asNumber: AsNumber.posSqrt,
    input: positive,
    name: "Pos.sqrt",
    output: positiveResult,
    reference: Reference.posSqrt,
  }),
  unary({
    asBigInt: AsBigInt.posNsuccDouble,
    asNumber: AsNumber.posNsuccDouble,
    input: natural,
    name: "Pos.Nsucc_double",
    output: naturalResult,
    reference: Reference.posNsuccDouble,
  }),
  unary({
    asBigInt: AsBigInt.posNdouble,
    asNumber: AsNumber.posNdouble,
    input: natural,
    name: "Pos.Ndouble",
    output: naturalResult,
    reference: Reference.posNdouble,
  }),
  binary({
    asBigInt: AsBigInt.posLor,
    asNumber: AsNumber.posLor,
    inputs: [positive, positive],
    name: "Pos.lor",
    output: positiveResult,
    reference: Reference.posLor,
  }),
  binary({
    asBigInt: AsBigInt.posLand,
    asNumber: AsNumber.posLand,
    inputs: [positive, positive],
    name: "Pos.land",
    output: naturalResult,
    reference: Reference.posLand,
  }),
  binary({
    asBigInt: AsBigInt.posLdiff,
    asNumber: AsNumber.posLdiff,
    inputs: [positive, positive],
    name: "Pos.ldiff",
    output: naturalResult,
    reference: Reference.posLdiff,
  }),
  binary({
    asBigInt: AsBigInt.posLxor,
    asNumber: AsNumber.posLxor,
    inputs: [positive, positive],
    name: "Pos.lxor",
    output: naturalResult,
    reference: Reference.posLxor,
  }),
  conversion({
    domain: peanoSized.filter((v) => v > 0n),
    input: toPositive,
    name: "Pos.to_nat",
    output: ofNat,
    reference: Reference.posToNat,
    sides: [
      numberToNumber(AsNumber.posToNat),
      bigIntToBigInt(AsBigInt.posToNat),
      numberToBigInt(NatAsBigInt.posToNat),
      bigIntToNumber(BinNumsAsBigInt.posToNat),
    ],
  }),
  conversion({
    domain: peanoSized,
    input: toNat,
    name: "Pos.of_succ_nat",
    output: ofPositive,
    reference: Reference.posOfSuccNat,
    sides: [
      numberToNumber(AsNumber.posOfSuccNat),
      bigIntToBigInt(AsBigInt.posOfSuccNat),
      bigIntToNumber(NatAsBigInt.posOfSuccNat),
      numberToBigInt(BinNumsAsBigInt.posOfSuccNat),
    ],
  }),
  unary({
    asBigInt: AsBigInt.nSuccDouble,
    asNumber: AsNumber.nSuccDouble,
    input: natural,
    name: "N.succ_double",
    output: naturalResult,
    reference: Reference.nSuccDouble,
  }),
  unary({
    asBigInt: AsBigInt.nDouble,
    asNumber: AsNumber.nDouble,
    input: natural,
    name: "N.double",
    output: naturalResult,
    reference: Reference.nDouble,
  }),
  unary({
    asBigInt: AsBigInt.nSuccPos,
    asNumber: AsNumber.nSuccPos,
    input: natural,
    name: "N.succ_pos",
    output: positiveResult,
    reference: Reference.nSuccPos,
  }),
  binary({
    asBigInt: AsBigInt.nSub,
    asNumber: AsNumber.nSub,
    inputs: [natural, natural],
    name: "N.sub",
    output: naturalResult,
    reference: Reference.nSub,
  }),
  binary({
    asBigInt: AsBigInt.nCompare,
    asNumber: AsNumber.nCompare,
    inputs: [natural, natural],
    name: "N.compare",
    output: order,
    reference: Reference.nCompare,
  }),
  binary({
    asBigInt: AsBigInt.nLeb,
    asNumber: AsNumber.nLeb,
    inputs: [natural, natural],
    name: "N.leb",
    output: truth,
    reference: Reference.nLeb,
  }),
  binary({
    asBigInt: AsBigInt.nPosDivEucl,
    asNumber: AsNumber.nPosDivEucl,
    inputs: [positive, natural],
    name: "N.pos_div_eucl",
    output: naturalPair,
    reference: Reference.nPosDivEucl,
  }),
  binary({
    asBigInt: AsBigInt.nLor,
    asNumber: AsNumber.nLor,
    inputs: [natural, natural],
    name: "N.lor",
    output: naturalResult,
    reference: Reference.nLor,
  }),
  binary({
    asBigInt: AsBigInt.nLand,
    asNumber: AsNumber.nLand,
    inputs: [natural, natural],
    name: "N.land",
    output: naturalResult,
    reference: Reference.nLand,
  }),
  binary({
    asBigInt: AsBigInt.nLdiff,
    asNumber: AsNumber.nLdiff,
    inputs: [natural, natural],
    name: "N.ldiff",
    output: naturalResult,
    reference: Reference.nLdiff,
  }),
  binary({
    asBigInt: AsBigInt.nLxor,
    asNumber: AsNumber.nLxor,
    inputs: [natural, natural],
    name: "N.lxor",
    output: naturalResult,
    reference: Reference.nLxor,
  }),
  unary({
    asBigInt: AsBigInt.zDouble,
    asNumber: AsNumber.zDouble,
    input: integer,
    name: "Z.double",
    output: integerResult,
    reference: Reference.zDouble,
  }),
  unary({
    asBigInt: AsBigInt.zSuccDouble,
    asNumber: AsNumber.zSuccDouble,
    input: integer,
    name: "Z.succ_double",
    output: integerResult,
    reference: Reference.zSuccDouble,
  }),
  unary({
    asBigInt: AsBigInt.zPredDouble,
    asNumber: AsNumber.zPredDouble,
    input: integer,
    name: "Z.pred_double",
    output: integerResult,
    reference: Reference.zPredDouble,
  }),
  binary({
    asBigInt: AsBigInt.zPosSub,
    asNumber: AsNumber.zPosSub,
    inputs: [positive, positive],
    name: "Z.pos_sub",
    output: integerResult,
    reference: Reference.zPosSub,
  }),
  binary({
    asBigInt: AsBigInt.zAdd,
    asNumber: AsNumber.zAdd,
    inputs: [integer, integer],
    name: "Z.add",
    output: integerResult,
    reference: Reference.zAdd,
  }),
  unary({
    asBigInt: AsBigInt.zOpp,
    asNumber: AsNumber.zOpp,
    input: integer,
    name: "Z.opp",
    output: integerResult,
    reference: Reference.zOpp,
  }),
  binary({
    asBigInt: AsBigInt.zSub,
    asNumber: AsNumber.zSub,
    inputs: [integer, integer],
    name: "Z.sub",
    output: integerResult,
    reference: Reference.zSub,
  }),
  binary({
    asBigInt: AsBigInt.zMul,
    asNumber: AsNumber.zMul,
    inputs: [integer, integer],
    name: "Z.mul",
    output: integerResult,
    reference: Reference.zMul,
  }),
  binary({
    asBigInt: AsBigInt.zPowPos,
    asNumber: AsNumber.zPowPos,
    domains: powers.filter(([, p = 0n]) => p > 0n),
    inputs: [integer, positive],
    name: "Z.pow_pos",
    output: integerResult,
    reference: Reference.zPowPos,
  }),
  binary({
    asBigInt: AsBigInt.zPow,
    asNumber: AsNumber.zPow,
    domains: powers,
    inputs: [integer, integer],
    name: "Z.pow",
    output: integerResult,
    reference: Reference.zPow,
  }),
  binary({
    asBigInt: AsBigInt.zCompare,
    asNumber: AsNumber.zCompare,
    inputs: [integer, integer],
    name: "Z.compare",
    output: order,
    reference: Reference.zCompare,
  }),
  binary({
    asBigInt: AsBigInt.zLeb,
    asNumber: AsNumber.zLeb,
    inputs: [integer, integer],
    name: "Z.leb",
    output: truth,
    reference: Reference.zLeb,
  }),
  binary({
    asBigInt: AsBigInt.zLtb,
    asNumber: AsNumber.zLtb,
    inputs: [integer, integer],
    name: "Z.ltb",
    output: truth,
    reference: Reference.zLtb,
  }),
  binary({
    asBigInt: AsBigInt.zEqb,
    asNumber: AsNumber.zEqb,
    inputs: [integer, integer],
    name: "Z.eqb",
    output: truth,
    reference: Reference.zEqb,
  }),
  binary({
    asBigInt: AsBigInt.zMax,
    asNumber: AsNumber.zMax,
    inputs: [integer, integer],
    name: "Z.max",
    output: integerResult,
    reference: Reference.zMax,
  }),
  binary({
    asBigInt: AsBigInt.zMin,
    asNumber: AsNumber.zMin,
    inputs: [integer, integer],
    name: "Z.min",
    output: integerResult,
    reference: Reference.zMin,
  }),
  conversion({
    domain: [...peanoSized, ...peanoSized.map((v) => -v)],
    input: integer.encode,
    name: "Z.to_nat",
    output: ofNat,
    reference: Reference.zToNat,
    sides: [
      numberToNumber(AsNumber.zToNat),
      bigIntToBigInt(AsBigInt.zToNat),
      numberToBigInt(NatAsBigInt.zToNat),
      bigIntToNumber(BinNumsAsBigInt.zToNat),
    ],
  }),
  conversion({
    domain: peanoSized,
    input: toNat,
    name: "Z.of_nat",
    output: ofZ,
    reference: Reference.zOfNat,
    sides: [
      numberToNumber(AsNumber.zOfNat),
      bigIntToBigInt(AsBigInt.zOfNat),
      bigIntToNumber(NatAsBigInt.zOfNat),
      numberToBigInt(BinNumsAsBigInt.zOfNat),
    ],
  }),
  unary({
    asBigInt: AsBigInt.zOfN,
    asNumber: AsNumber.zOfN,
    input: natural,
    name: "Z.of_N",
    output: integerResult,
    reference: Reference.zOfN,
  }),
  unary({
    asBigInt: AsBigInt.zToPos,
    asNumber: AsNumber.zToPos,
    input: integer,
    name: "Z.to_pos",
    output: positiveResult,
    reference: Reference.zToPos,
  }),
  binary({
    asBigInt: AsBigInt.zPosDivEucl,
    asNumber: AsNumber.zPosDivEucl,
    inputs: [positive, integer],
    name: "Z.pos_div_eucl",
    output: integerPair,
    reference: Reference.zPosDivEucl,
  }),
  binary({
    asBigInt: AsBigInt.zDivEucl,
    asNumber: AsNumber.zDivEucl,
    inputs: [integer, integer],
    name: "Z.div_eucl",
    output: integerPair,
    reference: Reference.zDivEucl,
  }),
  binary({
    asBigInt: AsBigInt.zDiv,
    asNumber: AsNumber.zDiv,
    inputs: [integer, integer],
    name: "Z.div",
    output: integerResult,
    reference: Reference.zDiv,
  }),
  binary({
    asBigInt: AsBigInt.zModulo,
    asNumber: AsNumber.zModulo,
    inputs: [integer, integer],
    name: "Z.modulo",
    output: integerResult,
    reference: Reference.zModulo,
  }),
  binary({
    asBigInt: AsBigInt.zQuotrem,
    asNumber: AsNumber.zQuotrem,
    inputs: [integer, integer],
    name: "Z.quotrem",
    output: integerPair,
    reference: Reference.zQuotrem,
  }),
  binary({
    asBigInt: AsBigInt.zQuot,
    asNumber: AsNumber.zQuot,
    inputs: [integer, integer],
    name: "Z.quot",
    output: integerResult,
    reference: Reference.zQuot,
  }),
  binary({
    asBigInt: AsBigInt.zRem,
    asNumber: AsNumber.zRem,
    inputs: [integer, integer],
    name: "Z.rem",
    output: integerResult,
    reference: Reference.zRem,
  }),
  unary({
    asBigInt: AsBigInt.zEven,
    asNumber: AsNumber.zEven,
    input: integer,
    name: "Z.even",
    output: truth,
    reference: Reference.zEven,
  }),
  unary({
    asBigInt: AsBigInt.zDiv2,
    asNumber: AsNumber.zDiv2,
    input: integer,
    name: "Z.div2",
    output: integerResult,
    reference: Reference.zDiv2,
  }),
  unary({
    asBigInt: AsBigInt.zSqrtrem,
    asNumber: AsNumber.zSqrtrem,
    input: integer,
    name: "Z.sqrtrem",
    output: integerPair,
    reference: Reference.zSqrtrem,
  }),
  binary({
    asBigInt: AsBigInt.zShiftl,
    asNumber: AsNumber.zShiftl,
    domains: shifts,
    inputs: [integer, integer],
    name: "Z.shiftl",
    output: integerResult,
    reference: Reference.zShiftl,
  }),
  binary({
    asBigInt: AsBigInt.zShiftr,
    asNumber: AsNumber.zShiftr,
    domains: shifts,
    inputs: [integer, integer],
    name: "Z.shiftr",
    output: integerResult,
    reference: Reference.zShiftr,
  }),
  binary({
    asBigInt: AsBigInt.zLor,
    asNumber: AsNumber.zLor,
    inputs: [integer, integer],
    name: "Z.lor",
    output: integerResult,
    reference: Reference.zLor,
  }),
  binary({
    asBigInt: AsBigInt.zLand,
    asNumber: AsNumber.zLand,
    inputs: [integer, integer],
    name: "Z.land",
    output: integerResult,
    reference: Reference.zLand,
  }),
  binary({
    asBigInt: AsBigInt.zLxor,
    asNumber: AsNumber.zLxor,
    inputs: [integer, integer],
    name: "Z.lxor",
    output: integerResult,
    reference: Reference.zLxor,
  }),
];

const unbounded = (side: Side): boolean => !side.bounded;

const mismatches = (c: Case): string[] => {
  const found: string[] = [];

  for (const xs of c.inputs) {
    const want = c.reference(xs);

    const sides =
      want.fits && xs.every(fits) ? c.sides : c.sides.filter(unbounded);

    for (const side of sides) {
      const got = side.run(xs);

      if (got !== want.text) {
        found.push(
          `(${xs.join(", ")}) as ${side.label}: ${got}, not ${want.text}`
        );
      }
    }
  }

  return found.slice(0, 10);
};

test.each(cases)(
  "$name agrees with its definition as number and bigint",
  { timeout: 5000 },
  (c) => {
    expect(mismatches(c)).toStrictEqual([]);
  }
);

test("BigInt conversions stay exact beyond 2^53 in all four directions", () => {
  for (const n of [9_007_199_254_740_993n, 2n ** 127n - 1n]) {
    expect(AsBigInt.posToNat(n)).toBe(n);
    expect(AsBigInt.zToNat(n)).toBe(n);
    expect(AsBigInt.zToNat(-n)).toBe(0n);
    expect(AsBigInt.posOfSuccNat(n)).toBe(n + 1n);
    expect(AsBigInt.zOfNat(n)).toBe(n);
  }
});

test("bigint parity and floor halving agree with Rocq across signed limb boundaries", () => {
  for (const magnitude of [
    0n,
    2n,
    2n ** 53n,
    2n ** 64n,
    2n ** 127n,
    2n ** 1024n,
  ]) {
    for (const offset of [-1n, 0n, 1n]) {
      for (const x of [magnitude + offset, -magnitude + offset]) {
        const encoded = integer.encode(x);
        const half = AsBigInt.zDiv2(x);
        expect(AsBigInt.zEven(x)).toBe(Reference.zEven(encoded).tag === "True");
        expect(half).toBe(ofZ(Reference.zDiv2(encoded)));
        expect(x - 2n * half).toBe(AsBigInt.zEven(x) ? 0n : 1n);
      }
    }
  }
});

test("bigint floor division stays exact across signs and large boundaries", () => {
  for (const n of [2n ** 53n + 1n, 2n ** 64n, 2n ** 127n - 1n]) {
    for (const a of [0n, n, -n, n + 1n, -n - 1n]) {
      const z = integer.encode(a);

      expect(AsBigInt.zDiv2(a)).toBe(ofZ(Reference.zDiv2(z)));

      for (const b of [0n, 1n, -1n, 2n, -2n, 3n, -3n, n, -n]) {
        expect(AsBigInt.zDiv(a, b)).toBe(
          ofZ(Reference.zDiv(z, integer.encode(b)))
        );
      }
    }
  }
});

test("bigint bitwise calls stay independent across limb boundaries", () => {
  const edges = [0n, 1n, ...around(63n), ...around(64n), ...around(128n)];

  for (const a of edges) {
    for (const b of edges.toReversed()) {
      const n = natural.encode(a);
      const m = natural.encode(b);

      expect(AsBigInt.nLor(a, b)).toBe(ofN(Reference.nLor(n, m)));
      expect(AsBigInt.nLand(a, b)).toBe(ofN(Reference.nLand(n, m)));
      expect(AsBigInt.nLdiff(a, b)).toBe(ofN(Reference.nLdiff(n, m)));
      expect(AsBigInt.nLxor(a, b)).toBe(ofN(Reference.nLxor(n, m)));

      for (const x of [a, -a]) {
        for (const y of [b, -b]) {
          const z = integer.encode(x);
          const w = integer.encode(y);

          expect(AsBigInt.zLor(x, y)).toBe(ofZ(Reference.zLor(z, w)));
          expect(AsBigInt.zLand(x, y)).toBe(ofZ(Reference.zLand(z, w)));
          expect(AsBigInt.zLxor(x, y)).toBe(ofZ(Reference.zLxor(z, w)));
        }
      }
    }
  }
});

test("bigint shifts saturate for amounts beyond machine-word sizes", () => {
  const distance = 2n ** 128n;

  for (const x of [-(2n ** 1024n), -1n, 0n, 1n, 2n ** 1024n]) {
    const saturated = x < 0n ? -1n : 0n;
    expect(AsBigInt.zShiftr(x, distance)).toBe(saturated);
    expect(AsBigInt.zShiftl(x, -distance)).toBe(saturated);
  }

  expect(AsBigInt.zShiftl(0n, distance)).toBe(0n);
  expect(AsBigInt.zShiftr(0n, -distance)).toBe(0n);
});

test("Number bitwise realisers preserve bits above 32 without allocating shared state", () => {
  for (const [x, y] of [
    [2 ** 31 + 3, 2 ** 32 + 5],
    [2 ** 40 + 3, 2 ** 40 + 5],
    [Number.MAX_SAFE_INTEGER, 2 ** 52 + 1],
  ] satisfies [number, number][]) {
    const a = BigInt(x);
    const b = BigInt(y);
    expect(AsNumber.posLor(x, y)).toBe(Number(AsBigInt.posLor(a, b)));
    expect(AsNumber.posLand(x, y)).toBe(Number(AsBigInt.posLand(a, b)));
    expect(AsNumber.posLxor(x, y)).toBe(Number(AsBigInt.posLxor(a, b)));
    expect(AsNumber.posLdiff(x, y)).toBe(Number(AsBigInt.posLdiff(a, b)));
    expect(AsNumber.nLor(x, y)).toBe(Number(AsBigInt.nLor(a, b)));
    expect(AsNumber.nLand(x, y)).toBe(Number(AsBigInt.nLand(a, b)));
    expect(AsNumber.nLxor(x, y)).toBe(Number(AsBigInt.nLxor(a, b)));
    expect(AsNumber.nLdiff(x, y)).toBe(Number(AsBigInt.nLdiff(a, b)));

    for (const sign of [1n, -1n]) {
      const z = integer.encode(sign * a);
      const w = integer.encode(b);
      expect(AsNumber.zLor(Number(sign * a), y)).toBe(
        Number(ofZ(Reference.zLor(z, w)))
      );
      expect(AsNumber.zLand(Number(sign * a), y)).toBe(
        Number(ofZ(Reference.zLand(z, w)))
      );
      expect(AsNumber.zLxor(Number(sign * a), y)).toBe(
        Number(ofZ(Reference.zLxor(z, w)))
      );
    }
  }
});

test("Number bitwise realisers retain signed 64-bit wrapping and canonical zero", () => {
  expect(AsNumber.zLor(2 ** 63, 0)).toBe(-(2 ** 63));
  expect(AsNumber.zLxor(2 ** 64, 0)).toBe(0);
  expect(AsNumber.nLand(2 ** 64, 2 ** 64)).toBe(0);
  expect(AsNumber.posLdiff(2 ** 63, 2 ** 63)).toBe(2 ** 64);
  expect(Object.is(AsNumber.zLand(-0, 0), 0)).toBe(true);
});
