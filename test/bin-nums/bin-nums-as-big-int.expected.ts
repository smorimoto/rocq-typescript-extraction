const Pos$toNat: (_0: bigint) => number = Number;
const Pos$ofSuccNat: (_0: number) => bigint = (n): bigint => BigInt(n) + 1n;
const Z$toNat: (_0: bigint) => number = (x): number => (x > 0 ? Number(x) : 0);
const Z$ofNat: (_0: number) => bigint = BigInt;
const Ops$posToNat = (x: bigint): number => Pos$toNat(x);
const Ops$posOfSuccNat = (x: number): bigint => Pos$ofSuccNat(x);
const Ops$zToNat = (x: bigint): number => Z$toNat(x);
const Ops$zOfNat = (x: number): bigint => Z$ofNat(x);

export const Ops = {
  posOfSuccNat: Ops$posOfSuccNat,
  posToNat: Ops$posToNat,
  zOfNat: Ops$zOfNat,
  zToNat: Ops$zToNat,
} as const;
