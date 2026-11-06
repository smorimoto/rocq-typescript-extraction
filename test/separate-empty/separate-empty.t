Extraction writes only the requested module, without an empty dependency file.

  $ mkdir extracted
  $ rocq compile -q -output-directory extracted \
  >   -Q ../../theories TypeScriptExtraction \
  >   -R . Dune_Extraction_SeparateEmpty SeparateEmpty.v
  $ ls -1 extracted
  separate-empty.ts

  $ bun ./separate-empty.cases.ts
  a file uses the types of a library from which nothing remains
  5
  1
