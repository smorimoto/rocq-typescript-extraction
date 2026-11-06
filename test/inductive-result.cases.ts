import { U, Use, Wrap } from "./inductive-result.ts";
import type { FT, SIG, TypeLambda, UBT, WrapRaw } from "./inductive-result.ts";
import { print } from "./observe.ts";

interface StringLambda extends TypeLambda {
  readonly type: string;
}

const Shown: FT<StringLambda> = <T>(X: SIG<T>) => ({ z: String(X.z) });

console.log(
  "an inductive result carries the argument and the constant constructor"
);

{
  const stop: UBT = U.z;
  const made: WrapRaw<number> = Wrap<number>({ z: 1 }).make(4);

  print(stop);
  print(made);
}

console.log("a consumer implements the signature with its own lambda");

{
  const shown: string = Use<StringLambda, number>(Shown)({ z: 3 }).z;

  print(shown);
}
