import { print } from "./observe.ts";
import {
  countdown,
  evens,
  from0,
  headOr,
  mapS,
  ones,
  shead,
  stail,
  take,
} from "./streams.ts";
import { ofNumber, toArray, toNumber } from "./support.ts";

console.log("an infinite stream is built lazily and read by prefix");

print(toArray(take(ofNumber(4), from0(ofNumber(3)))).map(toNumber));

print(toArray(take(ofNumber(3), ones)).map(toNumber));

print(toArray(take(ofNumber(3), evens)).map(toNumber));

console.log("head, tail, and map on streams");

{
  const s = from0(ofNumber(7));
  print(toNumber(shead(stail(s))));
  const labels = mapS((n) => `#${toNumber(n)}`, s);
  print(take(ofNumber(2), labels));
}

console.log("a match on a coinductive type with two constructors");

print(toNumber(headOr(ofNumber(9), countdown(ofNumber(2)))));

print(toNumber(headOr(ofNumber(9), countdown(ofNumber(0)))));
