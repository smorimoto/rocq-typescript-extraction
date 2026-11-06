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

export type FT<R> = <T>(X: SIG<T>) => SIG<Kind<R, T>>;

export interface WrapC<T> {
  readonly tag: "C";
  readonly x: T;
}

export interface WrapStop {
  readonly tag: "Stop";
}

export type WrapRaw<T> = WrapC<T> | WrapStop;

export type WrapT<T> = WrapRaw<T>;

export interface WrapResult<T> {
  readonly c: (x: T) => WrapRaw<T>;
  readonly stop: WrapStop;
  readonly rawRect: <A>(c0: (_: T) => A, stop0: A, r: WrapRaw<T>) => A;
  readonly rawRec: <A>(c0: (_: T) => A, stop0: A, r: WrapRaw<T>) => A;
  readonly z: WrapRaw<T>;
  readonly make: (x: T) => WrapRaw<T>;
}

export const Wrap = <T>(_X: SIG<T>): WrapResult<T> => {
  const c = (x: T): WrapRaw<T> => ({ tag: "C", x });
  const stop: WrapStop = { tag: "Stop" };

  const rawRect = <A>(c0: (_: T) => A, stop0: A, r: WrapRaw<T>): A => {
    switch (r.tag) {
      case "C": {
        return c0(r.x);
      }

      case "Stop": {
        return stop0;
      }

      default: {
        return r satisfies never;
      }
    }
  };

  const rawRec = <A>(c0: (_: T) => A, stop0: A, r: WrapRaw<T>): A => {
    switch (r.tag) {
      case "C": {
        return c0(r.x);
      }

      case "Stop": {
        return stop0;
      }

      default: {
        return r satisfies never;
      }
    }
  };

  const z: WrapRaw<T> = stop;
  const make = (x: T): WrapRaw<T> => c(x);

  return { c, make, rawRec, rawRect, stop, z };
};

const A$z: number = s(0);

const A = {
  z: A$z,
} as const;

export type UseBT<R, T> = Kind<R, T>;

export interface UseResult<R, T> {
  readonly B: SIG<UseBT<R, T>>;
  readonly z: UseBT<R, T>;
}

export const Use =
  <R, T>(F: FT<R>) =>
  (X: SIG<T>): UseResult<R, T> => {
    const B = F<T>(X);
    const z: UseBT<R, T> = B.z;

    return { B, z };
  };

export interface WrapTLambda extends TypeLambda {
  readonly type: WrapRaw<this["Target"]>;
}

export type UBT = UseBT<WrapTLambda, number>;

export const U = Use<WrapTLambda, number>(Wrap)(A);
