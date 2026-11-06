const __unaryConstructor = <T extends object>(
  __unaryBuild: (__unaryChild: T) => T
): ((__unaryChild: T) => T) => {
  const __unarySuccessors = new WeakMap<T, WeakRef<T>>();

  return (__unaryChild: T): T => {
    const __unaryExisting = __unarySuccessors.get(__unaryChild)?.deref();

    if (__unaryExisting !== undefined) {
      return __unaryExisting;
    }

    const __unaryValue = Object.freeze(__unaryBuild(__unaryChild));
    __unarySuccessors.set(__unaryChild, new WeakRef(__unaryValue));

    return __unaryValue;
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

export const o: O = Object.freeze({ tag: "O" });

export const s: (arg0: Nat) => Nat = __unaryConstructor<Nat>(
  (arg0: Nat): Nat => ({ arg0, tag: "S" })
);
