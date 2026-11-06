import { print } from "../observe.ts";
import { origin } from "./origin.ts";
import { fromDot, fromOrigin } from "./separate-known.ts";

console.log("a match on a constant of another file reads it");

print(origin);

print(fromOrigin);

console.log("a match on a constant of the file is its branch");

print(fromDot);
