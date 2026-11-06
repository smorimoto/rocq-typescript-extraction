export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

const s = (n: number): number => n + 1;

export interface SIG<T> {
  readonly z: T;
}

export interface FTResult<R> {
  readonly z: R;
}

export type FT<R> = <T>(X: SIG<T>) => FTResult<Kind<R, T>>;

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

const A$z: number = s(s(s(s(0))));

const A = {
  z: A$z,
} as const;

export type UseBT<R, T> = Kind<R, T>;

export interface UseResult<R, T> {
  readonly B: FTResult<UseBT<R, T>>;
  readonly z: UseBT<R, T>;
}

export const Use =
  <R, T>(F: FT<R>) =>
  (X: SIG<T>): UseResult<R, T> => {
    const B = F<T>(X);
    const z: UseBT<R, T> = B.z;

    return { B, z };
  };

export interface ConstTLambda extends TypeLambda {
  readonly type: number;
}

export type U1BT = UseBT<ConstTLambda, number>;

export const U1 = Use<ConstTLambda, number>(Const)(A);

export interface SameTLambda extends TypeLambda {
  readonly type: this["Target"];
}

export type U2BT = UseBT<SameTLambda, number>;

export const U2 = Use<SameTLambda, number>(Same)(A);
