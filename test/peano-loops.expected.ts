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

interface Pair<A, B> {
  readonly tag: "Pair";
  readonly arg0: A;
  readonly arg1: B;
}

type Prod<A, B> = Pair<A, B>;

const pair = <A, B>(arg0: A, arg1: B): Pair<A, B> => ({
  arg0,
  arg1,
  tag: "Pair",
});

const fst = <A, B>(p: Prod<A, B>): A => p.arg0;

const divmod = (x: Nat, y: Nat, q: Nat, u: Nat): Prod<Nat, Nat> => {
  let x0 = x;
  let q0 = q;
  let u0 = u;

  for (;;) {
    switch (x0.tag) {
      case "O": {
        return pair(q0, u0);
      }

      case "S": {
        switch (u0.tag) {
          case "O": {
            x0 = x0.arg0;
            q0 = s(q0);
            u0 = y;
            continue;
          }

          case "S": {
            x0 = x0.arg0;
            u0 = u0.arg0;
            continue;
          }

          default: {
            return u0 satisfies never;
          }
        }
      }

      default: {
        return x0 satisfies never;
      }
    }
  }
};

const div = (x: Nat, y: Nat): Nat => {
  switch (y.tag) {
    case "O": {
      return y;
    }

    case "S": {
      return fst(divmod(x, y.arg0, o, y.arg0));
    }

    default: {
      return y satisfies never;
    }
  }
};

export const half = (n: Nat): Nat => div(n, s(s(o)));
