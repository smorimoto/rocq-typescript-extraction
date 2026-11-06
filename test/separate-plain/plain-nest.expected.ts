import * as $Nat from "./nat.ts";

const { add } = $Nat;

export type S = Record<never, never>;

const F$Nested$twice = (n: number): number => add(n, n);

export interface FNestedResult {
  readonly twice: (n: number) => number;
}

export interface FResult {
  readonly Nested: (_Y: S) => FNestedResult;
}

export const F = (_X: S): FResult => {
  const Nested = (_Y: S): FNestedResult => ({ twice: F$Nested$twice });

  return { Nested };
};
