import { G, GA, GS, GSA } from "./functor-as-module.ts";
import { print } from "./observe.ts";

console.log("a functor defined as a module returns the module");

print(G<string>({ z: "s" }).z);

print(GS<string>({ z: "s" }).z);

print(GA.z);

print(GSA.z);
