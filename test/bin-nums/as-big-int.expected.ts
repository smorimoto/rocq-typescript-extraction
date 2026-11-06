const Pos$succ: (_0: bigint) => bigint = (x: bigint): bigint => x + 1n;

const Pos$add: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x + y;

const Pos$addCarry: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x + y + 1n;

const Pos$predDouble: (_0: bigint) => bigint = (x: bigint): bigint =>
  2n * x - 1n;

const Pos$predN: (_0: bigint) => bigint = (x: bigint): bigint => x - 1n;

const Pos$sub: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (x > y ? x - y : 1n);

const Pos$mul: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x * y;

const Pos$div2: (_0: bigint) => bigint = (x: bigint): bigint =>
  x === 1n ? 1n : x >> 1n;

const Pos$div2Up: (_0: bigint) => bigint = (x: bigint): bigint =>
  (x + 1n) >> 1n;

const Pos$compareCont: (
  _0: "Eq" | "Lt" | "Gt",
  _1: bigint,
  _2: bigint
) => "Eq" | "Lt" | "Gt" = (
  r: "Eq" | "Lt" | "Gt",
  x: bigint,
  y: bigint
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return r;
};

const Pos$compare: (_0: bigint, _1: bigint) => "Eq" | "Lt" | "Gt" = (
  x: bigint,
  y: bigint
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return "Eq";
};

const Pos$eqb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x === y;

const Pos$leb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x <= y;

const Pos$sqrt: (_0: bigint) => bigint = (x: bigint): bigint => {
  let s = 2n ** BigInt(Math.ceil(x.toString(2).length / 2));
  let t = (s + x / s) / 2n;

  while (t < s) {
    s = t;
    t = (s + x / s) / 2n;
  }

  return s;
};

const Pos$nsuccDouble: (_0: bigint) => bigint = (x: bigint): bigint =>
  2n * x + 1n;

const Pos$ndouble: (_0: bigint) => bigint = (x: bigint): bigint => 2n * x;

const Pos$lor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x | y;

const Pos$land: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x & y;

const Pos$ldiff: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x & ~y;

const Pos$lxor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x ^ y;

const Pos$toNat: (_0: bigint) => bigint = BigInt;
const Pos$ofSuccNat: (_0: bigint) => bigint = (n): bigint => BigInt(n) + 1n;
const N$succDouble: (_0: bigint) => bigint = (x: bigint): bigint => 2n * x + 1n;
const N$double0: (_0: bigint) => bigint = (x: bigint): bigint => 2n * x;
const N$succPos: (_0: bigint) => bigint = (x: bigint): bigint => x + 1n;

const N$sub: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (x > y ? x - y : 0n);

const N$compare: (_0: bigint, _1: bigint) => "Eq" | "Lt" | "Gt" = (
  x: bigint,
  y: bigint
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return "Eq";
};

const N$leb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x <= y;

const N$posDivEucl: (_0: bigint, _1: bigint) => readonly [bigint, bigint] = (
  a: bigint,
  b: bigint
): readonly [bigint, bigint] => {
  if (b === 0n) {
    return [2n ** BigInt(a.toString(2).length - 1) - 1n, a];
  }

  return [a / b, a % b];
};

const N$lor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x | y;

const N$land: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x & y;

const N$ldiff: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x & ~y;

const N$lxor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x ^ y;

const Z$double0: (_0: bigint) => bigint = (x: bigint): bigint => 2n * x;
const Z$succDouble: (_0: bigint) => bigint = (x: bigint): bigint => 2n * x + 1n;
const Z$predDouble: (_0: bigint) => bigint = (x: bigint): bigint => 2n * x - 1n;

const Z$posSub: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x - y;

const Z$add: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x + y;

const Z$opp: (_0: bigint) => bigint = (x: bigint): bigint => -x;

const Z$sub: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x - y;

const Z$mul: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x * y;

const Z$powPos: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x ** y;

const Z$pow: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (y < 0n ? 0n : x ** y);

const Z$compare: (_0: bigint, _1: bigint) => "Eq" | "Lt" | "Gt" = (
  x: bigint,
  y: bigint
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return "Eq";
};

const Z$leb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x <= y;

const Z$ltb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x < y;

const Z$eqb: (_0: bigint, _1: bigint) => boolean = (
  x: bigint,
  y: bigint
): boolean => x === y;

