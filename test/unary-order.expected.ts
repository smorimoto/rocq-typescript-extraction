const __unaryConstructor = <T extends object>(
  __unaryBuild: (__unaryChild: T) => T
): ((__unaryChild: T) => T) => {
  const __unarySuccessors = new WeakMap<T, WeakRef<T>>();

  return (__unaryChild: T): T => {
    const __unaryExisting = __unarySuccessors.get(__unaryChild)?.deref();

    if (__unaryExisting !== undefined) {
      return __unaryExisting;
    }

    const __unaryValue = Object.freeze(__unaryBuild(__unaryChild));
    __unarySuccessors.set(__unaryChild, new WeakRef(__unaryValue));

    return __unaryValue;
  };
};

/* oxlint-disable anti-slop/no-runtime-typeof -- Numbers mark complete entries. */
const __unaryOrder = <T extends object, R extends object>(
  __unaryTag: string,
  __unaryZero: string,
  __unarySuccessor: string,
  __unaryField: string,
  __unaryChild: (value: T) => T | undefined,
  __unaryYes: R,
  __unaryNo: R,
  __unaryFallback: (__unaryLeft: T, __unaryRight: T) => R
): ((__unaryLeft: T, __unaryRight: T) => R) => {
  interface __UnaryPrefix {
    readonly depth: number;
    readonly rest: T;
  }

  const __unaryPrefixes = new WeakMap<T, number | __UnaryPrefix>();

  const __unarySave = (
    __unaryRoot: T,
    __unaryDepth: number,
    __unaryRest: T | undefined
  ): void => {
    if (__unaryDepth === 0 && __unaryRest !== undefined) {
      return;
    }

    const __unaryPrevious = __unaryPrefixes.get(__unaryRoot);

    if (
      typeof __unaryPrevious === "number" ||
      (__unaryPrevious !== undefined &&
        __unaryPrevious.depth >= __unaryDepth &&
        __unaryRest !== undefined)
    ) {
      return;
    }

    __unaryPrefixes.set(
      __unaryRoot,
      __unaryRest === undefined
        ? __unaryDepth
        : { depth: __unaryDepth, rest: __unaryRest }
    );

    if (__unaryDepth === 0) {
      return;
    }

    const __unaryFirst = __unaryChild(__unaryRoot);

    if (__unaryFirst === undefined) {
      return;
    }

    const __unaryPreviousFirst = __unaryPrefixes.get(__unaryFirst);

    if (
      __unaryPreviousFirst === undefined ||
      (typeof __unaryPreviousFirst !== "number" &&
        (__unaryPreviousFirst.depth < __unaryDepth - 1 ||
          __unaryRest === undefined))
    ) {
      __unaryPrefixes.set(
        __unaryFirst,
        __unaryRest === undefined
          ? __unaryDepth - 1
          : { depth: __unaryDepth - 1, rest: __unaryRest }
      );
    }
  };

  const __unaryDecide = (
    __unaryLeftDepth: number,
    __unaryLeftRest: T | undefined,
    __unaryRightDepth: number,
    __unaryRightRest: T | undefined
  ): R | undefined => {
    if (
      __unaryLeftRest === undefined &&
      __unaryRightDepth >= __unaryLeftDepth
    ) {
      return __unaryYes;
    }

    if (
      __unaryRightRest === undefined &&
      __unaryLeftDepth > __unaryRightDepth
    ) {
      return __unaryNo;
    }

    return undefined;
  };

  const __unaryStep = (
    __unaryCurrent: T | undefined
  ): T | undefined | false => {
    if (__unaryCurrent === undefined) {
      return false;
    }

    const __unaryKind = Object.getOwnPropertyDescriptor(
      __unaryCurrent,
      __unaryTag
    );

    if (
      __unaryKind === undefined ||
      !Object.hasOwn(__unaryKind, "value") ||
      __unaryKind.writable !== false ||
      __unaryKind.configurable !== false
    ) {
      return false;
    }

    if (__unaryKind.value === __unaryZero) {
      return undefined;
    }

    if (__unaryKind.value !== __unarySuccessor) {
      return false;
    }

    const __unaryNext = Object.getOwnPropertyDescriptor(
      __unaryCurrent,
      __unaryField
    );

    if (
      __unaryNext === undefined ||
      !Object.hasOwn(__unaryNext, "value") ||
      __unaryNext.writable !== false ||
      __unaryNext.configurable !== false
    ) {
      return false;
    }

    const __unaryValue = __unaryChild(__unaryCurrent);

    if (Object(__unaryValue) !== __unaryValue) {
      return false;
    }

    return __unaryValue;
  };

  const __unarySlow = (
    __unaryLeft: T,
    __unaryRight: T,
    __unaryLeftPrefix: number | __UnaryPrefix | undefined,
    __unaryRightPrefix: number | __UnaryPrefix | undefined
  ): R => {
    let __unaryLeftDepth = 0;
    let __unaryRightDepth = 0;
    let __unaryLeftRest: T | undefined = __unaryLeft;
    let __unaryRightRest: T | undefined = __unaryRight;

    if (typeof __unaryLeftPrefix === "number") {
      __unaryLeftDepth = __unaryLeftPrefix;
      __unaryLeftRest = undefined;
    } else if (__unaryLeftPrefix !== undefined) {
      __unaryLeftDepth = __unaryLeftPrefix.depth;
      __unaryLeftRest = __unaryLeftPrefix.rest;
    }

    if (typeof __unaryRightPrefix === "number") {
      __unaryRightDepth = __unaryRightPrefix;
      __unaryRightRest = undefined;
    } else if (__unaryRightPrefix !== undefined) {
      __unaryRightDepth = __unaryRightPrefix.depth;
      __unaryRightRest = __unaryRightPrefix.rest;
    }

    const __unaryKnown = __unaryDecide(
      __unaryLeftDepth,
      __unaryLeftRest,
      __unaryRightDepth,
      __unaryRightRest
    );

    if (__unaryKnown !== undefined) {
      return __unaryKnown;
    }

    let __unaryAnswer: R | undefined;

    for (;;) {
      __unaryAnswer = __unaryDecide(
        __unaryLeftDepth,
        __unaryLeftRest,
        __unaryRightDepth,
        __unaryRightRest
      );

      if (__unaryAnswer !== undefined) {
        break;
      }

      const __unaryAdvanceLeft =
        __unaryRightRest === undefined ||
        (__unaryLeftRest !== undefined &&
          __unaryLeftDepth <= __unaryRightDepth);

      const __unaryCurrent = __unaryAdvanceLeft
        ? __unaryLeftRest
        : __unaryRightRest;

      const __unaryDepth = __unaryAdvanceLeft
        ? __unaryLeftDepth
        : __unaryRightDepth;

      const __unaryNext = __unaryStep(__unaryCurrent);

      if (__unaryNext === false) {
        break;
      }

      let __unaryNextDepth = __unaryDepth;
      let __unaryNextRest: T | undefined;

      if (__unaryNext === undefined) {
        __unaryNextRest = undefined;
      } else {
        const __unarySuffix = __unaryPrefixes.get(__unaryNext);
        __unaryNextDepth = __unaryDepth + 1;
        __unaryNextRest = __unaryNext;

        if (typeof __unarySuffix === "number") {
          __unaryNextDepth += __unarySuffix;
          __unaryNextRest = undefined;
        } else if (__unarySuffix !== undefined) {
          __unaryNextDepth += __unarySuffix.depth;
          __unaryNextRest = __unarySuffix.rest;
        }

        if (!Number.isSafeInteger(__unaryNextDepth)) {
          break;
        }
      }

      if (__unaryAdvanceLeft) {
        __unaryLeftDepth = __unaryNextDepth;
        __unaryLeftRest = __unaryNextRest;
      } else {
        __unaryRightDepth = __unaryNextDepth;
        __unaryRightRest = __unaryNextRest;
      }
    }

    __unarySave(__unaryLeft, __unaryLeftDepth, __unaryLeftRest);
    __unarySave(__unaryRight, __unaryRightDepth, __unaryRightRest);

    return __unaryAnswer ?? __unaryFallback(__unaryLeft, __unaryRight);
  };

  return (__unaryLeft: T, __unaryRight: T): R => {
    const __unaryLeftPrefix = __unaryPrefixes.get(__unaryLeft);
    const __unaryRightPrefix = __unaryPrefixes.get(__unaryRight);

    if (
      typeof __unaryLeftPrefix === "number" &&
      typeof __unaryRightPrefix === "number"
    ) {
      return __unaryLeftPrefix <= __unaryRightPrefix ? __unaryYes : __unaryNo;
    }

    return __unarySlow(
      __unaryLeft,
      __unaryRight,
      __unaryLeftPrefix,
      __unaryRightPrefix
    );
  };
};
/* oxlint-enable anti-slop/no-runtime-typeof */

