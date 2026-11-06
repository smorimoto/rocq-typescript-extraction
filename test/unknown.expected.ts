const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

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

export const dep = <B extends Bool>(b: B): B extends True ? Nat : Bool => {
  switch (b.tag) {
    case "True": {
      return __magic<Nat, B extends True ? Nat : Bool>(o);
    }

    case "False": {
      return __magic<Bool, B extends True ? Nat : Bool>(false0);
    }

    default: {
      return b satisfies never;
    }
  }
};

export const fromFalse = (): Nat => __fail("absurd case");
export const fallback = (): Nat => fromFalse();
export const pr = undefined;
const sizeOf = <A>(_unused: A): Nat => o;
export const sized: Nat = sizeOf<undefined>(undefined);

export const proofs: List<undefined> = cons<undefined>(
  undefined,
  cons<undefined>(undefined, nil)
);
