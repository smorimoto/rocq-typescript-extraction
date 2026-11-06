import { print } from "./observe.ts";
import { bucket, scrambled } from "./short-circuit.ts";

console.log("a scrutinee that the tests read twice is computed once");

print(scrambled(0));

print(scrambled(1));

console.log("each branch of a small let returns its body");

print(bucket(0));

print(bucket(4));
