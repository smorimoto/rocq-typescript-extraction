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

const fst = <A, B>(p: Prod<A, B>): A => p.arg0;

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

const eqb = (n: Nat, m: Nat): Bool => {
  let n0 = n;
  let m0 = m;

  for (;;) {
    switch (n0.tag) {
      case "O": {
        switch (m0.tag) {
          case "O": {
            return true0;
          }

          case "S": {
            return false0;
          }

          default: {
            return m0 satisfies never;
          }
        }
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
};

const id = <A>(x: A): A => x;
export const ids = (n: Nat, b: Bool): Prod<Nat, Bool> => pair(id(n), id(b));
const first = <A>(d: A, l: List<A>): A => (l.tag === "Nil" ? d : l.arg0);

export const firsts = (ns: List<Nat>, bs: List<Bool>): Prod<Nat, Bool> =>
  pair(first(o, ns), first(false0, bs));

const length = <A>(l: List<A>): Nat => {
  let depth = 0;
  let l0 = l;

  for (;;) {
    let returned: Nat;

    switch (l0.tag) {
      case "Nil": {
        returned = o;
        break;
      }

      case "Cons": {
        depth += 1;
        l0 = l0.arg1;
        continue;
      }

      default: {
        returned = l0 satisfies never;
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

export const lengths = (ns: List<Nat>, bs: List<Bool>): Nat =>
  add(length(ns), length(bs));

const evenOdd = {
  even: <A>(l: List<A>): Bool => {
    const saved: [List<A>][] = [];
    let top = 0;
    let l0 = l;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          switch (l0.tag) {
            case "Nil": {
              return true0;
            }

            case "Cons": {
              __writeCell(saved, top, l0.arg1);
              top += 1;
              which = 1;
              continue;
            }

            default: {
              return l0 satisfies never;
            }
          }
        }

        default: {
          top -= 1;
          const l1: List<A> = __readCell(saved, top);

          switch (l1.tag) {
            case "Nil": {
              return false0;
            }

            case "Cons": {
              l0 = l1.arg1;
              which = 0;
              continue;
            }

            default: {
              return l1 satisfies never;
            }
          }
        }
      }
    }
  },
  odd: <A>(l: List<A>): Bool => {
    const saved: [List<A>][] = [];
    let top = 0;
    let l0 = l;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top -= 1;
          const l1: List<A> = __readCell(saved, top);

          switch (l1.tag) {
            case "Nil": {
              return true0;
            }

            case "Cons": {
              l0 = l1.arg1;
              which = 1;
              continue;
            }

            default: {
              return l1 satisfies never;
            }
          }
        }

        default: {
          switch (l0.tag) {
            case "Nil": {
              return false0;
            }

            case "Cons": {
              __writeCell(saved, top, l0.arg1);
              top += 1;
              which = 0;
              continue;
            }

            default: {
              return l0 satisfies never;
            }
          }
        }
      }
    }
  },
};

export const evens = (ns: List<Nat>, bs: List<Bool>): Prod<Bool, Bool> =>
  pair(evenOdd.even(ns), evenOdd.even(bs));

const fG = {
  f: <A>(l: List<A>): Bool => {
    const saved: [List<A>][] = [];
    let top = 0;
    const saved0: [List<never>][] = [];
    let top0 = 0;
    let l0 = l;
    let which = 0;

    for (;;) {
      switch (which) {
        case 0: {
          switch (l0.tag) {
            case "Nil": {
              return true0;
            }

            case "Cons": {
              __writeCell(saved, top, l0.arg1);
              top += 1;
              __writeCell(saved0, top0, nil);
              top0 += 1;
              which = 1;
              continue;
            }

            default: {
              return l0 satisfies never;
            }
          }
        }

        default: {
          top0 -= 1;
          top -= 1;
          const l1: List<A> = __readCell(saved, top);

          switch (l1.tag) {
            case "Nil": {
              return false0;
            }

            case "Cons": {
              l0 = l1.arg1;
              which = 0;
              continue;
            }

            default: {
              return l1 satisfies never;
            }
          }
        }
      }
    }
  },
  g: <A, B>(l: List<A>, _unused: List<B>): Bool => {
    const saved: [List<A>][] = [];
    let top = 0;
    let l0 = l;
    let which = 1;

    for (;;) {
      switch (which) {
        case 0: {
          top -= 1;
          const l1: List<A> = __readCell(saved, top);

          switch (l1.tag) {
            case "Nil": {
              return true0;
            }

            case "Cons": {
              l0 = l1.arg1;
              which = 1;
              continue;
            }

            default: {
              return l1 satisfies never;
            }
          }
        }

        default: {
          switch (l0.tag) {
            case "Nil": {
              return false0;
            }

            case "Cons": {
              __writeCell(saved, top, l0.arg1);
              top += 1;
              which = 0;
              continue;
            }

            default: {
              return l0 satisfies never;
            }
          }
        }
      }
    }
  },
};

export const alternates = (ns: List<Nat>, bs: List<Bool>): Bool => {
  const s0: Bool = fG.f(ns);

  switch (s0.tag) {
    case "True": {
      return fG.f(bs);
    }

    case "False": {
      return false0;
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const tagged = <A>(
  a: A,
  n: Nat,
  b: Bool
): Prod<Prod<A, Nat>, Prod<A, Bool>> => {
  const tag = <B>(x: B): Prod<A, B> => pair(a, x);

  return pair(tag(n), tag(b));
};

const outer = <A>(x: A): Prod<A, Nat> => {
  const inner = <B>(y: B): Prod<A, B> => pair(x, y);

  return fst(pair(inner<Nat>(o), inner<Bool>(true0)));
};

export const nested = (
  n: Nat,
  b: Bool
): Prod<Prod<Nat, Nat>, Prod<Bool, Nat>> => pair(outer(n), outer(b));

const id0 = <A>(x: A): A => x;

export const picked = (n: Nat, m: Nat, b: Bool): Prod<Nat, Bool> =>
  pair<Nat, Bool>(add(n, m), b.tag === "True" ? id0(eqb(id0(n), m)) : false0);

const id1 = <A>(y: A): A => y;
const Inner$both = (n: Nat, b: Bool): Prod<Nat, Bool> => pair(id1(n), id1(b));

export const Inner = {
  both: Inner$both,
} as const;

const applyId = <A>(x: A): A => x;

export const applied = (n: Nat, b: Bool): Prod<Nat, Bool> => {
  const f: () => (_: Bool) => Bool = applyId(
    () =>
      (x: Bool): Bool =>
        x
  );

  return pair(
    __magic<() => (_: Bool) => Bool, () => (_: Nat) => Nat>(f)()(n),
    f()(b)
  );
};
