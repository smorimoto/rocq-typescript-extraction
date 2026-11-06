import { print } from "../observe.ts";
import { ofArray } from "../support.ts";
import { Outer } from "./nests.ts";
import { dropped, twice } from "./separate-members.ts";
import { sorted } from "./sorts.ts";

console.log("members named like methods of an application of another file");

print(sorted(ofArray([1, 2, 3])));

print(twice(ofArray([1, 2, 3])));

print(dropped(ofArray([1, 2, 3])));

console.log("a functor of another file whose body aliases a nested module");

print(Outer<string>({}).drop(ofArray(["a", "b"])));
