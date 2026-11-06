export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

export interface C1<T> {
  readonly empty: <A>() => Kind<T, A>;
  readonly map: <A, B>(_0: (_: A) => B, _1: Kind<T, A>) => Kind<T, B>;
}

export interface UseResult<T> {
  readonly b: Kind<T, boolean>;
}

export const Use = <T>(C: C1<T>): UseResult<T> => {
  const { map } = C;
  const b: Kind<T, boolean> = map((): boolean => true, C.empty<never>());

  return { b };
};

export const plain = (f: (_: number) => boolean): ((_: number) => boolean) => f;
export const gone: boolean = plain((_unused: number): boolean => true)(0);
