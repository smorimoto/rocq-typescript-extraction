import { both, go, Props, Q, Use, used } from "./functor-param-t.ts";
import type { TypeLambda } from "./functor-param-t.ts";
import { print } from "./observe.ts";

interface ArrayLambda extends TypeLambda {
  readonly type: readonly this["Target"][];
}

console.log("a parameter named like a type parameter of its functor");

print(go);

print(both);

print(used);

print(Q({ x: "q" }).y(0));

print(Use((T) => ({ y: () => T.x })).go);

print(Props<ArrayLambda>({ empty: () => [] }).fresh<number>());