const Z$max: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (x < y ? y : x);

const Z$min: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => (x > y ? y : x);

const Z$toNat: (_0: bigint) => bigint = (x): bigint => (x > 0 ? BigInt(x) : 0n);
const Z$ofNat: (_0: bigint) => bigint = BigInt;
const Z$ofN: (_0: bigint) => bigint = (x: bigint): bigint => x;

const Z$toPos: (_0: bigint) => bigint = (x: bigint): bigint =>
  x > 0n ? x : 1n;

const Z$posDivEucl: (_0: bigint, _1: bigint) => readonly [bigint, bigint] = (
  a: bigint,
  b: bigint
): readonly [bigint, bigint] => {
  if (b > 0n) {
    return [a / b, a % b];
  }

  const top = 2n ** BigInt(a.toString(2).length - 1);

  return [2n * top - 1n, a - top - b * (top - 1n)];
};

const Z$divEucl: (_0: bigint, _1: bigint) => readonly [bigint, bigint] = (
  a: bigint,
  b: bigint
): readonly [bigint, bigint] => {
  if (b === 0n) {
    return [0n, a];
  }

  const q = a / b;
  const r = a % b;

  return r !== 0n && r < 0n !== b < 0n ? [q - 1n, r + b] : [q, r];
};

const Z$div: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => {
  if (b === 0n) {
    return 0n;
  }

  const q = a / b;

  return a < 0n !== b < 0n && a % b !== 0n ? q - 1n : q;
};

const Z$modulo: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => {
  if (b === 0n) {
    return a;
  }

  const r = a % b;

  return r !== 0n && r < 0n !== b < 0n ? r + b : r;
};

const Z$quotrem: (_0: bigint, _1: bigint) => readonly [bigint, bigint] = (
  a: bigint,
  b: bigint
): readonly [bigint, bigint] => (b === 0n ? [0n, a] : [a / b, a % b]);

const Z$quot: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => (b === 0n ? 0n : a / b);

const Z$rem: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  b: bigint
): bigint => (b === 0n ? a : a % b);

const Z$even: (_0: bigint) => boolean = (x: bigint): boolean => (x & 1n) === 0n;
const Z$div2: (_0: bigint) => bigint = (x: bigint): bigint => x >> 1n;

const Z$sqrtrem: (_0: bigint) => readonly [bigint, bigint] = (
  x: bigint
): readonly [bigint, bigint] => {
  if (x <= 0n) {
    return [0n, 0n];
  }

  let s = 2n ** BigInt(Math.ceil(x.toString(2).length / 2));
  let t = (s + x / s) / 2n;

  while (t < s) {
    s = t;
    t = (s + x / s) / 2n;
  }

  return [s, x - s * s];
};

const Z$shiftl: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  n: bigint
): bigint => a << n;

const Z$shiftr: (_0: bigint, _1: bigint) => bigint = (
  a: bigint,
  n: bigint
): bigint => a >> n;

const Z$lor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x | y;

const Z$land: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x & y;

const Z$lxor: (_0: bigint, _1: bigint) => bigint = (
  x: bigint,
  y: bigint
): bigint => x ^ y;

const Ops$posSucc = (x: bigint): bigint => Pos$succ(x);
const Ops$posAdd = (x: bigint, x0: bigint): bigint => Pos$add(x, x0);
const Ops$posAddCarry = (x: bigint, x0: bigint): bigint => Pos$addCarry(x, x0);
const Ops$posPredDouble = (x: bigint): bigint => Pos$predDouble(x);
const Ops$posPredN = (x: bigint): bigint => Pos$predN(x);
const Ops$posSub = (x: bigint, x0: bigint): bigint => Pos$sub(x, x0);
const Ops$posMul = (x: bigint, x0: bigint): bigint => Pos$mul(x, x0);
const Ops$posDiv2 = (x: bigint): bigint => Pos$div2(x);
const Ops$posDiv2Up = (x: bigint): bigint => Pos$div2Up(x);

const Ops$posCompareCont = (
  x: "Eq" | "Lt" | "Gt",
  x0: bigint,
  x1: bigint
): "Eq" | "Lt" | "Gt" => Pos$compareCont(x, x0, x1);

const Ops$posCompare = (x: bigint, x0: bigint): "Eq" | "Lt" | "Gt" =>
  Pos$compare(x, x0);

