import {
  Outer,
  Tip,
  Word0,
  _1,
  accent,
  box,
  cfg,
  depth,
  else0,
  error,
  fooBar,
  fooBar0,
  horizontal,
  indexed,
  klass,
  klassSize,
  map,
  mkA,
  new0,
  o,
  ok,
  old,
  pick,
  primed,
  s,
  s0,
  set0,
  still,
  tagged,
  then0,
  twice,
  unbox,
  untag,
  x0,
  x1,
  y_00bd,
} from "./naming.ts";
import type {
  Date0,
  Error0,
  Outcome,
  OuterOuterU,
  OuterPiece,
  TipKind,
  Word,
} from "./naming.ts";
import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";

console.log(
  "a name that becomes a reserved word or an earlier name gets a suffix"
);

print(new0);

print({ actual: s0(o), expected: s(o) });

print([toNumber(fooBar), toNumber(fooBar0)]);

print(toNumber(twice(ofNumber(2))));

console.log("a module whose name a type has takes a suffix, as a value would");

{
  const w: Word = Word0.flip(new0);
  print({ actual: w, expected: old });
}

console.log("constructor fields take the kernel binder names, camelCased");

print(unbox(box("x", mkA)));

print({
  actual: box("x", mkA),
  expected: {
    contents: "x",
    other: mkA,
    tag: "Box",
  },
});

console.log(
  "a binder named tag or a reserved word falls back to positional fields"
);

print({
  actual: tagged(ofNumber(1), ofNumber(2)),
  expected: {
    arg0: ofNumber(1),
    arg1: ofNumber(2),
    tag: "Tagged",
  },
});

print(toNumber(untag(tagged(ofNumber(1), ofNumber(2)))));

print(toNumber(depth(cfg(ofNumber(1), ofNumber(2)))));

print(toNumber(klassSize(klass(ofNumber(1), ofNumber(3)))));

console.log("primed and non-ASCII binders are valid parameters");

print(toNumber(primed(ofNumber(2))));

print(toNumber(accent(ofNumber(2))));

console.log("a nested module may share its name with an enclosing module");

{
  const u: OuterOuterU = Outer.Outer.flip(Outer.Outer.left);
  print({ actual: u, expected: Outer.Outer.right });
  print({ actual: Outer.swap(Outer.up), expected: Outer.down });
  const p: OuterPiece = Outer.bigRound;
  const kind: TipKind = p.kind;
  print({ actual: kind, expected: Tip.round });
  print({ actual: p.size, expected: Outer.Tip.large });
}

console.log("a name that is not an identifier is escaped");

print([toNumber(_1), toNumber(x1), toNumber(y_00bd)]);

print({
  actual: indexed(ofNumber(1), ofNumber(2)),
  expected: {
    _2: ofNumber(1),
    tag: "Indexed",
    x2: ofNumber(2),
  },
});

print(toNumber(pick(ofNumber(1), ofNumber(2))));

console.log("a name that JavaScript or TypeScript reserves takes a suffix");

{
  const d: Date0 = set0(ofNumber(1));
  print(toNumber(d));
  const e: Outcome = error;
  const narrow: Error0 = { tag: "Error" };
  print({ actual: e, expected: narrow });
  print(ok(ofNumber(1)).tag);
  print([then0.tag, else0.tag]);
}

console.log("a name that differs from a reserved one only in case is kept");

print(toNumber(map(ofNumber(3))));

console.log(
  "a constructor named like a parameter of inlined code takes a suffix"
);

print(x0);

print(horizontal);

print(toNumber(still(ofNumber(2))));
