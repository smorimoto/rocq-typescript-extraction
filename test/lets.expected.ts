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

const go = (k: Nat, acc: Nat): Nat => {
  let k0 = k;
  let acc0 = acc;

  for (;;) {
    switch (k0.tag) {
      case "O": {
        return acc0;
      }

      case "S": {
        acc0 = add(acc0, k0);
        k0 = k0.arg0;
        continue;
      }

      default: {
        return k0 satisfies never;
      }
    }
  }
};

export const sumTo = (n: Nat): Nat => go(n, o);

const evOd = {
  ev: (k: Nat): Bool => {
    let k0 = k;

    for (;;) {
      switch (k0.tag) {
        case "O": {
          return true0;
        }

        case "S": {
          const k1: Nat = k0.arg0;

          switch (k1.tag) {
            case "O": {
              return false0;
            }

            case "S": {
              k0 = k1.arg0;
              continue;
            }

            default: {
              return k1 satisfies never;
            }
          }
        }

        default: {
          return k0 satisfies never;
        }
      }
    }
  },
  od: (k: Nat): Bool => {
    let k0 = k;

    for (;;) {
      switch (k0.tag) {
        case "O": {
          return false0;
        }

        case "S": {
          const k1: Nat = k0.arg0;

          switch (k1.tag) {
            case "O": {
              return true0;
            }

            case "S": {
              k0 = k1.arg0;
              continue;
            }

            default: {
              return k1 satisfies never;
            }
          }
        }

        default: {
          return k0 satisfies never;
        }
      }
    }
  },
};

export const parity: (_: Nat) => Bool = evOd.ev;
const f = (x: Nat, y: Nat): Nat => add(add(x, y), y);
export const twicePlus = (n: Nat): Nat => f(n, f(n, s(o)));

export const doublePlus = (n: Nat, m: Nat): Nat => {
  const k: Nat = s(n);

  return add(add(k, k), m);
};

export const countdown = (n: Nat): List<Nat> => {
  switch (n.tag) {
    case "O": {
      return nil;
    }

    case "S": {
      const go0 = (k: Nat): List<Nat> => {
        const saved: [Nat][] = [];
        let top = 0;
        let k0 = k;

        for (;;) {
          let returned: List<Nat>;

          switch (k0.tag) {
            case "O": {
              returned = cons(n.arg0, nil);
              break;
            }

            case "S": {
              __writeCell(saved, top, k0);
              top += 1;
              k0 = k0.arg0;
              continue;
            }

            default: {
              returned = k0 satisfies never;
            }
          }

          for (;;) {
            if (top === 0) {
              return returned;
            }

            top -= 1;
            const k00: Nat = __readCell(saved, top);
            returned = cons(k00, returned);
          }
        }
      };

      return go0(n.arg0);
    }

    default: {
      return n satisfies never;
    }
  }
};

export const adder = (n: Nat): ((_: Nat) => Nat) => {
  const base: Nat = add(n, n);

  return (m: Nat): Nat => add(base, m);
};
