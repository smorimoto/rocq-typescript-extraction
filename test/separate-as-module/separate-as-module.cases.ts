import { print } from "../observe.ts";
import { G, Id } from "./as-module.ts";
import { all, H } from "./separate-as-module.ts";

console.log(
  "functors of another file defined as a module and as their parameter"
);

print(all);

print(G<string>({ z: "s" }).z);

print(Id<string>({ z: "s" }).z);

print(H<null>({ z: null }).z);