const Ops$posEqb = (x: bigint, x0: bigint): boolean => Pos$eqb(x, x0);
const Ops$posLeb = (x: bigint, x0: bigint): boolean => Pos$leb(x, x0);
const Ops$posSqrt = (x: bigint): bigint => Pos$sqrt(x);
const Ops$posNsuccDouble = (x: bigint): bigint => Pos$nsuccDouble(x);
const Ops$posNdouble = (x: bigint): bigint => Pos$ndouble(x);
const Ops$posLor = (x: bigint, x0: bigint): bigint => Pos$lor(x, x0);
const Ops$posLand = (x: bigint, x0: bigint): bigint => Pos$land(x, x0);
const Ops$posLdiff = (x: bigint, x0: bigint): bigint => Pos$ldiff(x, x0);
const Ops$posLxor = (x: bigint, x0: bigint): bigint => Pos$lxor(x, x0);
const Ops$posToNat = (x: bigint): bigint => Pos$toNat(x);
const Ops$posOfSuccNat = (x: bigint): bigint => Pos$ofSuccNat(x);
const Ops$nSuccDouble = (x: bigint): bigint => N$succDouble(x);
const Ops$nDouble = (x: bigint): bigint => N$double0(x);
const Ops$nSuccPos = (x: bigint): bigint => N$succPos(x);
const Ops$nSub = (x: bigint, x0: bigint): bigint => N$sub(x, x0);

const Ops$nCompare = (x: bigint, x0: bigint): "Eq" | "Lt" | "Gt" =>
  N$compare(x, x0);

const Ops$nLeb = (x: bigint, x0: bigint): boolean => N$leb(x, x0);

const Ops$nPosDivEucl = (x: bigint, x0: bigint): readonly [bigint, bigint] =>
  N$posDivEucl(x, x0);

const Ops$nLor = (x: bigint, x0: bigint): bigint => N$lor(x, x0);
const Ops$nLand = (x: bigint, x0: bigint): bigint => N$land(x, x0);
const Ops$nLdiff = (x: bigint, x0: bigint): bigint => N$ldiff(x, x0);
const Ops$nLxor = (x: bigint, x0: bigint): bigint => N$lxor(x, x0);
const Ops$zDouble = (x: bigint): bigint => Z$double0(x);
const Ops$zSuccDouble = (x: bigint): bigint => Z$succDouble(x);
const Ops$zPredDouble = (x: bigint): bigint => Z$predDouble(x);
const Ops$zPosSub = (x: bigint, x0: bigint): bigint => Z$posSub(x, x0);
const Ops$zAdd = (x: bigint, x0: bigint): bigint => Z$add(x, x0);
const Ops$zOpp = (x: bigint): bigint => Z$opp(x);
const Ops$zSub = (x: bigint, x0: bigint): bigint => Z$sub(x, x0);
const Ops$zMul = (x: bigint, x0: bigint): bigint => Z$mul(x, x0);
const Ops$zPowPos = (x: bigint, x0: bigint): bigint => Z$powPos(x, x0);
const Ops$zPow = (x: bigint, x0: bigint): bigint => Z$pow(x, x0);

const Ops$zCompare = (x: bigint, x0: bigint): "Eq" | "Lt" | "Gt" =>
  Z$compare(x, x0);

const Ops$zLeb = (x: bigint, x0: bigint): boolean => Z$leb(x, x0);
const Ops$zLtb = (x: bigint, x0: bigint): boolean => Z$ltb(x, x0);
const Ops$zEqb = (x: bigint, x0: bigint): boolean => Z$eqb(x, x0);
const Ops$zMax = (x: bigint, x0: bigint): bigint => Z$max(x, x0);
const Ops$zMin = (x: bigint, x0: bigint): bigint => Z$min(x, x0);
const Ops$zToNat = (x: bigint): bigint => Z$toNat(x);
const Ops$zOfNat = (x: bigint): bigint => Z$ofNat(x);
const Ops$zOfN = (x: bigint): bigint => Z$ofN(x);
const Ops$zToPos = (x: bigint): bigint => Z$toPos(x);

const Ops$zPosDivEucl = (x: bigint, x0: bigint): readonly [bigint, bigint] =>
  Z$posDivEucl(x, x0);

const Ops$zDivEucl = (x: bigint, x0: bigint): readonly [bigint, bigint] =>
  Z$divEucl(x, x0);

