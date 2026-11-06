All 18 typing and memory observations agree with standard OCaml extraction.

  $ bun reference-observations.ts > reference.actual
  $ awk 'END { print NR }' reference.actual
  18
  $ diff -u reference.out reference.actual
