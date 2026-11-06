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

export const app = <A>(l: List<A>, m: List<A>): List<A> => {
  const saved: [A][] = [];
  let top = 0;
  let l0 = l;

  for (;;) {
    let returned: List<A>;

    switch (l0.tag) {
      case "Nil": {
        returned = m;
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
      returned = cons(arg0, returned);
    }
  }
};
