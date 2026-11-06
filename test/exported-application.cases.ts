import { B, F } from "./exported-application.ts";
import type { BBox, FResult, S } from "./exported-application.ts";
import { print } from "./observe.ts";

console.log(
  "an exported application exports its functor, its module type, and its types"
);

{
  const mine: S<string> = { z: "" };
  const m: FResult<string> = F<string>(mine);
  const b: BBox = B.w;
  print(m.w);
  print(m.boxRect((x) => x.length, "abc"));
  print(b);
}
