import * as $Datatypes from "./datatypes.ts";

const { app, cons, nil } = $Datatypes;

export type ORD = Record<never, never>;

export interface SortingInner<T> {
  readonly filter: (l: $Datatypes.List<T>) => $Datatypes.List<T>;
}

export interface SortingResult<T> {
  readonly sort: (l: $Datatypes.List<T>) => $Datatypes.List<T>;
  readonly Inner: SortingInner<T>;
}

export const Sorting = <T>(_X: ORD): SortingResult<T> => {
  const sort = (l: $Datatypes.List<T>): $Datatypes.List<T> => {
    switch (l.tag) {
      case "Nil": {
        return nil;
      }

      case "Cons": {
        return app(l.arg1, cons(l.arg0, nil));
      }

      default: {
        return l satisfies never;
      }
    }
  };

  const Inner$filter = (l: $Datatypes.List<T>): $Datatypes.List<T> => {
    switch (l.tag) {
      case "Nil": {
        return nil;
      }

      case "Cons": {
        return l.arg1;
      }

      default: {
        return l satisfies never;
      }
    }
  };

  const Inner = {
    filter: Inner$filter,
  } as const;

  return { Inner, sort };
};

export const NatOrd = {} as const;
export const Sort = Sorting<number>(NatOrd);

export const sorted = (x: $Datatypes.List<number>): $Datatypes.List<number> =>
  Sort.sort(x);
