import { print } from "../observe.ts";
import { Fig, scaled, unitArea } from "./separate-aliases.ts";

console.log("values defined through the alias");

print(unitArea);

print(scaled(Fig.square(2), 3));
