const __lazy = <T>(force: () => T): (() => T) => {
  let cell: { readonly value: T } | undefined;

  return () => {
    if (cell === undefined) {
      cell = { value: force() };
    }

    return cell.value;
  };
};

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

export interface SCons<A> {
  readonly tag: "SCons";
  readonly h: A;
  readonly t: Stream<A>;
}

export type Stream<A> = () => SCons<A>;

export const sCons = <A>(h: A, t: Stream<A>): SCons<A> => ({
  h,
  t,
  tag: "SCons",
});

export const from0 = (n: Nat): Stream<Nat> =>
  __lazy((): SCons<Nat> => sCons(n, from0(s(n))));

export const ones: Stream<Nat> = __lazy((): SCons<Nat> => sCons(s(o), ones));

export const mapS = <A, B>(f: (_: A) => B, s0: Stream<A>): Stream<B> =>
  __lazy((): SCons<B> => sCons(f(s0().h), mapS(f, s0().t)));

export const shead = <A>(s0: Stream<A>): A => s0().h;
export const stail = <A>(s0: Stream<A>): Stream<A> => s0().t;

export const take = <A>(n: Nat, s0: Stream<A>): List<A> => {
  const saved: [A][] = [];
  let top = 0;
  let n0 = n;
  let s1 = s0;

  for (;;) {
    let returned: List<A>;

    switch (n0.tag) {
      case "O": {
        returned = nil;
        break;
      }

      case "S": {
        __writeCell(saved, top, s1().h);
        top += 1;
        n0 = n0.arg0;
        s1 = s1().t;
        continue;
      }

      default: {
        returned = n0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const h: A = __readCell(saved, top);
      returned = cons(h, returned);
    }
  }
};

export const evens: Stream<Nat> = mapS((n: Nat): Nat => add(n, n), from0(o));

export interface CNil {
  readonly tag: "CNil";
}

export interface CCons {
  readonly tag: "CCons";
  readonly h: Nat;
  readonly t: Colist;
}

export type Colist = () => CNil | CCons;

export const cNil: CNil = { tag: "CNil" };
export const cCons = (h: Nat, t: Colist): CCons => ({ h, t, tag: "CCons" });

export const countdown = (n: Nat): Colist => {
  switch (n.tag) {
    case "O": {
      return __lazy((): CNil => cNil);
    }

    case "S": {
      return __lazy((): CCons => cCons(n, countdown(n.arg0)));
    }

    default: {
      return n satisfies never;
    }
  }
};

export const headOr = (d: Nat, l: Colist): Nat => {
  const s0: ReturnType<Colist> = l();

  switch (s0.tag) {
    case "CNil": {
      return d;
    }

    case "CCons": {
      return s0.h;
    }

    default: {
      return s0 satisfies never;
    }
  }
};
