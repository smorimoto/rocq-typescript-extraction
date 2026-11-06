import { print } from "../observe.ts";
import type { FT, SIG, TypeLambda } from "./result-sigs.ts";
import { U1, U2, Use } from "./separate-results.ts";
import type { U2B2T } from "./separate-results.ts";

interface StringLambda extends TypeLambda {
  readonly type: string;
}

const Shown: FT<StringLambda> = <T>(X: SIG<T>) => ({ z: String(X.z) });

console.log("applications to the implementations of another file");

{
  const yes: U2B2T = U2.both[1];

  print(U1.both);
  print(U2.both);
  print(yes);
}

console.log("a consumer lambda extends the TypeLambda of the signature's file");

print(Use<StringLambda, number>(Shown)({ z: 3 }).both);
