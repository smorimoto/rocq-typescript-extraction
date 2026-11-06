import { B, count, D, Holder, same, three, v } from "./applications.ts";
import type { BWrapped } from "./applications.ts";
import { print } from "./observe.ts";

console.log("an application is the functor applied to the module");

print(v);

print(B.twice(1));

print(B.unwrap(B.empty));

console.log("the types of an application are aliases of the functor's");

{
  const none: BWrapped = B.empty;
  print(three);

  print(count(none));
  print(count(three));
}

console.log("a two-parameter functor is applied one argument at a time");

print(D.step);

print(D.other);

console.log("an application in a module is a member of its object");

print(Holder.B.same);

print(same);
