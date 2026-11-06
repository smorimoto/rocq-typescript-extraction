import { go, MakeTac } from "./applied-module-type.ts";
import { print } from "./observe.ts";

console.log(
  "a parameter declared with an applied module type reads its members"
);

{
  print(go);
  const strings = MakeTac<string>({})({ leTotal: (x, y) => x <= y });
  print(strings.cmp("b", "a"));
}
