import { print } from "../observe.ts";
import { nil } from "./datatypes.ts";
import { Assoc } from "./key-impl.ts";
import { built, found, P } from "./separate-keys.ts";

console.log(
  "a functor over the module type of another file reads the module's members"
);

print(built);

print(found);

print(P.ofList(nil));

console.log(
  "the module keeps its own set0 and empty beside the renamed set and Empty"
);

print(Assoc.set0(4, "x"));

print(Assoc.empty());
