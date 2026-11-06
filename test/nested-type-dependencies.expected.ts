const s = (n: number): number => n + 1;

export interface BASE<T> {
  readonly value: T;
}

export interface WRAPPEDEmpty {
  readonly tag: "Empty";
}

export interface WRAPPEDWrapped<BaseT> {
  readonly tag: "Wrapped";
  readonly value: BaseT;
}

export type WRAPPEDWrapper<BaseT> = WRAPPEDEmpty | WRAPPEDWrapped<BaseT>;

export interface WRAPPED<BaseT> {
  readonly Base: BASE<BaseT>;
}

export interface UseNoResult {
  readonly tag: "NoResult";
}

export interface UseResult1<BaseT> {
  readonly tag: "Result";
  readonly value: WRAPPEDWrapper<BaseT>;
}

export type UseResult0<BaseT> = UseNoResult | UseResult1<BaseT>;

export interface UseResult<BaseT> {
  readonly noResult: UseNoResult;
  readonly result: (value: WRAPPEDWrapper<BaseT>) => UseResult0<BaseT>;
  readonly resultRect: <A>(
    noResult0: A,
    result0: (_: WRAPPEDWrapper<BaseT>) => A,
    r: UseResult0<BaseT>
  ) => A;
  readonly resultRec: <A>(
    noResult0: A,
    result0: (_: WRAPPEDWrapper<BaseT>) => A,
    r: UseResult0<BaseT>
  ) => A;
  readonly read: (_unused: number) => BaseT;
}

export const Use = <BaseT>(W: WRAPPED<BaseT>): UseResult<BaseT> => {
  const noResult: UseNoResult = { tag: "NoResult" };

  const result = (value: WRAPPEDWrapper<BaseT>): UseResult0<BaseT> => ({
    tag: "Result",
    value,
  });

  const resultRect = <A>(
    noResult0: A,
    result0: (_: WRAPPEDWrapper<BaseT>) => A,
    r: UseResult0<BaseT>
  ): A => {
    switch (r.tag) {
      case "NoResult": {
        return noResult0;
      }

      case "Result": {
        return result0(r.value);
      }

      default: {
        return r satisfies never;
      }
    }
  };

  const resultRec = <A>(
    noResult0: A,
    result0: (_: WRAPPEDWrapper<BaseT>) => A,
    r: UseResult0<BaseT>
  ): A => {
    switch (r.tag) {
      case "NoResult": {
        return noResult0;
      }

      case "Result": {
        return result0(r.value);
      }

      default: {
        return r satisfies never;
      }
    }
  };

  const read = (_unused: number): BaseT => W.Base.value;

  return { noResult, read, result, resultRec, resultRect };
};

export type ValuesBaseT = number;

const Values$Base$value: number = s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))));

export interface ValuesEmpty {
  readonly tag: "Empty";
}

export interface ValuesWrapped {
  readonly tag: "Wrapped";
  readonly value: ValuesBaseT;
}

export type ValuesWrapper = ValuesEmpty | ValuesWrapped;

const Values$empty: ValuesEmpty = { tag: "Empty" };

const Values$wrapped = (value: ValuesBaseT): ValuesWrapper => ({
  tag: "Wrapped",
  value,
});

const Values$wrapperRect = <A>(
  empty: A,
  wrapped: (_: number) => A,
  w: ValuesWrapper
): A => {
  switch (w.tag) {
    case "Empty": {
      return empty;
    }

    case "Wrapped": {
      return wrapped(w.value);
    }

    default: {
      return w satisfies never;
    }
  }
};

const Values$wrapperRec = <A>(
  empty: A,
  wrapped: (_: number) => A,
  w: ValuesWrapper
): A => {
  switch (w.tag) {
    case "Empty": {
      return empty;
    }

    case "Wrapped": {
      return wrapped(w.value);
    }

    default: {
      return w satisfies never;
    }
  }
};

export const Values = {
  Base: {
    value: Values$Base$value,
  },
  empty: Values$empty,
  wrapped: Values$wrapped,
  wrapperRec: Values$wrapperRec,
  wrapperRect: Values$wrapperRect,
} as const;

export type AppliedNoResult = UseNoResult;

export type AppliedResult0 = UseResult1<number>;

export type AppliedResult = UseResult0<number>;

export const Applied = Use<number>(Values);
