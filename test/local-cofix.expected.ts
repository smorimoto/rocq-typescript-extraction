const __fail = (message: string): never => {
  throw new Error(message);
};

const __lazy = <T>(force: () => T): (() => T) => {
  let cell: { readonly value: T } | undefined;

  return () => {
    if (cell === undefined) {
      cell = { value: force() };
    }

    return cell.value;
  };
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

const boom = (_unused: Nat): Nat =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_LocalCofix.LocalCofix.boom)");

export interface Cons {
  readonly tag: "Cons";
  readonly h: Nat;
  readonly t: Stream;
}

export type Stream = () => Cons;

export const cons = (h: Nat, t: Stream): Cons => ({ h, t, tag: "Cons" });

export interface Red {
  readonly tag: "Red";
}

export interface Green {
  readonly tag: "Green";
}

export interface Blue {
  readonly tag: "Blue";
}

export type Color = Red | Green | Blue;

export const red: Red = { tag: "Red" };
export const green: Green = { tag: "Green" };
export const blue: Blue = { tag: "Blue" };

export const localCofix = (n: Nat, c: Color): Stream =>
  __lazy((): Cons => {
    let result: Nat;

    switch (c.tag) {
      case "Red": {
        result = s(o);
        break;
      }

      case "Green": {
        result = s(s(o));
        break;
      }

      case "Blue": {
        result = n;
        break;
      }

      default: {
        result = c satisfies never;
      }
    }

    return cons(result, localCofix(n, c));
  });

export const wrap = (n: Nat, c: Color): Prod<Nat, Stream> => {
  const s0: Stream = __lazy((): Cons => {
    switch (c.tag) {
      case "Red": {
        return cons(s(o), s0);
      }

      case "Green": {
        return cons(s(s(o)), s0);
      }

      case "Blue": {
        return cons(n, s0);
      }

      default: {
        return c satisfies never;
      }
    }
  });

  return pair(n, s0);
};

export const wrapBoom = (c: Color): Prod<Nat, Stream> => {
  const s0: Stream = __lazy((): Cons => {
    switch (c.tag) {
      case "Red": {
        return cons(s(o), s0);
      }

      case "Green": {
        return cons(s(s(o)), s0);
      }

      case "Blue": {
        return cons(boom(o), s0);
      }

      default: {
        return c satisfies never;
      }
    }
  });

  return pair<Nat, Stream>(o, s0);
};

export const force0 = (s0: Stream): Nat => s0().h;
