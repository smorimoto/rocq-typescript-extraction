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

export interface Early {
  readonly tag: "Early";
}

export interface Late {
  readonly tag: "Late";
}

export interface Night {
  readonly tag: "Night";
}

export type Shift = Early | Late | Night;

export const early: Early = { tag: "Early" };
export const late: Late = { tag: "Late" };
export const night: Night = { tag: "Night" };

export const weight = (s0: Shift): Nat => {
  switch (s0.tag) {
    case "Early": {
      return s(o);
    }

    case "Late": {
      return s(s(o));
    }

    case "Night": {
      return s(s(s(o)));
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const shiftOf = (n: Nat): Shift => {
  switch (n.tag) {
    case "O": {
      return early;
    }

    case "S": {
      switch (n.arg0.tag) {
        case "O": {
          return late;
        }

        case "S": {
          return night;
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

export const threeInCond = (b: Bool, s0: Shift, n: Nat): Nat => {
  switch (b.tag) {
    case "True": {
      switch (s0.tag) {
        case "Early": {
          return add(s(o), n);
        }

        case "Late": {
          return add(s(s(o)), n);
        }

        case "Night": {
          return add(s(s(s(o))), n);
        }

        default: {
          return s0 satisfies never;
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

export const threeUnderCall = (b: Bool, s0: Shift, n: Nat): Nat => {
  switch (b.tag) {
    case "True": {
      switch (s0.tag) {
        case "Early": {
          return add(mul(s(o), n), n);
        }

        case "Late": {
          return add(mul(s(s(o)), n), n);
        }

        case "Night": {
          return add(mul(s(s(s(o))), n), n);
        }

        default: {
          return s0 satisfies never;
        }
      }
    }

    case "False": {
      return add(o, n);
    }

    default: {
      return b satisfies never;
    }
  }
};

export const letInMatchInCall = (n: Nat, m: Nat): Nat => {
  switch (n.tag) {
    case "O": {
      return add(m, m);
    }

    case "S": {
      const k: Nat = add(n.arg0, n.arg0);

      return add(add(k, m), m);
    }

    default: {
      return n satisfies never;
    }
  }
};

export const wideContext = (n: Nat, m: Nat): Nat => {
  let result: Nat;

  switch (m.tag) {
    case "O": {
      result = n;
      break;
    }

    case "S": {
      result = m.arg0.tag === "O" ? m : m.arg0.arg0;
      break;
    }

    default: {
      result = m satisfies never;
    }
  }

  return add(add(n, n), result);
};

export const twoMatches = (s0: Shift, t: Shift): Nat => {
  let result: Nat;

  switch (s0.tag) {
    case "Early": {
      result = s(o);
      break;
    }

    case "Late": {
      result = s(s(o));
      break;
    }

    case "Night": {
      result = s(s(s(o)));
      break;
    }

    default: {
      result = s0 satisfies never;
    }
  }

  switch (t.tag) {
    case "Early": {
      return add(result, s(s(s(s(o)))));
    }

    case "Late": {
      return add(result, s(s(s(s(s(o))))));
    }

    case "Night": {
      return add(result, s(s(s(s(s(s(o)))))));
    }

    default: {
      return t satisfies never;
    }
  }
};

export const boundMatch = (s0: Shift, n: Nat): Nat => {
  switch (s0.tag) {
    case "Early": {
      const w: Nat = n;

      return add(w, w);
    }

    case "Late": {
      const w: Nat = add(n, n);

      return add(w, w);
    }

    case "Night": {
      const w: Nat = o;

      return add(w, w);
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const boundWide = (s0: Shift, n: Nat): Nat => {
  let w: Nat;

  switch (s0.tag) {
    case "Early": {
      w = n;
      break;
    }

    case "Late": {
      w = add(n, n);
      break;
    }

    case "Night": {
      w = o;
      break;
    }

    default: {
      w = s0 satisfies never;
    }
  }

  return add(w, add(w, n));
};

export const boundStatement = (s0: Shift, n: Nat): Nat => {
  let w: Nat;

  switch (s0.tag) {
    case "Early": {
      w = n;
      break;
    }

    case "Late": {
      w = add(n, n);
      break;
    }

    case "Night": {
      w = o;
      break;
    }

    default: {
      w = s0 satisfies never;
    }
  }

  const v: Nat = add(w, w);

  return add(v, n);
};

export const constructorContext = (s0: Shift, n: Nat): Prod<Nat, Nat> => {
  let result: Nat;

  switch (s0.tag) {
    case "Early": {
      result = n;
      break;
    }

    case "Late": {
      result = add(n, n);
      break;
    }

    case "Night": {
      result = o;
      break;
    }

    default: {
      result = s0 satisfies never;
    }
  }

  return pair<Nat, Nat>(s(n), result);
};

export const constructorBody = (s0: Shift, n: Nat): List<Nat> => {
  let w: Nat;

  switch (s0.tag) {
    case "Early": {
      w = n;
      break;
    }

    case "Late": {
      w = add(n, n);
      break;
    }

    case "Night": {
      w = o;
      break;
    }

    default: {
      w = s0 satisfies never;
    }
  }

  return cons(w, cons<Nat>(s(o), nil));
};

export const matchOnMatch = (s0: Shift, n: Nat): Nat => {
  let result: Nat;

  switch (s0.tag) {
    case "Early": {
      result = n;
      break;
    }

    case "Late": {
      result = s(n);
      break;
    }

    case "Night": {
      result = o;
      break;
    }

    default: {
      result = s0 satisfies never;
    }
  }

  switch (result.tag) {
    case "O": {
      return s(s(s(s(s(s(s(o)))))));
    }

    case "S": {
      return result.arg0;
    }

    default: {
      return result satisfies never;
    }
  }
};

export const partialOfPair = (p: Prod<Nat, Nat>): ((_: Nat) => Nat) => {
  const x: Nat = add(p.arg0, p.arg1);

  return (x0: Nat): Nat => add(x, x0);
};

const nightWeightOf = (s0: Shift): Nat => {
  switch (s0.tag) {
    case "Early": {
      return s(o);
    }

    case "Late": {
      return s(s(o));
    }

    case "Night": {
      return s(s(s(o)));
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const nightWeight: Nat = s(nightWeightOf(shiftOf(s(s(o)))));
export const openingWeight: Nat = s(o);

export interface SCons {
  readonly tag: "SCons";
  readonly h: Nat;
  readonly t: Stream;
}

export type Stream = () => SCons;

export const sCons = (h: Nat, t: Stream): SCons => ({ h, t, tag: "SCons" });

export const doubles = (n: Nat): Stream =>
  __lazy((): SCons => {
    const k: Nat = add(n, n);

    return sCons(add(k, k), doubles(s(n)));
  });

export const shead = (s0: Stream): Nat => s0().h;
