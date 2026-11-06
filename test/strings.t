  $ bun ./strings.cases.ts
  make keeps the low byte of its character and caps the length
  16777211n
  'aaa'
  'aaa'
  ''
  {
    actual: 16777211n,
    expected: 16777211n
  }
  {
    actual: 16777211n,
    expected: 16777211n
  }
  get reads a byte, and 0 out of range
  5n
  101n
  0n
  0n
  104n
  0n
  sub clamps its length to the end and gives nothing past it
  'ell'
  'ello'
  ''
  ''
  ''
  ''
  'ello'
  'hello'
  cat keeps the longest prefix of its second argument that fits
  'abcd'
  'x'
  {
    actual: 16777211n,
    expected: 16777211n
  }
  97n
  {
    actual: 16777211n,
    expected: 16777211n
  }
  120n
  97n
  compare orders by byte, and eqb switches over its result
  'Lt'
  'Gt'
  'Eq'
  'Lt'
  'Gt'
  'Lt'
  'Eq'
  true
  false
  true
  a literal holds one code unit per byte of its UTF-8
  6n
  195n
  169n
  'Gt'
