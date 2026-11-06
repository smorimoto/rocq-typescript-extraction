import { print } from "../observe.ts";
import { cons, nil, o, pair, s, true0 } from "./datatypes.ts";
import type { List, Nat } from "./datatypes.ts";
import { map } from "./list-def.ts";
import {
  Geometry,
  both,
  double0,
  doubles,
  map as mapPair,
  twice,
} from "./separate.ts";
import type { GeometryFigure } from "./separate.ts";

const toNumber = (n: Nat): number => (n.tag === "O" ? 0 : 1 + toNumber(n.arg0));

const toNumbers = (l: List<Nat>): number[] =>
  l.tag === "Nil" ? [] : [toNumber(l.arg0), ...toNumbers(l.arg1)];

console.log("a module imports the types and constructors of another file");

{
  print(toNumber(double0(s(s(s(o))))));
  const p = both(true0, s(o));
  print({ actual: p.arg0, expected: true0 });
  print(toNumber(p.arg1));
}

console.log("a library of several words is extracted to a kebab-case file");

{
  const l = cons(s(o), cons(s(s(o)), nil));
  print(toNumbers(doubles(l)));
  print(toNumbers(map(double0, l)));
}

console.log(
  "a parameter named after a binding of another file leaves it alone"
);

{
  const l = cons(s(o), cons(s(s(o)), nil));
  print(toNumbers(twice(double0, l)));
  const p = mapPair(double0, pair(s(o), s(s(o))));
  print(toNumber(p.arg0));
  print(toNumber(p.arg1));
}

console.log("a module of the extracted file keeps its object and its types");

{
  const line: GeometryFigure = Geometry.line(s(s(o)));
  print(toNumber(Geometry.len(line)));
  print(toNumber(Geometry.len(Geometry.dot)));
}
