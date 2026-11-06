import * as $Datatypes from "./datatypes.ts";

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

const { false0, true0 } = $Datatypes;

export const leb: (n: $Datatypes.Nat, m: $Datatypes.Nat) => $Datatypes.Bool =
  __unaryOrder<$Datatypes.Nat, $Datatypes.Bool>(
    "tag",
    "O",
    "S",
    "arg0",
    (__unaryValue: $Datatypes.Nat): $Datatypes.Nat | undefined =>
      __unaryValue.tag === "S" ? __unaryValue.arg0 : undefined,
    true0,
    false0,
    (n: $Datatypes.Nat, m: $Datatypes.Nat): $Datatypes.Bool => {
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

export const ltb = (n: $Datatypes.Nat, m: $Datatypes.Nat): $Datatypes.Bool => {
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
