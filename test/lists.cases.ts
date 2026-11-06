import {
  cons,
  doubled,
  empty,
  eqb,
  firsts,
  leb,
  max,
  middle,
  nextHead,
  nil,
  order,
  pair,
  preds,
  safeHead,
  sum,
  swapPair,
  third,
  total,
} from "./lists.ts";
import { print } from "./observe.ts";
import { ofArray, ofNumber, toArray, toNumber } from "./support.ts";

const nats = (xs: number[]) => ofArray(xs.map(ofNumber));

console.log("option: safeHead distinguishes the empty list");

print(safeHead(nil));

print(safeHead(cons("a", nil)));

console.log("prod: swapPair exchanges the components");

print({ actual: swapPair(pair(1, true)), expected: pair(true, 1) });

console.log("list recursion and Corelib list functions");

print(toNumber(sum(nats([1, 2, 3]))));

print(toArray(firsts).map(toNumber));

print(toArray(doubled).map(toNumber));

print(toArray(middle).map(toNumber));

print(toNumber(third));

print(toNumber(total));

print(empty<number>());

console.log("Corelib arithmetic on nat");

print(nextHead.tag === "Some" && toNumber(nextHead.arg0));

print(order.tag);

print(eqb(ofNumber(2), ofNumber(2)).tag);

print(eqb(ofNumber(2), ofNumber(3)).tag);

print(leb(ofNumber(3), ofNumber(2)).tag);

print(toNumber(max(ofNumber(3), ofNumber(5))));

console.log("a lambda whose body binds a scrutinee has a block body");

print(toArray(preds).map(toNumber));
