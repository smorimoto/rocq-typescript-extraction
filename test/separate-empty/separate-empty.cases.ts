import { print } from "../observe.ts";
import { pick, twice } from "./separate-empty.ts";

console.log("a file uses the types of a library from which nothing remains");

print(twice((n) => n + 1, 3));

print(pick((b) => (b ? 1 : 0))(true));
