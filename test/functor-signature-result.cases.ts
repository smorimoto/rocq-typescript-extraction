import { AG, P, U1, U2, Use } from "./functor-signature-result.ts";
import type {
  FT,
  SIG,
  TypeLambda,
  U1BT,
  U2B2T,
  U2BT,
} from "./functor-signature-result.ts";
import { print } from "./observe.ts";

interface StringLambda extends TypeLambda {
  readonly type: string;
}

const Shown: FT<StringLambda> = <T>(X: SIG<T>) => ({ z: String(X.z) });

console.log("each implementation picks the type left in the result");

{
  const zero: U1BT = U1.z;
  const seven: U2BT = U2.z;
  const yes: U2B2T = U2.both[1];

  print(zero);
  print(seven);
  print(yes);
  print(U1.both);
  print(U2.both);
}

console.log("a functor passes its parameter on, and an application is partial");

print(AG.again);

print(P<string>({ z: "s" }).z);

print(P<string>({ z: "s" }).both);

console.log("a consumer implements the signature with its own lambda");

{
  const S = Use<StringLambda, number>(Shown)({ z: 3 });
  const three: string = S.z;

  print(three);
  print(S.both);
}
