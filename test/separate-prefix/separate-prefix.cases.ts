import { print } from "../observe.ts";
import { swapTwice } from "./pair-ext.ts";
import { swap } from "./pair.ts";
import { flipped, same } from "./separate-prefix.ts";

console.log("a file uses two libraries whose names share a prefix");

print(flipped([1, 2]));

print(same([1, 2]));

print(swap([3, 4]));

print(swapTwice([3, 4]));
