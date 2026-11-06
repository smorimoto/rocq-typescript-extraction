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

const mul: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n * m;

const sub: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => (n > m ? n - m : 0);

export interface Form0 {
  readonly tag: "Shape";
  readonly sides: number;
}

export interface Blob {
  readonly tag: "Blob";
  readonly form: number;
}

export type Form = Form0 | Blob;

export const form = (sides: number): Form => ({ sides, tag: "Shape" });
export const blob = (form0: number): Form => ({ form: form0, tag: "Blob" });

export const formArea = (s0: Form): number => {
  switch (s0.tag) {
    case "Shape": {
      return mul(s0.sides, s0.sides);
    }

    case "Blob": {
      return s0.form;
    }

    default: {
      return s0 satisfies never;
    }
  }
};

export interface FrameT {
  readonly form: number;
  readonly border: number;
}

const Frame$form = (t: FrameT): number => t.form;
const Frame$border = (t: FrameT): number => t.border;
const Frame$inner = (f: FrameT): number => sub(f.form, f.border);

export const Frame = {
  border: Frame$border,
  form: Frame$form,
  inner: Frame$inner,
} as const;

export interface Hold<Form1> {
  readonly tag: "Hold";
  readonly held: Form1;
}

export interface Empty {
  readonly tag: "Empty";
}

export type Holder<Form1> = Hold<Form1> | Empty;

export const hold = <Form1>(held: Form1): Holder<Form1> => ({
  held,
  tag: "Hold",
});

export const empty: Empty = { tag: "Empty" };
export const twice = (form0: number): number => add(form0, form0);
export const reform = (n: number): Holder<number> => hold(n);
export const reform0 = (n: number): number => s(n);

export const formS: List<Form> = cons<Form>(
  form(s(s(0))),
  cons<Form>(blob(s(s(s(s(s(0)))))), nil)
);

const Forms$unitSquare: Form = form(s(0));

export const Forms = {
  unitSquare: Forms$unitSquare,
} as const;
