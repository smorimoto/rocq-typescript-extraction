const Pos$succ: (_0: number) => number = (x: number): number => x + 1;

const Pos$add: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x + y;

const Pos$addCarry: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x + y + 1;

const Pos$predDouble: (_0: number) => number = (x: number): number => 2 * x - 1;
const Pos$predN: (_0: number) => number = (x: number): number => x - 1;

const Pos$sub: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => (x > y ? x - y : 1);

const Pos$mul: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x * y;

const Pos$div2: (_0: number) => number = (x: number): number =>
  x === 1 ? 1 : Math.floor(x / 2);

const Pos$div2Up: (_0: number) => number = (x: number): number =>
  Math.ceil(x / 2);

const Pos$compareCont: (
  _0: "Eq" | "Lt" | "Gt",
  _1: number,
  _2: number
) => "Eq" | "Lt" | "Gt" = (
  r: "Eq" | "Lt" | "Gt",
  x: number,
  y: number
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return r;
};

const Pos$compare: (_0: number, _1: number) => "Eq" | "Lt" | "Gt" = (
  x: number,
  y: number
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return "Eq";
};

const Pos$eqb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x === y;

const Pos$leb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x <= y;

const Pos$sqrt: (_0: number) => number = (x: number): number => {
  const s = Math.floor(Math.sqrt(x));

  return s * s > x ? s - 1 : s;
};

const Pos$nsuccDouble: (_0: number) => number = (x: number): number =>
  2 * x + 1;

const Pos$ndouble: (_0: number) => number = (x: number): number => 2 * x;

const Pos$lor: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) | BigInt(y)));

const Pos$land: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) & BigInt(y)));

const Pos$ldiff: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x - Number(BigInt.asIntN(64, BigInt(x) & BigInt(y)));

const Pos$lxor: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) ^ BigInt(y)));

const Pos$toNat: (_0: number) => number = Number;
const Pos$ofSuccNat: (_0: number) => number = (n): number => Number(n) + 1;
const N$succDouble: (_0: number) => number = (x: number): number => 2 * x + 1;
const N$double0: (_0: number) => number = (x: number): number => 2 * x;
const N$succPos: (_0: number) => number = (x: number): number => x + 1;

const N$sub: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => (x > y ? x - y : 0);

const N$compare: (_0: number, _1: number) => "Eq" | "Lt" | "Gt" = (
  x: number,
  y: number
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return "Eq";
};

const N$leb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x <= y;

const N$posDivEucl: (_0: number, _1: number) => readonly [number, number] = (
  a: number,
  b: number
): readonly [number, number] => {
  if (b === 0) {
    return [2 ** (a.toString(2).length - 1) - 1, a];
  }

  return [Math.floor(a / b), a % b];
};

const N$lor: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) | BigInt(y)));

const N$land: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) & BigInt(y)));

const N$ldiff: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x - Number(BigInt.asIntN(64, BigInt(x) & BigInt(y)));

const N$lxor: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) ^ BigInt(y)));

const Z$double0: (_0: number) => number = (x: number): number => 2 * x;
const Z$succDouble: (_0: number) => number = (x: number): number => 2 * x + 1;
const Z$predDouble: (_0: number) => number = (x: number): number => 2 * x - 1;

const Z$posSub: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x - y;

const Z$add: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x + y;

const Z$opp: (_0: number) => number = (x: number): number => 0 - x;

const Z$sub: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x - y;

const Z$mul: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => (x === 0 || y === 0 ? 0 : x * y);

const Z$powPos: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x ** y;

const Z$pow: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => (y < 0 ? 0 : x ** y);

const Z$compare: (_0: number, _1: number) => "Eq" | "Lt" | "Gt" = (
  x: number,
  y: number
): "Eq" | "Lt" | "Gt" => {
  if (x < y) {
    return "Lt";
  }

  if (x > y) {
    return "Gt";
  }

  return "Eq";
};

const Z$leb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x <= y;

const Z$ltb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x < y;

const Z$eqb: (_0: number, _1: number) => boolean = (
  x: number,
  y: number
): boolean => x === y;

const Z$max: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => (x < y ? y : x);

const Z$min: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => (x > y ? y : x);

const Z$toNat: (_0: number) => number = (x): number => (x > 0 ? Number(x) : 0);
const Z$ofNat: (_0: number) => number = Number;
const Z$ofN: (_0: number) => number = (x: number): number => x;
const Z$toPos: (_0: number) => number = (x: number): number => (x > 0 ? x : 1);

