import { print } from "./observe.ts";
import {
  boundMatch,
  boundStatement,
  boundWide,
  constructorBody,
  constructorContext,
  doubles,
  early,
  false0,
  late,
  letInMatchInCall,
  matchOnMatch,
  night,
  nightWeight,
  openingWeight,
  partialOfPair,
  pair,
  shead,
  threeInCond,
  threeUnderCall,
  true0,
  twoMatches,
  wideContext,
} from "./statements.ts";
import { ofNumber, toArray, toNumber } from "./support.ts";

console.log("a match in a branch of a conditional returns from each case");

print(toNumber(threeInCond(true0, late, ofNumber(3))));

print(toNumber(threeInCond(false0, late, ofNumber(3))));

console.log("a call around a match is pushed into its cases");

print(toNumber(threeUnderCall(true0, night, ofNumber(2))));

print(toNumber(threeUnderCall(false0, night, ofNumber(2))));

console.log("a let in a branch stays in its case");

print(toNumber(letInMatchInCall(ofNumber(0), ofNumber(2))));

print(toNumber(letInMatchInCall(ofNumber(3), ofNumber(2))));

console.log("a context that computes reads a variable the cases assign");

print(toNumber(wideContext(ofNumber(2), ofNumber(0))));

print(toNumber(wideContext(ofNumber(2), ofNumber(1))));

print(toNumber(wideContext(ofNumber(2), ofNumber(5))));

console.log("two matches of one call, the first through a variable");

print(toNumber(twoMatches(early, night)));

print(toNumber(twoMatches(late, early)));

console.log("a let bound to a match is assigned in its cases");

print(toNumber(boundMatch(late, ofNumber(2))));

print(toNumber(boundMatch(night, ofNumber(2))));

console.log("a let whose body computes more is assigned in its cases");

print(toNumber(boundWide(late, ofNumber(2))));

print(toNumber(boundWide(night, ofNumber(2))));

console.log("a let whose body binds is assigned in its cases");

print(toNumber(boundStatement(late, ofNumber(2))));

print(toNumber(boundStatement(early, ofNumber(3))));

console.log("a context that holds a constructor reads the assigned variable");

{
  const p = constructorContext(late, ofNumber(2));
  print(toNumber(p.arg0));
  print(toNumber(p.arg1));
  print(toArray(constructorBody(late, ofNumber(2))).map(toNumber));
}

console.log("a match on the result of a match");

print(toNumber(matchOnMatch(early, ofNumber(4))));

print(toNumber(matchOnMatch(night, ofNumber(4))));

console.log("a partial application of a match on a pair");

print(toNumber(partialOfPair(pair(ofNumber(1), ofNumber(2)))(ofNumber(3))));

console.log("a top-level constant whose value is a match");

print(toNumber(nightWeight));

console.log("a top-level match on a constant");

print(toNumber(openingWeight));

console.log("a let in a lazy constructor runs when the cell is forced");

print(toNumber(shead(doubles(ofNumber(3)))));

print(toNumber(shead(doubles(ofNumber(3))().t)));
