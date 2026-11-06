const __readCell = <T>(cells: readonly (readonly [T])[], index: number): T => {
  const cell = cells[index];

  if (cell === undefined) {
    throw new Error("Invalid continuation stack access");
  }

  return cell[0];
};

const __writeCell = <T>(cells: [T][], index: number, value: T): void => {
  const cell = cells[index];

  if (cell === undefined) {
    cells[index] = [value];
  } else {
    cell[0] = value;
  }
};

export interface TypeLambda {
  readonly Target: unknown;
  readonly Target1: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

export type Kind2<F, A, B> = F extends TypeLambda
  ? (F & { readonly Target: A; readonly Target1: B })["type"]
  : never;

const s = (n: number): number => n + 1;
const pair = <A, B>(a: A, b: B): readonly [A, B] => [a, b];

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

export interface CONTAINER<T> {
  readonly empty: <A>() => Kind<T, A>;
  readonly map: <A, B>(_0: (_: A) => B, _1: Kind<T, A>) => Kind<T, B>;
}

export interface MAP<T> {
  readonly empty: <A, B>() => Kind2<T, A, B>;
  readonly add: <A, B>(_0: A, _1: B, _2: Kind2<T, A, B>) => Kind2<T, A, B>;
}

export type UseBoxed<T> = Kind<T, number>;

export interface UseResult<T> {
  readonly boxedRect: <A>(
    box0: (_: Kind<T, number>) => A,
    x: Kind<T, number>
  ) => A;
  readonly boxedRec: <A>(
    box0: (_: Kind<T, number>) => A,
    x: Kind<T, number>
  ) => A;
  readonly e: Kind<T, number>;
  readonly twice: <A>(f: (_: A) => A, x: Kind<T, A>) => Kind<T, A>;
  readonly succs: Kind<T, number>;
  readonly box: Kind<T, number>;
}

export const Use = <T>(C: CONTAINER<T>): UseResult<T> => {
  const { map } = C;

  const boxedRect = <A>(
    box0: (_: Kind<T, number>) => A,
    x: Kind<T, number>
  ): A => box0(x);

  const boxedRec = <A>(
    box0: (_: Kind<T, number>) => A,
    x: Kind<T, number>
  ): A => box0(x);

  const e: Kind<T, number> = C.empty<number>();

  const twice = <A>(f: (_: A) => A, x: Kind<T, A>): Kind<T, A> =>
    map(f, map(f, x));

  const succs: Kind<T, number> = twice((x: number): number => s(x), e);
  const box: Kind<T, number> = succs;

  return { box, boxedRec, boxedRect, e, succs, twice };
};

export interface PairsResult<T> {
  readonly one: Kind2<T, number, boolean>;
}

export const Pairs = <T>(M: MAP<T>): PairsResult<T> => {
  const one: Kind2<T, number, boolean> = M.add(
    s(0),
    true,
    M.empty<number, boolean>()
  );

  return { one };
};

export type AgainUBoxed<T> = UseBoxed<T>;

export interface AgainResult<T> {
  readonly U: UseResult<T>;
  readonly again: Kind<T, number>;
}

export const Again = <T>(C: CONTAINER<T>): AgainResult<T> => {
  const U0 = Use<T>(C);
  const again: Kind<T, number> = U0.e;

  return { U: U0, again };
};

export interface ListLambda extends TypeLambda {
  readonly type: List<this["Target"]>;
}

export interface FixedResult {
  readonly xs: List<number>;
}

export const Fixed = (C: CONTAINER<ListLambda>): FixedResult => {
  const { map } = C;
  const xs0: List<number> = map((x: number): number => s(x), cons(s(0), nil));

  return { xs: xs0 };
};

export type LT<A> = List<A>;

const L$empty = <A>(): List<A> => nil;

const L$map = <A, B>(f: (_: A) => B, l: List<A>): List<B> => {
  const saved: [A][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<B>;

    switch (l0.tag) {
      case "Nil": {
        returned = nil;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, l0.arg0);
        top += 1;
        l0 = l0.arg1;
        continue;
      }

      default: {
        returned = l0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: A = __readCell(saved, top);
      returned = cons(f(arg0), returned);
    }
  }
};

const L = {
  empty: L$empty,
  map: L$map,
} as const;

export type PT<K, V> = List<readonly [K, V]>;

const P$empty = <A, B>(): List<readonly [A, B]> => nil;

const P$add = <A, B>(
  k: A,
  v: B,
  m: List<readonly [A, B]>
): List<readonly [A, B]> => cons(pair(k, v), m);

const P = {
  add: P$add,
  empty: P$empty,
} as const;

export interface LTLambda extends TypeLambda {
  readonly type: LT<this["Target"]>;
}

export type UBoxed = UseBoxed<LTLambda>;

export const U = Use<LTLambda>(L);

export interface PTLambda extends TypeLambda {
  readonly type: PT<this["Target"], this["Target1"]>;
}

export const PP = Pairs<PTLambda>(P);

export type ALUBoxed = AgainUBoxed<LTLambda>;

export const AL = Again<LTLambda>(L);
export const FL = Fixed(L);
export const total: List<number> = U.succs;
export const boxed: List<number> = U.box;
export const ones: List<readonly [number, boolean]> = PP.one;
export const xs: List<number> = FL.xs;
