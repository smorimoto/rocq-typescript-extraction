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

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });

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

const mul = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: Nat;

    switch (n0.tag) {
      case "O": {
        returned = o;
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
      returned = add(m, returned);
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

export const plus = (x: Nat, x0: Nat): Nat => add(x, x0);
export const add3 = (x: Nat): Nat => plus(s(s(s(o))), x);
export const plusN = (x: Nat, x0: Nat): Nat => plus(x, x0);

export const adders: List<(_: Nat) => Nat> = map(
  (x: Nat) =>
    (x0: Nat): Nat =>
      plus(x, x0),
  cons<Nat>(o, cons<Nat>(s(o), nil))
);

export const applyTwice = <A>(f: (_: A) => A, x: A): A => f(f(x));
const x0: (_: Nat) => Nat = (x: Nat): Nat => plus(s(s(o)), x);
export const add4: (_: Nat) => Nat = (x: Nat): Nat => applyTwice(x0, x);
export const sum3 = (n: Nat, m: Nat, k: Nat): Nat => add(add(n, m), k);
export const partialSum3 = (x: Nat, x1: Nat, x2: Nat): Nat => sum3(x, x1, x2);
export const fullSum3: Nat = sum3(s(o), s(s(o)), s(s(s(o))));

export const staged = (n: Nat): ((_: Nat) => Nat) => {
  const t: Nat = mul(n, n);

  return (m: Nat): Nat => add(t, m);
};

export const stagedValue: Nat = staged(s(s(s(o))))(s(s(s(s(o)))));

export const pick = <A>(b: Bool, x: A, y: A): A => {
  switch (b.tag) {
    case "True": {
      return x;
    }

    case "False": {
      return y;
    }

    default: {
      return b satisfies never;
    }
  }
};

export const pickFirst = <A>(x: A, x1: A): A => pick(true0, x, x1);
export const one: Nat = s(o);
export const addOne = (x: Nat): Nat => plus(one, x);
export const addSucc = (x: Nat): Nat => plus(s(one), x);
