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

export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });

export interface Some<A> {
  readonly tag: "Some";
  readonly arg0: A;
}

export interface None {
  readonly tag: "None";
}

export type Option<A> = Some<A> | None;

export const some = <A>(arg0: A): Option<A> => ({ arg0, tag: "Some" });
export const none: None = { tag: "None" };

export interface Pair<A, B> {
  readonly tag: "Pair";
  readonly arg0: A;
  readonly arg1: B;
}

export type Prod<A, B> = Pair<A, B>;

export const pair = <A, B>(arg0: A, arg1: B): Pair<A, B> => ({
  arg0,
  arg1,
  tag: "Pair",
});

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

const add = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: Nat;

    switch (n0.tag) {
      case "O": {
        returned = m;
        break;
      }

      case "S": {
        depth += 1;
        n0 = n0.arg0;
        continue;
      }

      default: {
        returned = n0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = s(returned);
    }
  }
};

const map = <A, B>(f: (_: A) => B, l: List<A>): List<B> => {
  const saved: [A][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<B>;

    switch (l0.tag) {
      case "Nil": {
        returned = nil;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, l0.arg0);
        top += 1;
        l0 = l0.arg1;
        continue;
      }

      default: {
        returned = l0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: A = __readCell(saved, top);
      returned = cons(f(arg0), returned);
    }
  }
};

export interface EarlyMorningShift {
  readonly tag: "EarlyMorningShift";
}

export interface LateAfternoonShift {
  readonly tag: "LateAfternoonShift";
}

export interface EveningShift {
  readonly tag: "EveningShift";
}

export interface OvernightShift {
  readonly tag: "OvernightShift";
}

export type Shift =
  | EarlyMorningShift
  | LateAfternoonShift
  | EveningShift
  | OvernightShift;

export const earlyMorningShift: EarlyMorningShift = {
  tag: "EarlyMorningShift",
};

export const lateAfternoonShift: LateAfternoonShift = {
  tag: "LateAfternoonShift",
};

export const eveningShift: EveningShift = { tag: "EveningShift" };
export const overnightShift: OvernightShift = { tag: "OvernightShift" };

export const combineMeasurements = (
  firstReading: Nat,
  secondReading: Nat,
  thirdReading: Nat,
  fourthReading: Nat
): Nat =>
  add(add(add(firstReading, secondReading), thirdReading), fourthReading);

export const combinedReadings: Nat = combineMeasurements(
  combineMeasurements(s(o), s(s(o)), s(s(s(o))), s(s(s(s(o))))),
  combineMeasurements(s(s(s(s(o)))), s(s(s(o))), s(s(o)), s(o)),
  s(o),
  s(o)
);

export const applyTwice = <A>(f: (_: A) => A, x: A): A => f(f(x));

export const pairwiseCombinations: List<(_: Nat) => Nat> = map(
  (firstReading: Nat) =>
    (secondReading: Nat): Nat =>
      combineMeasurements(firstReading, secondReading, s(o), s(o)),
  cons<Nat>(s(o), cons<Nat>(s(s(o)), nil))
);

const x0: (_: Nat) => Nat = (x: Nat): Nat =>
  combineMeasurements(s(o), s(o), s(o), x);

export const twiceCombined: (_: Nat) => Nat = (x: Nat): Nat =>
  applyTwice(x0, x);

export const shiftWeight = (s0: Shift, bonus: Nat): Nat => {
  switch (s0.tag) {
    case "EarlyMorningShift": {
      return combineMeasurements(s(o), bonus, o, o);
    }

    case "LateAfternoonShift": {
      return combineMeasurements(s(s(o)), bonus, o, o);
    }

    case "EveningShift": {
      return combineMeasurements(s(s(s(o))), bonus, o, o);
    }

    case "OvernightShift": {
      return combineMeasurements(s(s(s(s(o)))), bonus, o, o);
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const emptySchedule: Prod<
  List<Option<Nat>>,
  Prod<List<Option<Shift>>, List<Option<Nat>>>
> = pair<List<Option<Nat>>, Prod<List<Option<Shift>>, List<Option<Nat>>>>(
  nil,
  pair<List<Option<Shift>>, List<Option<Nat>>>(nil, nil)
);

export const duréeTotaleDesRelevé: Nat = combineMeasurements(
  s(s(s(o))),
  s(s(s(o))),
  s(s(o)),
  s(o)
);
