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

export interface Idle {
  readonly tag: "Idle";
}

export interface Handle<A> {
  readonly tag: "Handle";
  readonly f: (_: A) => number;
}

export type Handler<A> = Idle | Handle<A>;

export const idle: Idle = { tag: "Idle" };

export const handle = <A>(f: (_: A) => number): Handler<A> => ({
  f,
  tag: "Handle",
});

export const quiet: Handler<number> = idle;

export const run = (h: Handler<number>, x: number): number => {
  switch (h.tag) {
    case "Idle": {
      return 0;
    }

    case "Handle": {
      return h.f(x);
    }

    default: {
      return h satisfies never;
    }
  }
};

export const handlers: List<Handler<number>> = cons<Handler<number>>(
  idle,
  cons<Handler<number>>(
    handle((x: number): number => s(x)),
    nil
  )
);

export const three: number = run(idle, s(s(s(0))));
