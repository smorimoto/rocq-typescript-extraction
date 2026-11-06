import { Correct, go, Main } from "./functorial-type-applied.ts";
import { print } from "./observe.ts";

console.log(
  "a functor applied in a body to a parameter typed by an applied module type"
);

print(go);

print(Main({ bot: "m" }).run(0));

print(Correct({ bot: 1 })({ get0: (n) => n + 1 }).checked(2));
