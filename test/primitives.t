  $ bun ./primitives.cases.ts
  int63 literals are bigints, operations go through the preset
  42n
  9223372036854775807n
  5n
  0n
  4611686018427387905n
  144n
  a match on bool extracted to boolean without a match function
  true
  'the answer'
  'a number'
  a primitive string keeps one UTF-16 code unit per byte
  8
  195
  169
  {
    actual: 'hÃ©llo, bob',
    expected: 'hÃ©llo, bob'
  }
  11n
  float literals are numbers, including a negative zero
  0.5
  0.3333333333333333
  true
  a match on a generated union gives a boolean under the preset
  true
