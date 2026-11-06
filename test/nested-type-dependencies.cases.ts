import { Applied, Use, Values } from "./nested-type-dependencies.ts";
import type { UseResult0 } from "./nested-type-dependencies.ts";
import { print } from "./observe.ts";

console.log("a function retains its nested functor parameter capture");

{
  const supplied = Use({ Base: { value: "payload" } });

  print(Applied.read(0));
  print(supplied.read(0));
}

console.log("constructor fields retain transitive abstract type dependencies");

{
  const result: UseResult0<number> = Applied.result(Values.wrapped(7));

  print(result);
  print(Applied.noResult);
}
