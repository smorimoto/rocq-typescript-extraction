export interface True {
  readonly tag: "True";
}

export interface False {
  readonly tag: "False";
}

export type Bool = True | False;

export const true0: True = { tag: "True" };
export const false0: False = { tag: "False" };

const negb = (b: Bool): Bool => {
  switch (b.tag) {
    case "True": {
      return false0;
    }

    case "False": {
      return true0;
    }

    default: {
      return b satisfies never;
    }
  }
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

const even = (n: Nat): Bool => {
  let n0 = n;

  for (;;) {
    switch (n0.tag) {
      case "O": {
        return true0;
      }

      case "S": {
        switch (n0.arg0.tag) {
          case "O": {
            return false0;
          }

          case "S": {
            n0 = n0.arg0.arg0;
            continue;
          }

          default: {
            return n0.arg0 satisfies never;
          }
        }
      }

      default: {
        return n0 satisfies never;
      }
    }
  }
};

const odd = (n: Nat): Bool => negb(even(n));

const pow = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let m0 = m;

  for (;;) {
    let returned: Nat;

    switch (m0.tag) {
      case "O": {
        returned = s(o);
        break;
      }

      case "S": {
        depth += 1;
        m0 = m0.arg0;
        continue;
      }

      default: {
        returned = m0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = mul(n, returned);
    }
  }
};

const div2 = (n: Nat): Nat => {
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
        switch (n0.arg0.tag) {
          case "O": {
            returned = o;
            break;
          }

          case "S": {
            depth += 1;
            n0 = n0.arg0.arg0;
            continue;
          }

          default: {
            returned = n0.arg0 satisfies never;
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

export const natEven = (x: Nat): Bool => even(x);
export const natOdd = (x: Nat): Bool => odd(x);
export const natDiv2 = (x: Nat): Nat => div2(x);
export const natPow = (x: Nat, x0: Nat): Nat => pow(x, x0);
