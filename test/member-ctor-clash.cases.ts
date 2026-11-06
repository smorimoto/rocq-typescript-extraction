import { fresh, Tree } from "./member-ctor-clash.ts";
import { print } from "./observe.ts";

console.log(
  "a functor reads the definition, not the constructor of its letters"
);

print(fresh);

print(Tree.empty);
