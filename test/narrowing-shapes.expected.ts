const s = (n: number): number => n + 1;

export interface Some<A> {
  readonly tag: "Some";
  readonly arg0: A;
}

export interface None {
  readonly tag: "None";
}

export type Option<A> = Some<A> | None;

export const some = <A>(arg0: A): Option<A> => ({ arg0, tag: "Some" });
export const none: None = { tag: "None" };

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

const eqb: (_0: number, _1: number) => boolean = (
  n: number,
  m: number
): boolean => n === m;

export interface Red {
  readonly tag: "Red";
}

export interface Green {
  readonly tag: "Green";
}

export interface Mix {
  readonly tag: "Mix";
  readonly n: number;
}

export type Colour = Red | Green | Mix;

export const red: Red = { tag: "Red" };
export const green: Green = { tag: "Green" };
export const mix = (n: number): Colour => ({ n, tag: "Mix" });

const name = (c: Colour): number => {
  switch (c.tag) {
    case "Red": {
      return 0;
    }

    case "Green": {
      return s(0);
    }

    case "Mix": {
      return c.n;
    }

    default: {
      return c satisfies never;
    }
  }
};

export const local = (_unused: number): number => {
  const c: Colour = green;

  return name(c);
};

export const nested = (k: number): number => {
  const c: Colour = red;

  return add(k, name(c));
};

export const either = (b: boolean): number => {
  const c: Colour = b ? red : green;

  switch (c.tag) {
    case "Red": {
      return 0;
    }

    default: {
      return name(c);
    }
  }
};

const chosen: Colour = eqb(name(green), s(0)) ? red : green;
export const ofChosen: number = chosen.tag === "Red" ? 0 : s(0);

export const swapped = (c0: Colour): number => {
  const c: Colour = c0.tag === "Red" ? green : red;

  switch (c.tag) {
    case "Red": {
      return name(c);
    }

    default: {
      return s(0);
    }
  }
};

const Palette$base: Colour = green;
const Palette$inside: number = s(0);

export const Palette = {
  base: Palette$base,
  inside: Palette$inside,
} as const;

export const outside: number = s(0);

export const again = (c: Colour): number => {
  switch (c.tag) {
    case "Red": {
      return 0;
    }

    case "Green": {
      return s(s(0));
    }

    case "Mix": {
      return c.n;
    }

    default: {
      return c satisfies never;
    }
  }
};

export const rest = (c: Colour): number => {
  switch (c.tag) {
    case "Red": {
      return 0;
    }

    default: {
      switch (c.tag) {
        case "Mix": {
          return c.n;
        }

        default: {
          return s(s(0));
        }
      }
    }
  }
};

const twice = (f: (_: number) => number, n: number): number => f(f(n));

export const later = (c: Colour): number => {
  switch (c.tag) {
    case "Red": {
      return twice((k: number): number => s(k), 0);
    }

    case "Green": {
      return s(0);
    }

    case "Mix": {
      return c.n;
    }

    default: {
      return c satisfies never;
    }
  }
};

export const deeper = (o: Option<Colour>): number => {
  switch (o.tag) {
    case "Some": {
      const s0: Colour = o.arg0;

      switch (s0.tag) {
        case "Red": {
          return twice((k: number): number => {
            switch (o.arg0.tag) {
              case "Red": {
                return s(k);
              }

              case "Green": {
                return 0;
              }

              case "Mix": {
                return o.arg0.n;
              }

              default: {
                return o.arg0 satisfies never;
              }
            }
          }, 0);
        }

        default: {
          return 0;
        }
      }
    }

    case "None": {
      return 0;
    }

    default: {
      return o satisfies never;
    }
  }
};

export const rank: number = s(0);

export const mixed = (b: boolean): number => {
  const c: Colour = b ? red : mix(s(s(s(0))));

  switch (c.tag) {
    case "Red": {
      return name(c);
    }

    case "Green": {
      return s(0);
    }

    case "Mix": {
      return c.n;
    }

    default: {
      return c satisfies never;
    }
  }
};

const four: Colour = mix(s(s(s(s(0)))));

const ofFourOf = (s0: Colour): number => {
  switch (s0.tag) {
    case "Red": {
      return 0;
    }

    case "Green": {
      return s(0);
    }

    case "Mix": {
      return s0.n;
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export const ofFour: number = ofFourOf(four);
