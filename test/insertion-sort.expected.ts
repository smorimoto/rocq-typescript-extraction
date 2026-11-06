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

const leb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n <= m;

const insert = (x: number, l: List<number>): List<number> => {
  const saved: [number][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<number>;

    switch (l0.tag) {
      case "Nil": {
        returned = cons(x, nil);
        break;
      }

      case "Cons": {
        if (leb(x, l0.arg0)) {
          returned = cons(x, l0);
        } else {
          __writeCell(saved, top, l0.arg0);
          top += 1;
          l0 = l0.arg1;
          continue;
        }

        break;
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
      const arg0: number = __readCell(saved, top);
      returned = cons(arg0, returned);
    }
  }
};

export const insertionSort = (l: List<number>): List<number> => {
  const saved: [number][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<number>;

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
      const arg0: number = __readCell(saved, top);
      returned = insert(arg0, returned);
    }
  }
};
