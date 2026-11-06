export interface LAT<T> {
  readonly bot: T;
  readonly lub: (_0: T, _1: T) => T;
}

export interface SOLVER<LT> {
  readonly L: LAT<LT>;
  readonly run: (_0: number) => LT;
}
