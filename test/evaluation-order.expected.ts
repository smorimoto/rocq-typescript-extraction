const __fail = (message: string): never => {
  throw new Error(message);
};

const __lazy = <T>(force: () => T): (() => T) => {
  let cell: { readonly value: T } | undefined;

  return () => {
    if (cell === undefined) {
      cell = { value: force() };
    }

    return cell.value;
  };
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

const boom = (_unused: Nat): Nat =>
  __fail(
    "AXIOM TO BE REALIZED (Dune_Extraction_EvaluationOrder.EvaluationOrder.boom)"
  );

export interface Red {
  readonly tag: "Red";
}

export interface Green {
  readonly tag: "Green";
}

export interface Blue {
  readonly tag: "Blue";
}

export type Color = Red | Green | Blue;

export const red: Red = { tag: "Red" };
export const green: Green = { tag: "Green" };
export const blue: Blue = { tag: "Blue" };

export const strictBranch = (n: Nat, c: Color): Nat => {
  switch (c.tag) {
    case "Red": {
      return add(n, s(o));
    }

    case "Green": {
      return add(n, s(s(o)));
    }

    case "Blue": {
      return add(n, boom(o));
    }

    default: {
      return c satisfies never;
    }
  }
};

export const inLambda = (n: Nat): ((_: Nat) => Nat) => {
  const k: Nat = add(n, n);

  return (m: Nat): Nat => add(m, k.tag === "O" ? boom(o) : k.arg0);
};

export const inBranch = (b: Bool, c: Color): Nat => {
  switch (b.tag) {
    case "True": {
      switch (c.tag) {
        case "Red": {
          return s(o);
        }

        case "Green": {
          return s(s(o));
        }

        case "Blue": {
          return boom(o);
        }

        default: {
          return c satisfies never;
        }
      }
    }

    case "False": {
      return o;
    }

    default: {
      return b satisfies never;
    }
  }
};

export const partialBoom = (n: Nat): ((_: Nat) => Nat) => {
  const x: Nat = n.tag === "O" ? boom(o) : n.arg0;

  return (x0: Nat): Nat => add(x, x0);
};

export const partialOk = (n: Nat): ((_: Nat) => Nat) => {
  const x: Nat = n.tag === "O" ? s(o) : n.arg0;

  return (x0: Nat): Nat => add(x, x0);
};

export const two = (c: Color, d: Color): Nat => {
  let result: Nat;

  switch (c.tag) {
    case "Red": {
      result = s(o);
      break;
    }

    case "Green": {
      result = s(s(o));
      break;
    }

    case "Blue": {
      result = s(s(s(o)));
      break;
    }

    default: {
      result = c satisfies never;
    }
  }

  switch (d.tag) {
    case "Red": {
      return add(result, s(s(s(s(o)))));
    }

    case "Green": {
      return add(result, s(s(s(s(s(o))))));
    }

    case "Blue": {
      return add(result, boom(o));
    }

    default: {
      return d satisfies never;
    }
  }
};

export const classify = (n: Nat): Color => {
  switch (n.tag) {
    case "O": {
      return red;
    }

    case "S": {
      switch (n.arg0.tag) {
        case "O": {
          return green;
        }

        case "S": {
          return blue;
        }

        default: {
          return n.arg0 satisfies never;
        }
      }
    }

    default: {
      return n satisfies never;
    }
  }
};

const topSafeOf = (s0: Color): Nat => (s0.tag === "Red" ? s(o) : boom(o));
export const topSafe: Nat = s(topSafeOf(classify(o)));

export const shadow = (n: Nat, c: Color): Nat => {
  const result: Nat = add(n, n);
  let result0: Nat;

  switch (c.tag) {
    case "Red": {
      result0 = s(o);
      break;
    }

    case "Green": {
      result0 = s(s(o));
      break;
    }

    case "Blue": {
      result0 = s(s(s(o)));
      break;
    }

    default: {
      result0 = c satisfies never;
    }
  }

  return add(add(result, result), result0);
};

export interface Cons {
  readonly tag: "Cons";
  readonly h: Nat;
  readonly t: Stream;
}

export type Stream = () => Cons;

export const cons = (h: Nat, t: Stream): Cons => ({ h, t, tag: "Cons" });

export const later = (n: Nat): Stream =>
  __lazy((): Cons => cons(n.tag === "O" ? boom(o) : n.arg0, later(n)));

export const force0 = (s0: Stream): Nat => s0().h;

export const lazyLet = (n: Nat): Stream =>
  __lazy((): Cons => {
    const k: Nat = add(n, n);

    return cons(add(k, n.tag === "O" ? boom(o) : o), lazyLet(n));
  });

const matchTok = <R>(onA: () => R, onC: () => R, t: boolean): R =>
  t ? onA() : onC();

export const fromTok = (n: Nat, t: boolean, c: Color): Nat =>
  add(
    n,
    matchTok(
      (): Nat => {
        switch (c.tag) {
          case "Red": {
            return s(o);
          }

          case "Green": {
            return s(s(o));
          }

          case "Blue": {
            return s(s(s(o)));
          }

          default: {
            return c satisfies never;
          }
        }
      },
      (): Nat => boom(o),
      t
    )
  );
