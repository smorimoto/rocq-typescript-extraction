import { print } from "../observe.ts";
import { ofArray, ofNumber, toArray, toNumber } from "../support.ts";
import { keep, same, sames } from "./separate-types.ts";

console.log("a file that names only types of another file still runs");

print(toNumber(same(ofNumber(2))));

print({
  actual: keep({ default: ofNumber(0), items: [] }),
  expected: {
    default: ofNumber(0),
    items: [],
  },
});

print(toArray(sames(ofArray([ofNumber(1), ofNumber(3)]))).map(toNumber));
