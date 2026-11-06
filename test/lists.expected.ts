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

const optionMap = <A, B>(f: (_: A) => B, o0: Option<A>): Option<B> => {
  switch (o0.tag) {
    case "Some": {
      return some(f(o0.arg0));
    }

    case "None": {
      return none;
    }

    default: {
      return o0 satisfies never;
    }
  }
};

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
const snd = <A, B>(p: Prod<A, B>): B => p.arg1;

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

const app = <A>(l: List<A>, m: List<A>): List<A> => {
  const saved: [A][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<A>;

    switch (l0.tag) {
      case "Nil": {
        returned = m;
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
      returned = cons(arg0, returned);
    }
  }
};

export interface Eq {
  readonly tag: "Eq";
}

export interface Lt {
  readonly tag: "Lt";
}

export interface Gt {
  readonly tag: "Gt";
}

export type Comparison = Eq | Lt | Gt;

export const eq: Eq = { tag: "Eq" };
export const lt: Lt = { tag: "Lt" };
export const gt: Gt = { tag: "Gt" };

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

const double0 = (n: Nat): Nat => add(n, n);

export const eqb = (n: Nat, m: Nat): Bool => {
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

export const leb = (n: Nat, m: Nat): Bool => {
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
};

const compare = (n: Nat, m: Nat): Comparison => {
  let n0 = n;
  let m0 = m;

  for (;;) {
    switch (n0.tag) {
      case "O": {
        switch (m0.tag) {
          case "O": {
            return eq;
          }

          case "S": {
            return lt;
          }

          default: {
            return m0 satisfies never;
          }
        }
      }

      case "S": {
        switch (m0.tag) {
          case "O": {
            return gt;
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

export const max = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n0 = n;
  let m0 = m;

  for (;;) {
    let returned: Nat;

    switch (n0.tag) {
      case "O": {
        returned = m0;
        break;
      }

      case "S": {
        switch (m0.tag) {
          case "O": {
            returned = n0;
            break;
          }

          case "S": {
            depth += 1;
            n0 = n0.arg0;
            m0 = m0.arg0;
            continue;
          }

          default: {
            returned = m0 satisfies never;
          }
        }

        break;
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

const seq = (start: Nat, len: Nat): List<Nat> => {
  const saved: [Nat][] = [];
  let top = 0;
  let start0 = start;
  let len0 = len;

  for (;;) {
    let returned: List<Nat>;

    switch (len0.tag) {
      case "O": {
        returned = nil;
        break;
      }

      case "S": {
        __writeCell(saved, top, start0);
        top += 1;
        start0 = s(start0);
        len0 = len0.arg0;
        continue;
      }

      default: {
        returned = len0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const start00: Nat = __readCell(saved, top);
      returned = cons(start00, returned);
    }
  }
};

const repeat = <A>(x: A, n: Nat): List<A> => {
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: List<A>;

    switch (n0.tag) {
      case "O": {
        returned = nil;
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
      returned = cons(x, returned);
    }
  }
};

const nth = <A>(n: Nat, l: List<A>, default0: A): A => {
  let n0 = n;
  let l0 = l;

  for (;;) {
    switch (n0.tag) {
      case "O": {
        switch (l0.tag) {
          case "Nil": {
            return default0;
          }

          case "Cons": {
            return l0.arg0;
          }

          default: {
            return l0 satisfies never;
          }
        }
      }

      case "S": {
        switch (l0.tag) {
          case "Nil": {
            return default0;
          }

          case "Cons": {
            n0 = n0.arg0;
            l0 = l0.arg1;
            continue;
          }

          default: {
            return l0 satisfies never;
          }
        }
      }

      default: {
        return n0 satisfies never;
      }
    }
  }
};

const firstn = <A>(n: Nat, l: List<A>): List<A> => {
  const saved: [A][] = [];
  let top = 0;
  let n0 = n;
  let l0 = l;

  for (;;) {
    let returned: List<A>;

    switch (n0.tag) {
      case "O": {
        returned = nil;
        break;
      }

      case "S": {
        switch (l0.tag) {
          case "Nil": {
            returned = nil;
            break;
          }

          case "Cons": {
            __writeCell(saved, top, l0.arg0);
            top += 1;
            n0 = n0.arg0;
            l0 = l0.arg1;
            continue;
          }

          default: {
            returned = l0 satisfies never;
          }
        }

        break;
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
      const arg0: A = __readCell(saved, top);
      returned = cons(arg0, returned);
    }
  }
};

const skipn = <A>(n: Nat, l: List<A>): List<A> => {
  let n0 = n;
  let l0 = l;

  for (;;) {
    switch (n0.tag) {
      case "O": {
        return l0;
      }

      case "S": {
        switch (l0.tag) {
          case "Nil": {
            return nil;
          }

          case "Cons": {
            n0 = n0.arg0;
            l0 = l0.arg1;
            continue;
          }

          default: {
            return l0 satisfies never;
          }
        }
      }

      default: {
        return n0 satisfies never;
      }
    }
  }
};

export const safeHead = <A>(l: List<A>): Option<A> => {
  switch (l.tag) {
    case "Nil": {
      return none;
    }

    case "Cons": {
      return some(l.arg0);
    }

    default: {
      return l satisfies never;
    }
  }
};

export const swapPair = <A, B>(p: Prod<A, B>): Prod<B, A> =>
  pair(snd(p), fst(p));

export const sum = (l: List<Nat>): Nat => {
  const saved: [Nat][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: Nat;

    switch (l0.tag) {
      case "Nil": {
        returned = o;
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
      const arg0: Nat = __readCell(saved, top);
      returned = add(arg0, returned);
    }
  }
};

export const firsts: List<Nat> = map(
  (x: Prod<Nat, Bool>): Nat => fst(x),
  cons(
    pair<Nat, Bool>(s(o), true0),
    cons(pair<Nat, Bool>(s(s(o)), false0), nil)
  )
);

export const doubled: List<Nat> = map(double0, seq(o, s(s(s(s(o))))));

export const middle: List<Nat> = firstn(
  s(s(o)),
  skipn(s(o), seq(s(s(s(s(s(s(s(s(s(s(o)))))))))), s(s(s(s(s(o)))))))
);

export const third: Nat = nth(
  s(s(o)),
  seq(s(s(s(s(s(s(s(s(s(s(o)))))))))), s(s(s(s(s(o)))))),
  o
);

export const nextHead: Option<Nat> = optionMap(
  (x: Nat): Nat => s(x),
  safeHead(seq(s(s(s(o))), s(s(o))))
);

export const total: Nat = length(
  app(repeat<Bool>(true0, s(s(o))), cons<Bool>(false0, nil))
);

export const order: Comparison = compare(s(s(s(o))), s(s(s(s(s(o))))));
export const empty = <A>(): List<A> => nil;

export const preds: List<Nat> = map(
  (q: Prod<Nat, Nat>): Nat => {
    const s0: Nat = add(q.arg0, q.arg1);

    switch (s0.tag) {
      case "O": {
        return q.arg1;
      }

      case "S": {
        return s0.arg0;
      }

      default: {
        return s0 satisfies never;
      }
    }
  },
  cons(pair<Nat, Nat>(s(o), s(s(o))), cons(pair<Nat, Nat>(o, o), nil))
);
