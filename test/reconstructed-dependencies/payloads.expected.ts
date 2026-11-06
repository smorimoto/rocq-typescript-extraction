import type * as $Datatypes from "./datatypes.ts";

const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

export type Payload<B extends boolean> = B extends true
  ? bigint
  : $Datatypes.EmptySet;

export const read = <B extends boolean>(b: B, x: Payload<B>): bigint =>
  b ? __magic<Payload<B>, bigint>(x) : __fail("absurd case");

export interface Numbered {
  readonly tag: "Numbered";
  readonly n: bigint;
}

export interface Unnumbered {
  readonly tag: "Unnumbered";
}

export type Token = Numbered | Unnumbered;

export const numbered = (n: bigint): Token => ({ n, tag: "Numbered" });
export const unnumbered: Unnumbered = { tag: "Unnumbered" };

export interface Parcel0<B extends boolean> {
  readonly tag: "Parcel";
  readonly b: B;
  readonly x: B extends true ? Token : $Datatypes.EmptySet;
}

export type Parcel = Parcel0<true> | Parcel0<false>;

export const parcel = <B extends boolean>(
  b: B,
  x: B extends true ? Token : $Datatypes.EmptySet
): Parcel0<B> => ({ b, tag: "Parcel", x });

export type Choice<B extends boolean> = B extends true
  ? Parcel
  : $Datatypes.EmptySet;

export const inspect = <B extends boolean>(b: B, _unused: Choice<B>): B => b;

export type Mapped<B extends boolean> = B extends true
  ? boolean
  : $Datatypes.EmptySet;

export const mappedRead = <B extends boolean>(b: B, x: Mapped<B>): boolean => {
  if (b) {
    const s0: boolean = __magic<Mapped<B>, boolean>(x);

    switch (s0) {
      case true: {
        return true;
      }

      default: {
        return false;
      }
    }
  }

  return __fail("absurd case");
};

export interface SecretValue {
  readonly tag: "SecretValue";
  readonly n: bigint;
}

export interface NoSecret {
  readonly tag: "NoSecret";
}

export type Secret = SecretValue | NoSecret;

export const secretValue = (n: bigint): Secret => ({ n, tag: "SecretValue" });
export const noSecret: NoSecret = { tag: "NoSecret" };

export interface READER {
  readonly readSecret: <B extends boolean>(
    _0: B,
    _1: B extends true ? Secret : $Datatypes.EmptySet
  ) => boolean;
}

export interface UseResult {
  readonly ready: (x: Secret) => boolean;
}

export const Use = (R: READER): UseResult => {
  const ready = (x: Secret): boolean => R.readSecret(true, x);

  return { ready };
};
