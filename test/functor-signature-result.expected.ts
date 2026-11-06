export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface SIG<T> {
  readonly z: T;
}

export type FT<R> = <T>(X: SIG<T>) => SIG<Kind<R, T>>;

interface ConstResult {
  readonly z: number;
}

const Const = <T>(_X: SIG<T>): ConstResult => {
  const z = 0;

  return { z };
};

interface SameResult<T> {
  readonly z: T;
}

const Same = <T>(X: SIG<T>): SameResult<T> => {
  const z: T = X.z;

  return { z };
};

const A$z: number = s(s(s(s(s(s(s(0)))))));

const A = {
  z: A$z,
} as const;

export type A2T = boolean;

const A2$z = true;

const A2 = {
  z: A2$z,
} as const;

export type UseBT<R, T> = Kind<R, T>;

export type UseB2T<R> = Kind<R, A2T>;

export interface UseResult<R, T> {
  readonly B: SIG<UseBT<R, T>>;
  readonly B2: SIG<UseB2T<R>>;
  readonly z: UseBT<R, T>;
  readonly both: readonly [UseBT<R, T>, UseB2T<R>];
}

export const Use =
  <R, T>(F: FT<R>) =>
  (X: SIG<T>): UseResult<R, T> => {
    const B = F<T>(X);
    const B2 = F<boolean>(A2);
    const z: UseBT<R, T> = B.z;
    const both: readonly [UseBT<R, T>, UseB2T<R>] = pair(B.z, B2.z);

    return { B, B2, both, z };
  };

export type AgainUBT<R, T> = UseBT<R, T>;

export type AgainUB2T<R> = UseB2T<R>;

export interface AgainResult<R, T> {
  readonly U: UseResult<R, T>;
  readonly again: AgainUBT<R, T>;
}

export const Again =
  <R, T>(G: FT<R>) =>
  (X: SIG<T>): AgainResult<R, T> => {
    const U = Use<R, T>(G)(X);
    const again: AgainUBT<R, T> = U.z;

    return { U, again };
  };

export interface ConstTLambda extends TypeLambda {
  readonly type: number;
}

export type U1BT = UseBT<ConstTLambda, number>;

export type U1B2T = UseB2T<ConstTLambda>;

export const U1 = Use<ConstTLambda, number>(Const)(A);

export interface SameTLambda extends TypeLambda {
  readonly type: this["Target"];
}

export type U2BT = UseBT<SameTLambda, number>;

export type U2B2T = UseB2T<SameTLambda>;

export const U2 = Use<SameTLambda, number>(Same)(A);

export const P = <T>(X: SIG<T>): UseResult<SameTLambda, T> =>
  Use<SameTLambda, T>(Same)(X);

export type AGUBT = AgainUBT<SameTLambda, number>;

export type AGUB2T = AgainUB2T<SameTLambda>;

export const AG = Again<SameTLambda, number>(Same)(A);
