Generated arrays, generic arrows, and const assertions are accepted.

  $ cat > allowed.ts <<'TS'
  > const saved: Treeʹ<A>[] = [];
  > const nested: Treeʹ<List<A>>[] = [];
  > const identity = <A>(value: A): A => value;
  > const literal = { tag: "Leaf" } as const;
  > TS
  $ sh no_assertions.sh allowed.ts

Angle-bracket casts are rejected, including Rocq apostrophes in type names.

  $ echo 'const value = <Tree<A>>other;' > rejected.ts
  $ sh no_assertions.sh rejected.ts
  1:const value = <Tree<A>>other;
  rejected.ts: an angle-bracket type assertion
  [1]
  $ echo 'const value = <Treeʹ<A>>other;' > rejected.ts
  $ sh no_assertions.sh rejected.ts
  1:const value = <Treeʹ<A>>other;
  rejected.ts: an angle-bracket type assertion
  [1]

Type assertions and non-null assertions are rejected.

  $ echo 'const value = other as Tree<A>;' > rejected.ts
  $ sh no_assertions.sh rejected.ts
  1:const value = other as Tree<A>;
  rejected.ts: a type assertion with as
  [1]
  $ echo 'const value = other!.field;' > rejected.ts
  $ sh no_assertions.sh rejected.ts
  1:const value = other!.field;
  rejected.ts: a non-null assertion
  [1]
