import { mapped, sorted, Sorting, twice } from "./method-member.ts";
import { print } from "./observe.ts";
import { ofArray } from "./support.ts";

console.log(
  "module methods preserve their results through direct calls and bindings"
);

print(sorted(ofArray([1, 2, 3])));

print(mapped(ofArray([1, 2])));

print(twice(ofArray([1, 2])));

console.log("a consumer calls an unrestricted method directly");

print(Sorting<string>({}).sort(ofArray(["a", "b", "c"])));
