import type * as $SolverSig from "./solver-sig.ts";

const Inner = <T>(X: $SolverSig.LAT<T>): $SolverSig.SOLVER<T> => {
  const run = (n: number): T => (n === 0 ? X.bot : X.lub(X.bot, X.bot));

  return { L: X, run };
};

export const Outer = <T>(Y: $SolverSig.LAT<T>): $SolverSig.SOLVER<T> => {
  const DS = Inner<T>(Y);
  const run = (n: number): T => Y.lub(DS.run(n), Y.bot);

  return { L: Y, run };
};
