import { U1, U2, Use } from "./inline-signature.ts";
import type { FT, SIG, TypeLambda, U1BT, U2BT } from "./inline-signature.ts";
import { print } from "./observe.ts";

interface StringLambda extends TypeLambda {
  readonly type: string;
}

const Shown: FT<StringLambda> = <T>(X: SIG<T>) => ({ z: String(X.z) });

console.log(
  "an inline functor signature lets each implementation pick the result type"
);

{
  const zero: U1BT = U1.z;
  const four: U2BT = U2.z;

  print(zero);
  print(four);
}

console.log("a consumer implements the inline signature with its own lambda");

{
  const shown: string = Use<StringLambda, number>(Shown)({ z: 3 }).z;

  print(shown);
}
