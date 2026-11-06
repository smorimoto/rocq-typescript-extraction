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

export const three = (): Nat => s(s(s(o)));
export const applyProof = (h: () => Nat): Nat => h();
export const applied: Nat = applyProof(three);
export const asValue = (): Nat => three();
export const twice = (h: () => () => Nat): Nat => h()();
export const five = (): Nat => s(s(s(s(s(o)))));
export const appliedTwice: Nat = twice((): (() => Nat) => five);

export const localErased = (n: Nat): Nat => {
  const f = (): Nat => n;

  return add(f(), f());
};

export const fromOption = (o0: Option<() => Nat>): Nat => {
  switch (o0.tag) {
    case "Some": {
      return o0.arg0();
    }

    case "None": {
      return o;
    }

    default: {
      return o0 satisfies never;
    }
  }
};

export const someThree: Option<() => Nat> = some(three);
