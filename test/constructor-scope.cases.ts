import { got } from "./constructor-scope.ts";
import { print } from "./observe.ts";

console.log("a constructor that ignores the argument builds the value");

print(got);
