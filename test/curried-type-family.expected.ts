const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

const andb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a && b;

const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

export interface Nil {
  readonly tag: "Nil";
}

export interface Cons<A> {
  readonly tag: "Cons";
  readonly arg0: A;
  readonly arg1: List<A>;
}

export type List<A> = Nil | Cons<A>;

export const nil: Nil = { tag: "Nil" };

export const cons = <A>(arg0: A, arg1: List<A>): List<A> => ({
  arg0,
  arg1,
  tag: "Cons",
});

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const eqb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n === m;

export type Arrows<X> = ((_: never) => Arrows<X>) | X;

export const keepAction = <A>(
  _unused: List<undefined>,
  action: Arrows<A>
): Arrows<A> => action;

export const select = (flag: boolean): Arrows<number> =>
  flag
    ? __magic<(_: number) => number, Arrows<number>>((n: number): number => n)
    : __magic<(_: boolean) => (_: number) => number, Arrows<number>>(
        (enabled: boolean) =>
          (n: number): number =>
            enabled ? n : 0
      );

export const selected: number = __magic<
  Arrows<number>,
  (_: boolean) => (_: number) => number
>(select(false))(true)(s(s(s(s(s(s(s(0))))))));

export const runNumber = (enabled: boolean, n: number): number =>
  __magic<
    Arrows<(_: boolean) => (_: number) => (_: never) => number>,
    (_: boolean) => (_: number) => (_: undefined) => number
  >(
    keepAction<(_: boolean) => (_: number) => (_: never) => number>(
      cons<undefined>(
        undefined,
        cons<undefined>(undefined, cons<undefined>(undefined, nil))
      ),
      __magic<
        (_: boolean) => (_: number) => (_: never) => number,
        Arrows<(_: boolean) => (_: number) => (_: never) => number>
      >(
        (enabled0: boolean) => (n0: number) => (): number =>
          enabled0 ? add(n0, s(s(0))) : 0
      )
    )
  )(enabled)(n)(undefined);

export const runFlag = (n: number, enabled: boolean): boolean =>
  __magic<
    Arrows<(_: number) => (_: boolean) => boolean>,
    (_: number) => (_: boolean) => boolean
  >(
    keepAction<(_: number) => (_: boolean) => boolean>(
      cons<undefined>(undefined, cons<undefined>(undefined, nil)),
      __magic<
        (_: number) => (_: boolean) => boolean,
        Arrows<(_: number) => (_: boolean) => boolean>
      >(
        (n0: number) =>
          (enabled0: boolean): boolean =>
            andb(enabled0, eqb(n0, s(s(s(s(0))))))
      )
    )
  )(n)(enabled);

export const noInputs: boolean = __magic<Arrows<boolean>, boolean>(
  keepAction(nil, true)
);

export const useConsumer = (
  _unused: List<undefined>,
  consume: <A>(_: Arrows<A>) => A,
  action: Arrows<number>
): number => __magic<Arrows<number>, number>(consume(action));

export const higherRankResult = (n: number): number =>
  useConsumer(nil, <A>(value: Arrows<A>): A => __magic<Arrows<A>, A>(value), n);

export const functionAction = (
  empty: boolean
): Arrows<(_: number) => boolean> =>
  empty
    ? __magic<(_: number) => boolean, Arrows<(_: number) => boolean>>(
        (n: number): boolean => eqb(n, s(s(s(s(s(s(0)))))))
      )
    : __magic<
        (_: boolean) => (_: number) => boolean,
        Arrows<(_: number) => boolean>
      >(
        (enabled: boolean) =>
          (n: number): boolean =>
            andb(enabled, eqb(n, s(s(s(s(s(s(0))))))))
      );

export const functionResult = (
  empty: boolean,
  enabled: boolean,
  n: number
): boolean =>
  empty
    ? __magic<Arrows<(_: number) => boolean>, (_: number) => boolean>(
        functionAction(true)
      )(n)
    : __magic<
        Arrows<(_: number) => boolean>,
        (_: boolean) => (_: number) => boolean
      >(functionAction(false))(enabled)(n);

export const keepFunction = <A, B>(
  _unused: List<undefined>,
  action: Arrows<(_: A) => B>,
  _unused0: A
): Arrows<(_: A) => B> => action;

export const functionSeed = (n: number): boolean =>
  __magic<
    Arrows<(_: number) => boolean>,
    (_: boolean) => (_: number) => boolean
  >(
    keepFunction<number, boolean>(
      cons<undefined>(undefined, nil),
      __magic<
        (_: boolean) => (_: number) => boolean,
        Arrows<(_: number) => boolean>
      >(
        (flag: boolean) =>
          (count: number): boolean =>
            flag ? eqb(count, n) : false
      ),
      0
    )
  )(true)(s(s(s(0))));

