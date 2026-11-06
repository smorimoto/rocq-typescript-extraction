import * as $Datatypes from "./datatypes.ts";
import * as $KeyImpl from "./key-impl.ts";
import type * as $KeySig from "./key-sig.ts";

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

const { cons, nil, pair, s } = $Datatypes;

export interface PropsResult<T> {
  readonly ofList: <A>(
    l: $Datatypes.List<readonly [number, A]>
  ) => $KeySig.Kind<T, A>;
}

export const Props = <T>(M: $KeySig.MAP<T>): PropsResult<T> => {
  const ofList = <A>(
    l: $Datatypes.List<readonly [number, A]>
  ): $KeySig.Kind<T, A> => {
    const saved: [number][] = [];
    let top = 0;
    const saved0: [A][] = [];
    let top0 = 0;
    let l0 = l;

    for (;;) {
      let returned: $KeySig.Kind<T, A>;

      switch (l0.tag) {
        case "Nil": {
          returned = M.empty<A>();
          break;
        }

        case "Cons": {
          __writeCell(saved, top, l0.arg0[0]);
          top += 1;
          __writeCell(saved0, top0, l0.arg0[1]);
          top0 += 1;
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

        top0 -= 1;
        const saved1: A = __readCell(saved0, top0);
        top -= 1;
        const saved2: number = __readCell(saved, top);
        returned = M.set1(saved2, saved1, returned);
      }
    }
  };

  return { ofList };
};

export interface AssocTLambda extends $KeySig.TypeLambda {
  readonly type: $KeyImpl.AssocT<this["Target"]>;
}

export const P = Props<AssocTLambda>($KeyImpl.Assoc);

export const built: $KeyImpl.AssocTree<boolean> = P.ofList<boolean>(
  cons(pair(s(0), true), cons(pair(s(s(0)), false), nil))
);

export const found: $Datatypes.Option<boolean> = $KeyImpl.Assoc.get0(
  s(s(0)),
  built
);