const __readCell = <T>(cells: readonly (readonly [T])[], index: number): T => {
  const cell = cells[index];

  if (cell === undefined) {
    throw new Error("Invalid continuation stack access");
  }

  return cell[0];
};

const __writeCell = <T>(cells: [T][], index: number, value: T): void => {
  const cell = cells[index];

  if (cell === undefined) {
    cells[index] = [value];
  } else {
    cell[0] = value;
  }
};

export interface True {
  readonly tag: "True";
}

export interface False {
  readonly tag: "False";
}

export type Bool = True | False;

export const true0: True = { tag: "True" };
export const false0: False = { tag: "False" };

export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = Object.freeze({ tag: "O" });

export const s: (arg0: Nat) => Nat = __unaryConstructor<Nat>(
  (arg0: Nat): Nat => ({ arg0, tag: "S" })
);

export const leb: (n: Nat, m: Nat) => Bool = __unaryOrder<Nat, Bool>(
  "tag",
  "O",
  "S",
  "arg0",
  (__unaryValue: Nat): Nat | undefined =>
    __unaryValue.tag === "S" ? __unaryValue.arg0 : undefined,
  true0,
  false0,
  (n: Nat, m: Nat): Bool => {
    let n0 = n;
    let m0 = m;

    for (;;) {
      switch (n0.tag) {
        case "O": {
          return true0;
        }

        case "S": {
          switch (m0.tag) {
            case "O": {
              return false0;
            }

            case "S": {
              n0 = n0.arg0;
              m0 = m0.arg0;
              continue;
            }

            default: {
              return m0 satisfies never;
            }
          }
        }

        default: {
          return n0 satisfies never;
        }
      }
    }
  }
);

