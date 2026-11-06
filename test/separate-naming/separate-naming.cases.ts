import { print } from "../observe.ts";
import { corners } from "./separate-naming.ts";
import { square, triangle } from "./shapes.ts";

console.log("a value of a file whose import alias is renamed");

print(corners(triangle));

print(corners(square));
