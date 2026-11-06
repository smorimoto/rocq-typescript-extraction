const __fail = (message: string): never => {
  throw new Error(message);
};

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

export interface Key {
  readonly brand: unique symbol;
}

export const makeKey = (_unused: number): Key =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.make_key)");

export const keyId = (_unused: Key): number =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.key_id)");

export const roundtrip = (n: number): number => keyId(makeKey(n));

export interface Box<X> {
  readonly brand: unique symbol;
  readonly variance: (_: X) => X;
}

export const wrap = <A>(_unused: A): Box<A> =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.wrap)");

export const size = <A>(_unused: Box<A>): number =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.size)");

export const boxed = (n: number): number => size(wrap(n));

export interface Table<X, X0> {
  readonly brand: unique symbol;
  readonly variance: (_: readonly [X, X0]) => readonly [X, X0];
}

export const lookup = <A, B>(_unused: Table<A, B>, _unused0: A): Option<B> =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.lookup)");

export interface Tagged<X, X0> {
  readonly brand: unique symbol;
  readonly variance: (_: readonly [X, X0]) => readonly [X, X0];
}

export const retag = <A, B>(_unused: Tagged<A, B>): Tagged<B, A> =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.retag)");

export interface Wide<X, X0, X1, X2, X3, X4, X5> {
  readonly brand: unique symbol;
  readonly variance: (
    _: readonly [X, X0, X1, X2, X3, X4, X5]
  ) => readonly [X, X0, X1, X2, X3, X4, X5];
}

export interface Elt {
  readonly brand: unique symbol;
}

export const dup = (_unused: Elt): readonly [Elt, Elt] =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.dup)");

export interface Token {
  readonly brand: unique symbol;
}

const tokenOf = (_unused: number): Token =>
  __fail("AXIOM TO BE REALIZED (Dune_Extraction_Axioms.Axioms.token_of)");

export const tokens = (n: number): List<Token> => cons(tokenOf(n), nil);

export interface Secret {
  readonly brand: unique symbol;
}

export const reveal = (s0: Secret): List<Secret> => cons(s0, nil);