export const ltb = (n: Nat, m: Nat): Bool => {
  switch (m.tag) {
    case "O": {
      return false0;
    }

    case "S": {
      return leb(n, m.arg0);
    }

    default: {
      return m satisfies never;
    }
  }
};

export interface Tick {
  readonly tag: "Tick";
  readonly previous: Counter;
}

export interface Origin {
  readonly tag: "Origin";
}

export type Counter = Tick | Origin;

export const tick: (previous: Counter) => Counter = __unaryConstructor<Counter>(
  (previous: Counter): Counter => ({ previous, tag: "Tick" })
);

export const origin: Origin = Object.freeze({ tag: "Origin" });

export interface Within {
  readonly tag: "Within";
}

export interface Beyond {
  readonly tag: "Beyond";
}

export type Verdict = Within | Beyond;

export const within0: Within = { tag: "Within" };
export const beyond: Beyond = { tag: "Beyond" };

export const within: (left: Counter, right: Counter) => Verdict = __unaryOrder<
  Counter,
  Verdict
>(
  "tag",
  "Origin",
  "Tick",
  "previous",
  (__unaryValue: Counter): Counter | undefined =>
    __unaryValue.tag === "Tick" ? __unaryValue.previous : undefined,
  within0,
  beyond,
  (left: Counter, right: Counter): Verdict => {
    let left0 = left;
    let right0 = right;

    for (;;) {
      switch (left0.tag) {
        case "Tick": {
          switch (right0.tag) {
            case "Tick": {
              left0 = left0.previous;
              right0 = right0.previous;
              continue;
            }

            case "Origin": {
              return beyond;
            }

            default: {
              return right0 satisfies never;
            }
          }
        }

        case "Origin": {
          return within0;
        }

        default: {
          return left0 satisfies never;
        }
      }
    }
  }
);

