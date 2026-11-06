import * as constructors from "./constructors.ts";
import { print } from "./observe.ts";

console.log(
  "a constructor the command names is exported with its type and the other builders"
);

{
  print(Object.keys(constructors).toSorted());
  const line: constructors.Figure = constructors.line(3);
  print(line);
  const narrow: constructors.Line = { n: 3, tag: "Line" };
  print({ actual: line, expected: narrow });
}

console.log("a constructor of a mapped type exports its realiser");

print(constructors.s(41));

console.log("a match on a const initialised by a constructor call");

print(constructors.area);
