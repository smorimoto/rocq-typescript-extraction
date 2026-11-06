import * as $Datatypes from "./datatypes.ts";

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

const { cons, nil } = $Datatypes;

export interface TypeLambda {
  readonly Target: unknown;
  readonly type: unknown;
}

export type Kind<F, A> = F extends TypeLambda
  ? (F & { readonly Target: A })["type"]
  : never;

export interface CONTAINER<T> {
  readonly empty: <A>() => Kind<T, A>;
  readonly map: <A, B>(_0: (_: A) => B, _1: Kind<T, A>) => Kind<T, B>;
}

export interface UseResult<T> {
  readonly e: Kind<T, number>;
  readonly twice: <A>(f: (_: A) => A, x: Kind<T, A>) => Kind<T, A>;
}

export const Use = <T>(C: CONTAINER<T>): UseResult<T> => {
  const { map } = C;
  const e: Kind<T, number> = C.empty<number>();

  const twice = <A>(f: (_: A) => A, x: Kind<T, A>): Kind<T, A> =>
    map(f, map(f, x));

  return { e, twice };
};

export type LT<A> = $Datatypes.List<A>;

const L$empty = <A>(): $Datatypes.List<A> => nil;

const L$map = <A, B>(
  f: (_: A) => B,
  l: $Datatypes.List<A>
): $Datatypes.List<B> => {
  const saved: [A][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: $Datatypes.List<B>;

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

export const L = {
  empty: L$empty,
  map: L$map,
} as const;
