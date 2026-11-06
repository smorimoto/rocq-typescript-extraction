import {
  bucket,
  bucketWide,
  pairInPartial,
  predecessorInCond,
} from "./inline-statements.ts";
import { print } from "./observe.ts";

console.log("a let bound to an inline match is assigned in a chain of tests");

print(bucket(0));

print(bucket(1));

print(bucket(5));

console.log("a context that computes reads a variable the tests assign");

print(bucketWide(0, 1));

print(bucketWide(1, 1));

print(bucketWide(5, 1));

console.log("a call around an inline match returns from each test");

print(predecessorInCond(true, 0));

print(predecessorInCond(true, 4));

print(predecessorInCond(false, 4));

console.log("a partial application of a match on a tuple");

print(pairInPartial(2)(1));
