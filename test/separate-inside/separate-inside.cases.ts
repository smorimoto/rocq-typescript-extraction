import { print } from "../observe.ts";
import { M } from "./separate-inside.ts";

console.log("a module open at the command holds what it declares so far");

print(M.x);

print(M.N.y);

print(Object.keys(M));
