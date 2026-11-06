const __fail = (message: string): never => {
  throw new Error(message);
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

export const head = (l: List<Nat>): Nat => {
  switch (l.tag) {
    case "Nil": {
      return __fail("absurd case");
    }

    case "Cons": {
      return l.arg0;
    }

    default: {
      return l satisfies never;
    }
  }
};

const oracle = (_unused: Nat): Nat =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Absurd.Absurd.oracle)");

export const ask = (n: Nat): Nat => oracle(s(n));