const Z$posDivEucl: (_0: number, _1: number) => readonly [number, number] = (
  a: number,
  b: number
): readonly [number, number] => {
  if (b > 0) {
    return [Math.floor(a / b), a % b];
  }

  const top = 2 ** (a.toString(2).length - 1);

  return [2 * top - 1, a - top - b * (top - 1)];
};

const Z$divEucl: (_0: number, _1: number) => readonly [number, number] = (
  a: number,
  b: number
): readonly [number, number] => {
  if (a === 0 || b === 0) {
    return [0, a];
  }

  const q = Math.floor(a / b);
  const r = a % b;

  if (r === 0) {
    return [q, 0];
  }

  return r < 0 === b < 0 ? [q, r] : [q, r + b];
};

const Z$div: (_0: number, _1: number) => number = (
  a: number,
  b: number
): number => (a === 0 || b === 0 ? 0 : Math.floor(a / b));

const Z$modulo: (_0: number, _1: number) => number = (
  a: number,
  b: number
): number => {
  if (b === 0) {
    return a;
  }

  const r = a % b;

  if (r === 0) {
    return 0;
  }

  return r < 0 === b < 0 ? r : r + b;
};

const Z$quotrem: (_0: number, _1: number) => readonly [number, number] = (
  a: number,
  b: number
): readonly [number, number] => {
  if (b === 0) {
    return [0, a];
  }

  const q = Math.trunc(a / b);
  const r = a % b;

  return [q === 0 ? 0 : q, r === 0 ? 0 : r];
};

const Z$quot: (_0: number, _1: number) => number = (
  a: number,
  b: number
): number => {
  if (b === 0) {
    return 0;
  }

  const q = Math.trunc(a / b);

  return q === 0 ? 0 : q;
};

const Z$rem: (_0: number, _1: number) => number = (
  a: number,
  b: number
): number => {
  if (b === 0) {
    return a;
  }

  const r = a % b;

  return r === 0 ? 0 : r;
};

const Z$even: (_0: number) => boolean = (x: number): boolean => x % 2 === 0;
const Z$div2: (_0: number) => number = (x: number): number => Math.floor(x / 2);

const Z$sqrtrem: (_0: number) => readonly [number, number] = (
  x: number
): readonly [number, number] => {
  if (x <= 0) {
    return [0, 0];
  }

  const s = Math.floor(Math.sqrt(x));
  const t = s * s > x ? s - 1 : s;

  return [t, x - t * t];
};

const Z$shiftl: (_0: number, _1: number) => number = (
  a: number,
  n: number
): number => {
  if (n < 0) {
    return Math.floor(a / 2 ** Math.min(-n, 1023));
  }

  return a === 0 ? 0 : a * 2 ** n;
};

const Z$shiftr: (_0: number, _1: number) => number = (
  a: number,
  n: number
): number => {
  if (n > 0) {
    return Math.floor(a / 2 ** Math.min(n, 1023));
  }

  return a === 0 ? 0 : a * 2 ** -n;
};

const Z$lor: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) | BigInt(y)));

const Z$land: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) & BigInt(y)));

const Z$lxor: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => Number(BigInt.asIntN(64, BigInt(x) ^ BigInt(y)));

const Ops$posSucc = (x: number): number => Pos$succ(x);
const Ops$posAdd = (x: number, x0: number): number => Pos$add(x, x0);
const Ops$posAddCarry = (x: number, x0: number): number => Pos$addCarry(x, x0);
const Ops$posPredDouble = (x: number): number => Pos$predDouble(x);
const Ops$posPredN = (x: number): number => Pos$predN(x);
const Ops$posSub = (x: number, x0: number): number => Pos$sub(x, x0);
const Ops$posMul = (x: number, x0: number): number => Pos$mul(x, x0);
const Ops$posDiv2 = (x: number): number => Pos$div2(x);
const Ops$posDiv2Up = (x: number): number => Pos$div2Up(x);

const Ops$posCompareCont = (
  x: "Eq" | "Lt" | "Gt",
  x0: number,
  x1: number
): "Eq" | "Lt" | "Gt" => Pos$compareCont(x, x0, x1);

const Ops$posCompare = (x: number, x0: number): "Eq" | "Lt" | "Gt" =>
  Pos$compare(x, x0);

