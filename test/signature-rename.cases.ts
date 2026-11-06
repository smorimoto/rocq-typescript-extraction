import { print } from "./observe.ts";
import { F, go, M } from "./signature-rename.ts";
import { ofArray } from "./support.ts";

console.log("a functor calls the member that the module type names");

print(go);

print(F(M).go(ofArray([2])));

console.log("a member keeps its own name beside one renamed onto it");

print(M.set0(3));
