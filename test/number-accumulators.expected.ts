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

const Z$add: (_0: number, _1: number) => number = (
  x: number,
  y: number
): number => x + y;

export const sumRight = (xs: List<number>): number => {
  const saved: [number][] = [];
  let top = 0;
  let xs0 = xs;

  for (;;) {
    let returned: number;

    switch (xs0.tag) {
      case "Nil": {
        returned = 0;
        break;
      }

      case "Cons": {
        __writeCell(saved, top, xs0.arg0);
        top += 1;
        xs0 = xs0.arg1;
        continue;
      }

      default: {
        returned = xs0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const arg0: number = __readCell(saved, top);
      returned = Z$add(arg0, returned);
    }
  }
};
