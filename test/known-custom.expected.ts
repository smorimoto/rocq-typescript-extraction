export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });

const matchColour = <R>(
  onRed: () => R,
  onMix: (n: Nat) => R,
  c: { readonly tag: "red" } | { readonly tag: "mix"; readonly n: Nat }
): R => (c.tag === "red" ? onRed() : onMix(c.n));

export const nested = (
  c: { readonly tag: "red" } | { readonly tag: "mix"; readonly n: Nat }
): Nat =>
  matchColour(
    (): Nat => o,
    (_unused: Nat): Nat =>
      matchColour(
        (): Nat => s(s(o)),
        (k: Nat): Nat => k,
        c
      ),
    c
  );

export const ofRed = (
  c: { readonly tag: "red" } | { readonly tag: "mix"; readonly n: Nat }
): Nat =>
  matchColour(
    (): Nat => o,
    (_unused: Nat): Nat => s(s(o)),
    c
  );

const matchBox = <R>(
  onBox: (n: Nat) => R,
  onEmpty: () => R,
  b: { readonly tag: "box"; readonly n: Nat } | { readonly tag: "empty" }
): R => (b.tag === "box" ? onBox(b.n) : onEmpty());

export const onlyBox = (
  b: { readonly tag: "box"; readonly n: Nat } | { readonly tag: "empty" }
): Nat =>
  matchBox(
    (_unused: Nat): Nat =>
      matchBox(
        (k: Nat): Nat => k,
        (): Nat => s(o),
        b
      ),
    (): Nat => o,
    b
  );
