import { gone, plain, Use } from "./ignored-element.ts";
import type { C1, TypeLambda } from "./ignored-element.ts";
import { print } from "./observe.ts";

interface ListLambda extends TypeLambda {
  readonly type: readonly this["Target"][];
}

const Lists: C1<ListLambda> = {
  empty: <A>(): readonly A[] => [],
  map: <A, B>(f: (_: A) => B, xs: readonly A[]): readonly B[] => xs.map(f),
};

console.log(
  "mapping an empty container with an ignored element yields the result"
);

{
  const mapped: readonly boolean[] = Use<ListLambda>(Lists).b;

  print(mapped);
  print(gone);
  print(plain((n: number) => n === 0)(0));
}