export const keepTwo = <A>(
  _unused: List<undefined>,
  _unused0: List<undefined>,
  action: Arrows<A>,
  _unused1: Arrows<A>
): Arrows<A> => action;

export const twoActions = (n: number): number =>
  __magic<
    Arrows<((_: boolean) => (_: number) => number) | ((_: number) => number)>,
    (_: number) => number
  >(
    keepTwo<((_: boolean) => (_: number) => number) | ((_: number) => number)>(
      cons<undefined>(undefined, nil),
      cons<undefined>(undefined, cons<undefined>(undefined, nil)),
      __magic<
        (_: number) => number,
        Arrows<
          ((_: boolean) => (_: number) => number) | ((_: number) => number)
        >
      >((count: number): number => add(count, n)),
      __magic<
        (_: boolean) => (_: number) => number,
        Arrows<
          ((_: boolean) => (_: number) => number) | ((_: number) => number)
        >
      >(
        (flag: boolean) =>
          (count: number): number =>
            flag ? count : n
      )
    )
  )(s(s(s(0))));

export type Callbacks<Result> =
  | ((_: (_: number) => never) => Callbacks<Result>)
  | Result;

export const keepCallbacks = <A>(
  _unused: List<undefined>,
  action: Callbacks<A>
): Callbacks<A> => action;

export const callbackResult = (enabled: boolean, n: number): number =>
  __magic<
    Callbacks<
      (_: (_: number) => boolean) => (_: (_: number) => number) => number
    >,
    (_: (_: never) => boolean) => (_: (_: number) => number) => number
  >(
    keepCallbacks<
      (_: (_: number) => boolean) => (_: (_: number) => number) => number
    >(
      cons<undefined>(undefined, cons<undefined>(undefined, nil)),
      __magic<
        (_: (_: number) => boolean) => (_: (_: number) => number) => number,
        Callbacks<
          (_: (_: number) => boolean) => (_: (_: number) => number) => number
        >
      >(
        (flag: (_: number) => boolean) =>
          (count: (_: number) => number): number =>
            flag(0) ? count(s(s(0))) : 0
      )
    )
  )((): boolean => enabled)((offset: number): number => add(n, offset));

export type PairedArrows<Left, Right> =
  | ((_: never) => PairedArrows<Left, Right>)
  | readonly [Left, Right];

export const keepPair = <A, B>(
  _unused: List<undefined>,
  action: PairedArrows<A, B>
): PairedArrows<A, B> => action;

export const pairedResult = (
  enabled: boolean,
  n: number
): readonly [number, boolean] =>
  __magic<
    PairedArrows<number, never>,
    (_: boolean) => (_: number) => readonly [number, boolean]
  >(
    keepPair<number, never>(
      cons<undefined>(undefined, cons<undefined>(undefined, nil)),
      __magic<
        (_: never) => (_: number) => readonly [number, never],
        PairedArrows<number, never>
      >(
        (enabled0: never) =>
          (n0: number): readonly [number, never] =>
            pair(add(n0, s(0)), enabled0)
      )
    )
  )(enabled)(n);

export interface Grammar<Semantic, Production> {
  readonly action: (_0: Production) => Arrows<Semantic>;
}

export interface UseResult<Semantic, Production> {
  readonly get0: (x: Production) => Arrows<Semantic>;
}

export const Use = <Semantic, Production>(
  G: Grammar<Semantic, Production>
): UseResult<Semantic, Production> => {
  const get0 = (x: Production): Arrows<Semantic> => G.action(x);

  return { get0 };
};

export interface SampleCount {
  readonly tag: "Count";
}

export interface SampleFlag {
  readonly tag: "Flag";
}

export interface SampleEmpty {
  readonly tag: "Empty";
}

export type SampleSymbolKind = SampleCount | SampleFlag | SampleEmpty;

const Sample$count: SampleCount = { tag: "Count" };
const Sample$flag: SampleFlag = { tag: "Flag" };
const Sample$empty: SampleEmpty = { tag: "Empty" };

const Sample$symbolKindRect = <A>(
  count: A,
  flag: A,
  empty: A,
  s0: SampleSymbolKind
): A => {
  switch (s0.tag) {
    case "Count": {
      return count;
    }

    case "Flag": {
      return flag;
    }

    case "Empty": {
      return empty;
    }

    default: {
      return s0 satisfies never;
    }
  }
};

