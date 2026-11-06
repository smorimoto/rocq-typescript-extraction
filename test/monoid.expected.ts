const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

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

const andb: (_0: boolean, _1: boolean) => boolean = (
  a: boolean,
  b: boolean
): boolean => a && b;

const s = (n: number): number => n + 1;

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

export interface Monoid<Carrier0> {
  readonly op: (_: Carrier0) => (_: Carrier0) => Carrier0;
  readonly unit: Carrier0;
}

export const natMonoid: Monoid<number> = {
  op:
    (x: number) =>
    (x0: number): number =>
      add(x, x0),
  unit: 0,
};

export const mconcat = <Carrier0>(
  m: Monoid<Carrier0>,
  xs: List<Carrier0>
): Carrier0 => {
  const saved: [(_: Carrier0) => (_: Carrier0) => Carrier0][] = [];
  let top = 0;
  const saved0: [Carrier0][] = [];
  let top0 = 0;
  let xs0 = xs;

  for (;;) {
    let returned: Carrier0;

    switch (xs0.tag) {
      case "Nil": {
        returned = m.unit;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, m.op);
        top += 1;
        __writeCell(saved0, top0, xs0.arg0);
        top0 += 1;
        xs0 = xs0.arg1;
        continue;
      }

      default: {
        returned = xs0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top0 -= 1;
      const arg0: Carrier0 = __readCell(saved0, top0);
      top -= 1;

      const op: (_: Carrier0) => (_: Carrier0) => Carrier0 = __readCell(
        saved,
        top
      );

      returned = op(arg0)(returned);
    }
  }
};

export const total: number = mconcat(
  natMonoid,
  cons(s(0), cons(s(s(0)), cons(s(s(s(0))), nil)))
);

export const squared = <Carrier0>(m: Monoid<Carrier0>): Carrier0 =>
  m.op(m.unit)(m.unit);

export const count = <Carrier0>(ms: List<Monoid<Carrier0>>): number => {
  let depth = 0;
  let ms0 = ms;

  for (;;) {
    let returned: number;

    switch (ms0.tag) {
      case "Nil": {
        returned = 0;
        break;
      }

      case "Cons": {
        depth += 1;
        ms0 = ms0.arg1;
        continue;
      }

      default: {
        returned = ms0 satisfies never;
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

export const same = <Carrier0>(m: Monoid<Carrier0>): Monoid<Carrier0> => m;

export const doubled = <Carrier0>(m: Monoid<Carrier0>): Monoid<Carrier0> => ({
  op:
    (x: Carrier0) =>
    (y: Carrier0): Carrier0 =>
      m.op(m.op(x)(y))(y),
  unit: m.unit,
});

export const withUnit = (n: number): Monoid<number> => ({
  op:
    (x: number) =>
    (x0: number): number =>
      add(x, x0),
  unit: n,
});

export const pick = <B extends boolean>(
  b: B
): B extends true ? Monoid<number> : Monoid<boolean> =>
  b
    ? __magic<
        Monoid<number>,
        B extends true ? Monoid<number> : Monoid<boolean>
      >(natMonoid)
    : __magic<
        Monoid<boolean>,
        B extends true ? Monoid<number> : Monoid<boolean>
      >({
        op:
          (x: boolean) =>
          (x0: boolean): boolean =>
            andb(x, x0),
        unit: true,
      });

export const picked: number = squared(pick(true));
