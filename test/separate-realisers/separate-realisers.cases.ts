import { print } from "../observe.ts";
import { Box } from "./boxes.ts";
import { bigger, contents, filled } from "./separate-realisers.ts";

console.log("a file builds and matches a module type of another file");

print(contents(filled(3)));

print(contents(-1));

print(contents(bigger(filled(3))));

print(contents(bigger(-1)));

console.log("the module object of the other file holds the realisers it calls");

print(Box.full(4));

print(
  Box.matchBox(
    () => "empty",
    (n) => `full ${n}`,
    Box.full(4)
  )
);
