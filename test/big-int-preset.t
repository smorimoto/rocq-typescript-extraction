  $ bun ./big-int-preset.cases.ts
  BigInt alone accepts bigint literals, booleans, and readonly tuples
  true
  false
  {
    actual: [
      true,
      9007199254740993n
    ],
    expected: [
      true,
      9007199254740993n
    ]
  }
  [
    false,
    'a'
  ]
  [
    3n,
    true
  ]
  {
    actual: [
      undefined,
      9007199254740994n
    ],
    expected: [
      undefined,
      9007199254740994n
    ]
  }
  standard arithmetic remains exact beyond the number boundary
  9007199254740995n
  9007199254740997n
  27021597764222979n
  -9007199254740995n
  natural operations retain truncation and zero-divisor semantics
  0n
  0n
  0n
  {
    actual: 9007199254740992n,
    expected: 9007199254740992n
  }
  4503599627370496n
  1n
  0n
  {
    actual: 9007199254740993n,
    expected: 9007199254740993n
  }
  recursive binary matches keep exact predecessors
  54n
  1n
  {
    actual: 9007199254740994n,
    expected: 9007199254740994n
  }
  {
    actual: 9007199254740993n,
    expected: 9007199254740993n
  }
  0n
  -6n
  user inductives remain tagged and recursive results use bigint
  'Tick'
  2n
  2n
  BigInt also realises all four primitive operation families
  1n
  3.75
  'ab'
  4n
  9n
