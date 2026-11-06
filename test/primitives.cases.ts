import { print } from "./observe.ts";
import {
  answer,
  describe as describeNumber,
  greet,
  greetLength,
  greeting,
  half,
  horizontal,
  isAnswer,
  maxInt,
  minusZero,
  square,
  sum,
  third,
} from "./primitives.ts";

console.log("int63 literals are bigints, operations go through the preset");

print(answer);

print(maxInt);

print(sum(2n, 3n));

print(sum(maxInt, 1n));

print(sum(2n ** 62n, 1n));

print(square(12n));

console.log("a match on bool extracted to boolean without a match function");

print(isAnswer(42n));

print(describeNumber(42n));

print(describeNumber(7n));

console.log("a primitive string keeps one UTF-16 code unit per byte");

print(greeting.length);

print(greeting.codePointAt(1));

print(greeting.codePointAt(2));

print({ actual: greet("bob"), expected: `${greeting}bob` });

print(greetLength("bob"));

console.log("float literals are numbers, including a negative zero");

print(half);

print(third);

print(Object.is(minusZero, -0));

console.log("a match on a generated union gives a boolean under the preset");

print(horizontal);
