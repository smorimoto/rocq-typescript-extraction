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

export const keepB = (x: number): number => x;

export const collide = <B0 extends boolean>(
  b: B0
): B0 extends true ? number : boolean =>
  b
    ? __magic<number, B0 extends true ? number : boolean>(0)
    : __magic<boolean, B0 extends true ? number : boolean>(false);

export const snake = <IsNum extends boolean>(
  isNum: IsNum
): IsNum extends true ? number : boolean =>
  isNum
    ? __magic<number, IsNum extends true ? number : boolean>(0)
    : __magic<boolean, IsNum extends true ? number : boolean>(false);

export const afterNat = <B0 extends boolean>(
  n: number,
  b: B0
): B0 extends true ? number : boolean =>
  b
    ? __magic<number, B0 extends true ? number : boolean>(n)
    : __magic<boolean, B0 extends true ? number : boolean>(true);

export const callAfter: number = afterNat(s(s(s(s(s(0))))), true);

export const polyDep = <A, B0 extends boolean>(
  x: A,
  b: B0
): B0 extends true ? A : boolean =>
  b
    ? __magic<A, B0 extends true ? A : boolean>(x)
    : __magic<boolean, B0 extends true ? A : boolean>(false);

export const callPoly: number = polyDep(s(s(s(s(s(s(s(0))))))), true);

export const twoFlags = <A extends boolean, B0 extends boolean>(
  a: A,
  b: B0
): A extends true ? number : B0 extends true ? boolean : List<number> => {
  if (a) {
    return __magic<
      number,
      A extends true ? number : B0 extends true ? boolean : List<number>
    >(s(s(s(0))));
  }

  return b
    ? __magic<
        boolean,
        A extends true ? number : B0 extends true ? boolean : List<number>
      >(true)
    : __magic<
        List<number>,
        A extends true ? number : B0 extends true ? boolean : List<number>
      >(cons(s(0), nil));
};

export const callTwo: List<number> = twoFlags(false, false);
