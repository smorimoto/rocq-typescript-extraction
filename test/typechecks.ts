import { retag, reveal } from "./axioms.ts";
import type { Box, Elt, Key, Table, Tagged, Wide } from "./axioms.ts";
import type { Arrows, PairedArrows } from "./curried-type-family.ts";
import { dep, packet, twice, weigh } from "./dependent.ts";
import { Made } from "./functor-dep.ts";
import type { FT, SIG, TypeLambda } from "./functor-signature-result.ts";
import { nil, Use } from "./higher-kinded.ts";
import type { List, LTLambda } from "./higher-kinded.ts";
import { collide } from "./lifting.ts";
import { Geometry } from "./modules.ts";
import { cons, mconcat, natMonoid, nil as noMonoids, pick } from "./monoid.ts";
import type { Monoid } from "./monoid.ts";
import { applyPoly } from "./rank-two.ts";
import * as Monolithic from "./reconstructed-dependencies/monolithic.ts";
import * as Separate from "./reconstructed-dependencies/payloads.ts";
import { Made as SeparateMade } from "./separate-dependent/separate-dependent.ts";
import { consume, red } from "./three-way.ts";
import { sum } from "./type-fixpoint.ts";

export const curriedActionResult = (
  action: (_: boolean) => (_: number) => number
): Arrows<boolean> =>
  // @ts-expect-error an action returning numbers is not an action returning booleans
  action;

export const reversedCurriedPair = (
  action: (_: boolean) => (_: number) => readonly [number, boolean]
): PairedArrows<boolean, number> =>
  // @ts-expect-error the result parameters keep their order through recursion
  action;

export const readonlyModule = () => {
  // @ts-expect-error module members are read-only
  Geometry.figureRect = Geometry.figureRec;
};

// @ts-expect-error two axioms are distinct types
export const distinctAxioms = (key: Key): Elt => key;

// @ts-expect-error a box of 1 is not a box of number
export const widenBox = (box: Box<1>): Box<number> => box;

// @ts-expect-error a box of number is not a box of 1
export const narrowBox = (box: Box<number>): Box<1> => box;

export const rekeyTable = (table: Table<1, string>): Table<number, string> =>
  // @ts-expect-error the first parameter of a table is invariant
  table;

export const revalueTable = (table: Table<string, number>): Table<string, 1> =>
  // @ts-expect-error the second parameter of a table is invariant
  table;

export const widenLast = (
  wide: Wide<0, 0, 0, 0, 0, 0, 1>
): Wide<0, 0, 0, 0, 0, 0, 2> =>
  // @ts-expect-error the last parameter of a wide axiom is invariant
  wide;

export const retagAxiom = (tagged: Tagged<1, 2>): Tagged<2, 1> => retag(tagged);

export const opaqueSecret = () =>
  // @ts-expect-error a number is not a Secret
  reveal(3);

export const polymorphicMap = () =>
  Use<LTLambda>({
    empty: () => nil,
    // @ts-expect-error returning the input does not map A to B
    map: <A, B>(_f: (_: A) => B, list: List<A>): List<A> => list,
  });

interface StringLambda extends TypeLambda {
  readonly type: string;
}

// @ts-expect-error a number result cannot implement a string result
export const functorResult: FT<StringLambda> = <T>(_argument: SIG<T>) => ({
  z: 0,
});

export const dependentPayload = () =>
  // @ts-expect-error the payload of false is a boolean
  weigh(false, 3);

export const packetPayload = () =>
  // @ts-expect-error the payload of true is a number
  packet(true, false);

export const dependentResult = (): number =>
  // @ts-expect-error dep(false) is a boolean
  dep(false);

export const dependentPair = (): readonly [number, number] =>
  // @ts-expect-error twice(false) holds booleans
  twice(false);

export const liftedResult = (): number =>
  // @ts-expect-error collide(false) is a boolean
  collide(false);

export const functorDependentResult = (): number =>
  // @ts-expect-error dep(false) is a boolean
  Made.dep(false);

export const separateDependentResult = (): number =>
  // @ts-expect-error dep(false) is a boolean across generated imports too
  SeparateMade.dep(false);

export const constructorPayload = () =>
  // @ts-expect-error the shade of red is a number
  consume(red, true);

export const monoidCarrier = () =>
  // @ts-expect-error the carrier of natMonoid is a number
  mconcat(natMonoid, cons(true, noMonoids));

export const dependentMonoid = (): Monoid<number> =>
  // @ts-expect-error the carrier of pick(false) is a boolean
  pick(false);

export const rankTwoFunction = () =>
  // @ts-expect-error a function of numbers is not generic
  applyPoly((x: number): number => x + 1, 1, true);

export const recursiveUnion = () =>
  // @ts-expect-error sum may return a number and needs narrowing before a call
  sum(0, 0)(1);

export const reconstructedPayload = () => {
  // @ts-expect-error the payload requires a parcel, not its nested token
  Monolithic.inspect(true, Monolithic.unnumbered);
  // @ts-expect-error the same constraint applies across generated imports
  Separate.inspect(true, Separate.unnumbered);
};

export const reconstructedMapping = () => {
  // @ts-expect-error the custom mapping is boolean, not a constructor object
  Monolithic.mappedRead(true, { tag: "Marked" });
  // @ts-expect-error the same constraint applies across generated imports
  Separate.mappedRead(true, { tag: "Marked" });
};

export const reconstructedMember = () => {
  const monolithic = Monolithic.Use({ readSecret: (b) => b });
  const separate = Separate.Use({ readSecret: (b) => b });
  // @ts-expect-error ready requires the type recovered from the module signature
  monolithic.ready(Monolithic.unnumbered);
  // @ts-expect-error the same constraint applies across generated imports
  separate.ready(Separate.unnumbered);
};
