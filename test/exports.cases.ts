import * as exports from "./exports.ts";
import { print } from "./observe.ts";

console.log("only the requested function is exported");

print(Object.keys(exports));

console.log("the private helper, type, and realisers still serve it");

print(exports.measure(0));

print(exports.measure(4));
