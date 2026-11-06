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

export const add = (n: Nat, m: Nat): Nat => {
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

export const ltb = (n: Nat, m: Nat): Bool => leb(s(n), m);