const Ops$posEqb = (x: number, x0: number): boolean => Pos$eqb(x, x0);
const Ops$posLeb = (x: number, x0: number): boolean => Pos$leb(x, x0);
const Ops$posSqrt = (x: number): number => Pos$sqrt(x);
const Ops$posNsuccDouble = (x: number): number => Pos$nsuccDouble(x);
const Ops$posNdouble = (x: number): number => Pos$ndouble(x);
const Ops$posLor = (x: number, x0: number): number => Pos$lor(x, x0);
const Ops$posLand = (x: number, x0: number): number => Pos$land(x, x0);
const Ops$posLdiff = (x: number, x0: number): number => Pos$ldiff(x, x0);
const Ops$posLxor = (x: number, x0: number): number => Pos$lxor(x, x0);
const Ops$posToNat = (x: number): number => Pos$toNat(x);
const Ops$posOfSuccNat = (x: number): number => Pos$ofSuccNat(x);
const Ops$nSuccDouble = (x: number): number => N$succDouble(x);
const Ops$nDouble = (x: number): number => N$double0(x);
const Ops$nSuccPos = (x: number): number => N$succPos(x);
const Ops$nSub = (x: number, x0: number): number => N$sub(x, x0);

const Ops$nCompare = (x: number, x0: number): "Eq" | "Lt" | "Gt" =>
  N$compare(x, x0);

const Ops$nLeb = (x: number, x0: number): boolean => N$leb(x, x0);

const Ops$nPosDivEucl = (x: number, x0: number): readonly [number, number] =>
  N$posDivEucl(x, x0);

const Ops$nLor = (x: number, x0: number): number => N$lor(x, x0);
const Ops$nLand = (x: number, x0: number): number => N$land(x, x0);
const Ops$nLdiff = (x: number, x0: number): number => N$ldiff(x, x0);
const Ops$nLxor = (x: number, x0: number): number => N$lxor(x, x0);
const Ops$zDouble = (x: number): number => Z$double0(x);
const Ops$zSuccDouble = (x: number): number => Z$succDouble(x);
const Ops$zPredDouble = (x: number): number => Z$predDouble(x);
const Ops$zPosSub = (x: number, x0: number): number => Z$posSub(x, x0);
const Ops$zAdd = (x: number, x0: number): number => Z$add(x, x0);
const Ops$zOpp = (x: number): number => Z$opp(x);
const Ops$zSub = (x: number, x0: number): number => Z$sub(x, x0);
const Ops$zMul = (x: number, x0: number): number => Z$mul(x, x0);
const Ops$zPowPos = (x: number, x0: number): number => Z$powPos(x, x0);
const Ops$zPow = (x: number, x0: number): number => Z$pow(x, x0);

const Ops$zCompare = (x: number, x0: number): "Eq" | "Lt" | "Gt" =>
  Z$compare(x, x0);

const Ops$zLeb = (x: number, x0: number): boolean => Z$leb(x, x0);
const Ops$zLtb = (x: number, x0: number): boolean => Z$ltb(x, x0);
const Ops$zEqb = (x: number, x0: number): boolean => Z$eqb(x, x0);
const Ops$zMax = (x: number, x0: number): number => Z$max(x, x0);
const Ops$zMin = (x: number, x0: number): number => Z$min(x, x0);
const Ops$zToNat = (x: number): number => Z$toNat(x);
const Ops$zOfNat = (x: number): number => Z$ofNat(x);
const Ops$zOfN = (x: number): number => Z$ofN(x);
const Ops$zToPos = (x: number): number => Z$toPos(x);

const Ops$zPosDivEucl = (x: number, x0: number): readonly [number, number] =>
  Z$posDivEucl(x, x0);

const Ops$zDivEucl = (x: number, x0: number): readonly [number, number] =>
  Z$divEucl(x, x0);

const Ops$zDiv = (x: number, x0: number): number => Z$div(x, x0);
const Ops$zModulo = (x: number, x0: number): number => Z$modulo(x, x0);

const Ops$zQuotrem = (x: number, x0: number): readonly [number, number] =>
  Z$quotrem(x, x0);

const Ops$zQuot = (x: number, x0: number): number => Z$quot(x, x0);
const Ops$zRem = (x: number, x0: number): number => Z$rem(x, x0);
const Ops$zEven = (x: number): boolean => Z$even(x);
const Ops$zDiv2 = (x: number): number => Z$div2(x);
const Ops$zSqrtrem = (x: number): readonly [number, number] => Z$sqrtrem(x);
const Ops$zShiftl = (x: number, x0: number): number => Z$shiftl(x, x0);
const Ops$zShiftr = (x: number, x0: number): number => Z$shiftr(x, x0);
const Ops$zLor = (x: number, x0: number): number => Z$lor(x, x0);
const Ops$zLand = (x: number, x0: number): number => Z$land(x, x0);
const Ops$zLxor = (x: number, x0: number): number => Z$lxor(x, x0);

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