const Ops$zDiv = (x: bigint, x0: bigint): bigint => Z$div(x, x0);
const Ops$zModulo = (x: bigint, x0: bigint): bigint => Z$modulo(x, x0);

const Ops$zQuotrem = (x: bigint, x0: bigint): readonly [bigint, bigint] =>
  Z$quotrem(x, x0);

const Ops$zQuot = (x: bigint, x0: bigint): bigint => Z$quot(x, x0);
const Ops$zRem = (x: bigint, x0: bigint): bigint => Z$rem(x, x0);
const Ops$zEven = (x: bigint): boolean => Z$even(x);
const Ops$zDiv2 = (x: bigint): bigint => Z$div2(x);
const Ops$zSqrtrem = (x: bigint): readonly [bigint, bigint] => Z$sqrtrem(x);
const Ops$zShiftl = (x: bigint, x0: bigint): bigint => Z$shiftl(x, x0);
const Ops$zShiftr = (x: bigint, x0: bigint): bigint => Z$shiftr(x, x0);
const Ops$zLor = (x: bigint, x0: bigint): bigint => Z$lor(x, x0);
const Ops$zLand = (x: bigint, x0: bigint): bigint => Z$land(x, x0);
const Ops$zLxor = (x: bigint, x0: bigint): bigint => Z$lxor(x, x0);

export const Ops = {
  nCompare: Ops$nCompare,
  nDouble: Ops$nDouble,
  nLand: Ops$nLand,
  nLdiff: Ops$nLdiff,
  nLeb: Ops$nLeb,
  nLor: Ops$nLor,
  nLxor: Ops$nLxor,
  nPosDivEucl: Ops$nPosDivEucl,
  nSub: Ops$nSub,
  nSuccDouble: Ops$nSuccDouble,
  nSuccPos: Ops$nSuccPos,
  posAdd: Ops$posAdd,
  posAddCarry: Ops$posAddCarry,
  posCompare: Ops$posCompare,
  posCompareCont: Ops$posCompareCont,
  posDiv2: Ops$posDiv2,
  posDiv2Up: Ops$posDiv2Up,
  posEqb: Ops$posEqb,
  posLand: Ops$posLand,
  posLdiff: Ops$posLdiff,
  posLeb: Ops$posLeb,
  posLor: Ops$posLor,
  posLxor: Ops$posLxor,
  posMul: Ops$posMul,
  posNdouble: Ops$posNdouble,
  posNsuccDouble: Ops$posNsuccDouble,
  posOfSuccNat: Ops$posOfSuccNat,
  posPredDouble: Ops$posPredDouble,
  posPredN: Ops$posPredN,
  posSqrt: Ops$posSqrt,
  posSub: Ops$posSub,
  posSucc: Ops$posSucc,
  posToNat: Ops$posToNat,
  zAdd: Ops$zAdd,
  zCompare: Ops$zCompare,
  zDiv: Ops$zDiv,
  zDiv2: Ops$zDiv2,
  zDivEucl: Ops$zDivEucl,
  zDouble: Ops$zDouble,
  zEqb: Ops$zEqb,
  zEven: Ops$zEven,
  zLand: Ops$zLand,
  zLeb: Ops$zLeb,
  zLor: Ops$zLor,
  zLtb: Ops$zLtb,
  zLxor: Ops$zLxor,
  zMax: Ops$zMax,
  zMin: Ops$zMin,
  zModulo: Ops$zModulo,
  zMul: Ops$zMul,
  zOfN: Ops$zOfN,
  zOfNat: Ops$zOfNat,
  zOpp: Ops$zOpp,
  zPosDivEucl: Ops$zPosDivEucl,
  zPosSub: Ops$zPosSub,
  zPow: Ops$zPow,
  zPowPos: Ops$zPowPos,
  zPredDouble: Ops$zPredDouble,
  zQuot: Ops$zQuot,
  zQuotrem: Ops$zQuotrem,
  zRem: Ops$zRem,
  zShiftl: Ops$zShiftl,
  zShiftr: Ops$zShiftr,
  zSqrtrem: Ops$zSqrtrem,
  zSub: Ops$zSub,
  zSuccDouble: Ops$zSuccDouble,
  zToNat: Ops$zToNat,
  zToPos: Ops$zToPos,
} as const;