export const strictlyWithin = (left: Counter, right: Counter): Verdict => {
  switch (right.tag) {
    case "Tick": {
      return within(left, right.previous);
    }

    case "Origin": {
      return beyond;
    }

    default: {
      return right satisfies never;
    }
  }
};

export const customWithin: (_0: Counter, _1: Counter) => Verdict = (
  _left,
  _right
) => ({ tag: "Beyond" });

export const strictlyCustom = (left: Counter, right: Counter): Verdict =>
  customWithin(tick(left), right);

const customTick: (_0: Counter) => Counter = (previous) => ({
  previous,
  tag: "Tick",
});

export const customSuccessor = (left: Counter, right: Counter): Verdict =>
  within(customTick(left), right);

export const withinAlias = (x: Counter, x0: Counter): Verdict => within(x, x0);

export const equalCounter = (left: Counter, right: Counter): Bool => {
  let left0 = left;
  let right0 = right;

  for (;;) {
    switch (left0.tag) {
      case "Tick": {
        switch (right0.tag) {
          case "Tick": {
            left0 = left0.previous;
            right0 = right0.previous;
            continue;
          }

          case "Origin": {
            return false0;
          }

          default: {
            return right0 satisfies never;
          }
        }
      }

      case "Origin": {
        switch (right0.tag) {
          case "Tick": {
            return false0;
          }

          case "Origin": {
            return true0;
          }

          default: {
            return right0 satisfies never;
          }
        }
      }

      default: {
        return left0 satisfies never;
      }
    }
  }
};

export const successorEqual = (left: Counter, right: Counter): Bool =>
  equalCounter(tick(left), right);

export const twiceWithin = (left: Counter, right: Counter): Verdict =>
  within(tick(tick(left)), right);

export const swappedWithin = (left: Counter, right: Counter): Verdict =>
  within(tick(right), left);

export const unaryOrder: Counter = origin;
export const unaryRanks: Counter = tick(origin);

export interface Empty {
  readonly tag: "Empty";
}

export interface More {
  readonly tag: "More";
  readonly prior: Plain;
}

export type Plain = Empty | More;

export const empty: Empty = { tag: "Empty" };
export const more = (prior: Plain): Plain => ({ prior, tag: "More" });

