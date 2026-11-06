import { print } from "../observe.ts";
import { fibIter } from "./loop.ts";

console.log("fibIter updates its accumulators from their previous values");

print(fibIter(78, 0, 1));
