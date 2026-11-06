import {
  brokenReturned,
  inBlock,
  initialiser,
  longInBlock,
  longInitialiser,
  longNested,
  longNullary,
  longReturned,
  longestReturned,
  longThreeLinks,
  longWideCallee,
  longWithArrow,
  longWithTypeArguments,
  nested,
  nullary,
  returned,
  staged,
  threeLinks,
  Through,
  wideCallee,
  withArrow,
  withTypeArguments,
} from "./curried-calls.ts";
import { print } from "./observe.ts";

console.log("a staged function squares its first argument and adds the second");

{
  const plusNine = staged(3);
  print(plusNine(1));
  print(plusNine(2));
}

console.log("a call of a call as an initialiser");

print(initialiser);

print(longInitialiser);

console.log("a call of a call as a returned value, on one line and broken");

for (const f of [returned, longReturned, longestReturned, brokenReturned]) {
  print(f(1, 2));
}

print(inBlock(1, 2));

print(longInBlock(1, 2));

console.log("a call of a call as an argument");

print(nested(1, 2));

print(longNested(1, 2));

console.log(
  "type arguments, an arrow argument, three links, and a wide callee"
);

print(withTypeArguments(2));

print(longWithTypeArguments(2));

print(withArrow(2));

print(longWithArrow(2));

print(threeLinks(1, 2));

print(longThreeLinks(1, 2));

print(wideCallee(2, 5));

print(longWideCallee(2, 5));

console.log("a nullary call as the first argument");

print(nullary(1));

print(longNullary(1));

console.log("a member of a functor parameter as the callee");

{
  const through = Through({
    staged: (n) => (m) => n + m,
    triple: (n) => n * 2,
  });

  print(through.member(3, 4));
  print(through.longMember(3, 4));
  print(through.longestMember(3, 4));
}
