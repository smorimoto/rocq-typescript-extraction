const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

const s = (n: number): number => n + 1;

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

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

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

export type Shade<C extends Color> = C extends Red
  ? number
  : C extends Green
    ? boolean
    : List<number>;

export const produce = <C extends Color>(c: C): Shade<C> => {
  switch (c.tag) {
    case "Red": {
      return __magic<number, Shade<C>>(s(s(s(s(s(s(s(0))))))));
    }

    case "Green": {
      return __magic<boolean, Shade<C>>(true);
    }

    case "Blue": {
      return __magic<List<number>, Shade<C>>(cons(s(0), nil));
    }

    default: {
      return c satisfies never;
    }
  }
};

export const consume = <C extends Color>(c: C, x: Shade<C>): number => {
  switch (c.tag) {
    case "Red": {
      return __magic<Shade<C>, number>(x);
    }

    case "Green": {
      return __magic<Shade<C>, boolean>(x) ? s(0) : 0;
    }

    case "Blue": {
      const s0: List<number> = __magic<Shade<C>, List<number>>(x);

      switch (s0.tag) {
        case "Nil": {
          return 0;
        }

        case "Cons": {
          return s0.arg0;
        }

        default: {
          return s0 satisfies never;
        }
      }
    }

    default: {
      return c satisfies never;
    }
  }
};

export const redVal: number = produce(red);
export const greenVal: boolean = produce(green);

export const total: number = add(
  consume(red, s(s(s(s(s(0)))))),
  consume(green, true)
);
