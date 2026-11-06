import { fresh, Tree, Use } from "./member-ctor-clash-poly.ts";
import type { TreeT, TypeLambda } from "./member-ctor-clash-poly.ts";
import { print } from "./observe.ts";

interface TreeLambda extends TypeLambda {
  readonly type: TreeT<this["Target"]>;
}

console.log("a functor calls the polymorphic definition, not the constructor");

print(fresh);

print(Use<TreeLambda>(Tree).fresh);

print(Tree.empty<string>());
