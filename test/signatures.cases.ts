import { print } from "./observe.ts";
import { A, chosen, top } from "./signatures.ts";

const double = (n: number): number => n * 2;

console.log(
  "a member of a module takes the arrows of its declared type, aliases unexpanded"
);

print(A.f(double)(3));

print(A.pick(true, double)(1));

print(A.pick(false, double)(1));

print(A.Deep.d(1));

console.log("a top-level value keeps the arity of its expanded type");

print(top(double, 3));

console.log("a value chosen through the inductive of the sealed module");

print(A.z.tag);

print(chosen(5));

console.log("the schemes into Type are members, those into Prop are not");

print(A.wRect((g) => g(4), 0, A.z));

print(A.wRec((g) => g(4), 0, A.nothing));

print("wInd" in A);

print("wSind" in A);
