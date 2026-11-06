const Pos$toNat: (_0: number) => bigint = BigInt;
const Pos$ofSuccNat: (_0: bigint) => number = (n): number => Number(n) + 1;
const Z$toNat: (_0: number) => bigint = (x): bigint => (x > 0 ? BigInt(x) : 0n);
const Z$ofNat: (_0: bigint) => number = Number;
const Ops$posToNat = (x: number): bigint => Pos$toNat(x);
const Ops$posOfSuccNat = (x: bigint): number => Pos$ofSuccNat(x);
const Ops$zToNat = (x: number): bigint => Z$toNat(x);
const Ops$zOfNat = (x: bigint): number => Z$ofNat(x);

export const Ops = {
  posOfSuccNat: Ops$posOfSuccNat,
  posToNat: Ops$posToNat,
  zOfNat: Ops$zOfNat,
  zToNat: Ops$zToNat,
} as const;
