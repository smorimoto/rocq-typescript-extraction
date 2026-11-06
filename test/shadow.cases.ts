import { print } from "./observe.ts";
import { B, P } from "./shadow.ts";

console.log("a body module named like a top-level module does not shadow it");

print(P.z);

print(B.n);

print(B.P.n);
