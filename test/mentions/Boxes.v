From TypeScriptExtraction Require Import Number.
From Mentions Require Import Points.

Inductive wrap (A : Type) := Wrap (a : A) (p : point).
Extract Inductive wrap => "readonly [$1, Point]"
  [ "(<A>(a: A, p: Point): readonly [A, Point] => [a, p])" ]
  "(<R>(f: (a: A, p: Point) => R, w: readonly [A, Point]): R => f(w[0], w[1]))".

Axiom outline : Type.
Extract Constant outline => "/* Point */
readonly Point[]".

Axiom label : Type.
Extract Inlined Constant label => """Point""".

Axiom kind : Type.
Extract Inlined Constant kind => "typeof origin".

Axiom either : Type.
Extract Inlined Constant either => "Point | Point".

Axiom collide : Type.
Extract Constant collide => "<Point>(x: Point) => Point".

Axiom keyed : Type.
Extract Constant keyed => "{ [Point in ""px"" | ""py""]: Point }".

Axiom fields : Type.
Extract Constant fields => "{ [K in ""px"" | ""py""]: Point }".

Axiom picked : Type.
Extract Inlined Constant picked => "number extends infer Point ? Point : never".

Definition sample (n : nat) : wrap nat := Wrap nat n origin.
Definition hold (o : outline) : outline := o.
Definition labelled (s : label) : label := s.
Definition named (k : kind) : kind := k.
Definition sided (e : either) : either := e.
Definition crashed (c : collide) : collide := c.
Definition keyed_id (k : keyed) : keyed := k.
Definition fields_id (k : fields) : fields := k.
Definition picked_id (p : picked) : picked := p.
