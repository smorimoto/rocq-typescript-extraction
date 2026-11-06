export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

export interface MAP<T> {
  readonly empty: <A>() => Kind<T, A>;
  readonly set1: <A>(_0: number, _1: A, _2: Kind<T, A>) => Kind<T, A>;
}
