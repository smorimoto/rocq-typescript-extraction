import { go, Outer } from "./nested-alias.ts";
import { print } from "./observe.ts";
import { ofArray, toArray } from "./support.ts";

console.log(
  "an alias of a module nested in an application reaches its members"
);

{
  print(go);
  const strings = Outer<string>({});
  print(toArray(strings.join(ofArray(["a"]), ofArray(["b", "c"]))));
  print(toArray(strings.Raw.concat(ofArray(["d"]), ofArray([]))));
}
