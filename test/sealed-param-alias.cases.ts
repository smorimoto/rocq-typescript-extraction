import { print } from "./observe.ts";
import { go, Solver } from "./sealed-param-alias.ts";

console.log(
  "a sealed functor returns its parameter as the alias the constraint names"
);

{
  print(go);
  const strings = Solver({ bot: "b" });
  print(strings.run(0));
  print(strings.L.bot);
}
