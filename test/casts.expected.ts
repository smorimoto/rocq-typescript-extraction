const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

interface True {
  readonly tag: "True";
}

interface False {
  readonly tag: "False";
}

type Bool = True | False;

const true0: True = { tag: "True" };
const false0: False = { tag: "False" };

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

interface Some<A> {
  readonly tag: "Some";
  readonly arg0: A;
}

interface None {
  readonly tag: "None";
}

type Option<A> = Some<A> | None;

const some = <A>(arg0: A): Option<A> => ({ arg0, tag: "Some" });
const none: None = { tag: "None" };

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

const size = (_unused: Prod<Option<Bool>, Bool>): Nat => o;

export const sizes: Nat = add(
  add(
    size(pair<Option<Bool>, Bool>(none, true0)),
    size(
      __magic<Prod<Option<Nat>, Nat>, Prod<Option<Bool>, Bool>>(
        pair<Option<Nat>, Nat>(some<Nat>(o), o)
      )
    )
  ),
  size(pair<Option<Bool>, Bool>(some<Bool>(true0), false0))
);