const Sample$symbolKindRec = <A>(
  count: A,
  flag: A,
  empty: A,
  s0: SampleSymbolKind
): A => {
  switch (s0.tag) {
    case "Count": {
      return count;
    }

    case "Flag": {
      return flag;
    }

    case "Empty": {
      return empty;
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export type SampleSemantic = boolean | number | undefined;

export interface SampleCountRule {
  readonly tag: "CountRule";
}

export interface SampleFlagRule {
  readonly tag: "FlagRule";
}

export interface SampleEmptyRule {
  readonly tag: "EmptyRule";
}

export type SampleRule = SampleCountRule | SampleFlagRule | SampleEmptyRule;

const Sample$countRule: SampleCountRule = { tag: "CountRule" };
const Sample$flagRule: SampleFlagRule = { tag: "FlagRule" };
const Sample$emptyRule: SampleEmptyRule = { tag: "EmptyRule" };

const Sample$ruleRect = <A>(
  countRule: A,
  flagRule: A,
  emptyRule: A,
  r: SampleRule
): A => {
  switch (r.tag) {
    case "CountRule": {
      return countRule;
    }

    case "FlagRule": {
      return flagRule;
    }

    case "EmptyRule": {
      return emptyRule;
    }

    default: {
      return r satisfies never;
    }
  }
};

const Sample$ruleRec = <A>(
  countRule: A,
  flagRule: A,
  emptyRule: A,
  r: SampleRule
): A => {
  switch (r.tag) {
    case "CountRule": {
      return countRule;
    }

    case "FlagRule": {
      return flagRule;
    }

    case "EmptyRule": {
      return emptyRule;
    }

    default: {
      return r satisfies never;
    }
  }
};

const Sample$result = (p: SampleRule): SampleSymbolKind => {
  switch (p.tag) {
    case "CountRule": {
      return Sample$count;
    }

    case "FlagRule": {
      return Sample$flag;
    }

    case "EmptyRule": {
      return Sample$empty;
    }

    default: {
      return p satisfies never;
    }
  }
};

const Sample$inputs = (p: SampleRule): List<SampleSymbolKind> => {
  switch (p.tag) {
    case "CountRule": {
      return cons<SampleSymbolKind>(
        Sample$flag,
        cons<SampleSymbolKind>(
          Sample$count,
          cons<SampleSymbolKind>(Sample$empty, nil)
        )
      );
    }

    case "FlagRule": {
      return cons<SampleSymbolKind>(
        Sample$count,
        cons<SampleSymbolKind>(Sample$flag, nil)
      );
    }

    case "EmptyRule": {
      return nil;
    }

    default: {
      return p satisfies never;
    }
  }
};

const Sample$action = (p: SampleRule): Arrows<SampleSemantic> => {
  switch (p.tag) {
    case "CountRule": {
      return __magic<
        (_: boolean) => (_: number) => (_: never) => number,
        Arrows<SampleSemantic>
      >(
        (enabled: boolean) => (n: number) => (): number =>
          enabled ? add(n, s(s(s(0)))) : 0
      );
    }

    case "FlagRule": {
      return __magic<
        (_: number) => (_: boolean) => boolean,
        Arrows<SampleSemantic>
      >(
        (n: number) =>
          (enabled: boolean): boolean =>
            andb(enabled, eqb(n, s(s(s(s(0))))))
      );
    }

    case "EmptyRule": {
      return __magic<undefined, Arrows<SampleSemantic>>(undefined);
    }

    default: {
      return p satisfies never;
    }
  }
};

export const Sample = {
  action: Sample$action,
  count: Sample$count,
  countRule: Sample$countRule,
  empty: Sample$empty,
  emptyRule: Sample$emptyRule,
  flag: Sample$flag,
  flagRule: Sample$flagRule,
  inputs: Sample$inputs,
  result: Sample$result,
  ruleRec: Sample$ruleRec,
  ruleRect: Sample$ruleRect,
  symbolKindRec: Sample$symbolKindRec,
  symbolKindRect: Sample$symbolKindRect,
} as const;

export const Applied = Use<SampleSemantic, SampleRule>(Sample);

export const grammarNumber = (enabled: boolean, n: number): number =>
  __magic<
    Arrows<SampleSemantic>,
    (_: boolean) => (_: number) => (_: undefined) => number
  >(Applied.get0(Sample$countRule))(enabled)(n)(undefined);

export const grammarFlag = (n: number, enabled: boolean): boolean =>
  __magic<Arrows<SampleSemantic>, (_: number) => (_: boolean) => boolean>(
    Applied.get0(Sample$flagRule)
  )(n)(enabled);

export const grammarEmpty: undefined = __magic<
  Arrows<SampleSemantic>,
  undefined
>(Applied.get0(Sample$emptyRule));
