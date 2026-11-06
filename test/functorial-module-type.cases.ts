import { go, Use } from "./functorial-module-type.ts";
import { print } from "./observe.ts";

console.log("a functor over a module type that includes an application");

print(go);

print(Use<boolean>({ bot: false })({ get0: () => true }).run(0));
