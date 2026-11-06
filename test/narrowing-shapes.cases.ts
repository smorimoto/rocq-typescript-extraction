import {
  Palette,
  again,
  deeper,
  either,
  green,
  later,
  local,
  mix,
  mixed,
  nested,
  none,
  ofChosen,
  ofFour,
  outside,
  rank,
  red,
  rest,
  some,
  swapped,
} from "./narrowing-shapes.ts";
import { print } from "./observe.ts";

console.log("a match on a local or a global known to be one constructor");

print(local(5));

print(nested(2));

print({ actual: Palette.base, expected: green });

print(Palette.inside);

print(outside);

print(rank);

console.log("a match on a term known to be one of two constructors");

print(either(true));

print(either(false));

print(ofChosen);

print(swapped(red));

print(swapped(green));

print(swapped(mix(5)));

console.log("a match on a variable that an enclosing branch narrows");

print([again(red), again(green), again(mix(7))]);

print([rest(red), rest(green), rest(mix(4))]);

print([later(red), later(green), later(mix(3))]);

print([deeper(some(red)), deeper(some(green)), deeper(none)]);

console.log("a match on a term that is not narrowed keeps every branch");

print(mixed(true));

print(mixed(false));

print(ofFour);