export const copyPlain = (value: Plain): Plain => {
  let depth = 0;
  let value0 = value;

  for (;;) {
    let returned: Plain;

    switch (value0.tag) {
      case "Empty": {
        returned = empty;
        break;
      }

      case "More": {
        depth += 1;
        value0 = value0.prior;
        continue;
      }

      default: {
        returned = value0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = more(returned);
    }
  }
};

export interface Input {
  readonly value: Nat;
}

export interface FactoryReset {
  readonly tag: "Reset";
}

export interface FactoryNext {
  readonly tag: "Next";
  readonly previous: FactoryCount;
}

export type FactoryCount = FactoryReset | FactoryNext;

const Factory$countRect = <A>(
  reset0: A,
  next0: (_: FactoryCount) => (_: A) => A,
  c: FactoryCount
): A => {
  const saved: [FactoryCount][] = [];
  let top = 0;
  let c0 = c;

  for (;;) {
    let returned: A;

    switch (c0.tag) {
      case "Reset": {
        returned = reset0;
        break;
      }

      case "Next": {
        __writeCell(saved, top, c0.previous);
        top += 1;
        c0 = c0.previous;
        continue;
      }

      default: {
        returned = c0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const previous: FactoryCount = __readCell(saved, top);
      returned = next0(previous)(returned);
    }
  }
};

const Factory$countRec = <A>(
  reset0: A,
  next0: (_: FactoryCount) => (_: A) => A,
  c: FactoryCount
): A => {
  const saved: [FactoryCount][] = [];
  let top = 0;
  let c0 = c;

  for (;;) {
    let returned: A;

    switch (c0.tag) {
      case "Reset": {
        returned = reset0;
        break;
      }

      case "Next": {
        __writeCell(saved, top, c0.previous);
        top += 1;
        c0 = c0.previous;
        continue;
      }

      default: {
        returned = c0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const previous: FactoryCount = __readCell(saved, top);
      returned = next0(previous)(returned);
    }
  }
};

const Factory$before: (left: FactoryCount, right: FactoryCount) => Bool =
  __unaryOrder<FactoryCount, Bool>(
    "tag",
    "Reset",
    "Next",
    "previous",
    (__unaryValue: FactoryCount): FactoryCount | undefined =>
      __unaryValue.tag === "Next" ? __unaryValue.previous : undefined,
    true0,
    false0,
    (left: FactoryCount, right: FactoryCount): Bool => {
      let left0 = left;
      let right0 = right;

      for (;;) {
        switch (left0.tag) {
          case "Reset": {
            return true0;
          }

          case "Next": {
            switch (right0.tag) {
              case "Reset": {
                return false0;
              }

              case "Next": {
                left0 = left0.previous;
                right0 = right0.previous;
                continue;
              }

              default: {
                return right0 satisfies never;
              }
            }
          }

          default: {
            return left0 satisfies never;
          }
        }
      }
    }
  );

const Factory$strictlyBefore = (
  left: FactoryCount,
  right: FactoryCount
): Bool => {
  switch (right.tag) {
    case "Reset": {
      return false0;
    }

    case "Next": {
      return Factory$before(left, right.previous);
    }

    default: {
      return right satisfies never;
    }
  }
};

export interface FactoryResult {
  readonly reset: FactoryReset;
  readonly next0: (previous: FactoryCount) => FactoryCount;
  readonly countRect: <A>(
    reset0: A,
    next0: (_: FactoryCount) => (_: A) => A,
    c: FactoryCount
  ) => A;
  readonly countRec: <A>(
    reset0: A,
    next0: (_: FactoryCount) => (_: A) => A,
    c: FactoryCount
  ) => A;
  readonly before: (left: FactoryCount, right: FactoryCount) => Bool;
  readonly strictlyBefore: (left: FactoryCount, right: FactoryCount) => Bool;
  readonly value: Nat;
}

export const Factory = (X: Input): FactoryResult => {
  const reset: FactoryReset = Object.freeze({ tag: "Reset" });

  const Factory$next0: (previous: FactoryCount) => FactoryCount =
    __unaryConstructor<FactoryCount>(
      (previous: FactoryCount): FactoryCount => ({ previous, tag: "Next" })
    );

  const value: Nat = X.value;

  return {
    before: Factory$before,
    countRec: Factory$countRec,
    countRect: Factory$countRect,
    next0: Factory$next0,
    reset,
    strictlyBefore: Factory$strictlyBefore,
    value,
  };
};

const Argument$value: Nat = o;

const Argument = {
  value: Argument$value,
} as const;

export type InstanceReset = FactoryReset;

export type InstanceNext = FactoryNext;

export type InstanceCount = FactoryCount;

export const Instance = Factory(Argument);

export interface Comparison {
  readonly compare: (_0: Counter, _1: Counter) => Verdict;
}

export interface AbstractResult {
  readonly strict: (left: Counter, right: Counter) => Verdict;
}

export const Abstract = (X: Comparison): AbstractResult => {
  const strict = (left: Counter, right: Counter): Verdict =>
    X.compare(tick(left), right);

  return { strict };
};
