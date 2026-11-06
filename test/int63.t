  $ bun ./int63.cases.ts
  addition, subtraction, and multiplication wrap at 2^63
  0n
  0n
  12n
  {
    actual: 9223372036854775807n,
    expected: 9223372036854775807n
  }
  {
    actual: 9223372036854775806n,
    expected: 9223372036854775806n
  }
  0n
  1n
  4611686018427387904n
  unsigned division by zero gives zero and the dividend
  3n
  1n
  0n
  7n
  4611686018427387903n
  1n
  [
    3n,
    1n
  ]
  [
    0n,
    7n
  ]
  signed division truncates toward zero, the remainder keeps the dividend's sign
  {
    actual: 9223372036854775805n,
    expected: 9223372036854775805n
  }
  {
    actual: 9223372036854775807n,
    expected: 9223372036854775807n
  }
  3n
  {
    actual: 9223372036854775807n,
    expected: 9223372036854775807n
  }
  {
    actual: 4611686018427387904n,
    expected: 4611686018427387904n
  }
  0n
  0n
  7n
  a shift by 63 or more gives zero, the arithmetic shift keeps the sign
  4611686018427387904n
  0n
  {
    actual: 9223372036854775806n,
    expected: 9223372036854775806n
  }
  0n
  1n
  0n
  2n
  0n
  {
    actual: 9223372036854775804n,
    expected: 9223372036854775804n
  }
  {
    actual: 9223372036854775807n,
    expected: 9223372036854775807n
  }
  {
    actual: 9223372036854775807n,
    expected: 9223372036854775807n
  }
  0n
  0n
  2n
  0n
  the bitwise operations
  8n
  14n
  6n
  {
    actual: 4611686018427387904n,
    expected: 4611686018427387904n
  }
  {
    actual: 9223372036854775807n,
    expected: 9223372036854775807n
  }
  {
    actual: 4611686018427387903n,
    expected: 4611686018427387903n
  }
  the comparisons, unsigned and signed
  true
  false
  true
  false
  true
  true
  false
  true
  false
  true
  false
  false
  true
  'Lt'
  'Eq'
  'Gt'
  'Lt'
  'Lt'
  'Gt'
  'Eq'
  the operations with a carry
  {
    arg0: 0n,
    tag: 'C1'
  }
  {
    arg0: 3n,
    tag: 'C0'
  }
  {
    arg0: 0n,
    tag: 'C1'
  }
  {
    arg0: 4n,
    tag: 'C0'
  }
  {
    actual: {
      arg0: 9223372036854775807n,
      tag: 'C0'
    },
    expected: {
      arg0: 9223372036854775807n,
      tag: 'C0'
    }
  }
  {
    actual: {
      arg0: 9223372036854775807n,
      tag: 'C1'
    },
    expected: {
      arg0: 9223372036854775807n,
      tag: 'C1'
    }
  }
  {
    arg0: 2n,
    tag: 'C0'
  }
  {
    arg0: 1n,
    tag: 'C0'
  }
  {
    actual: {
      arg0: 9223372036854775807n,
      tag: 'C1'
    },
    expected: {
      arg0: 9223372036854775807n,
      tag: 'C1'
    }
  }
  {
    arg0: 0n,
    tag: 'C0'
  }
  the exact multiplication and the division of two words by one
  {
    actual: [
      9223372036854775806n,
      1n
    ],
    expected: [
      9223372036854775806n,
      1n
    ]
  }
  [
    2n,
    0n
  ]
  [
    0n,
    15n
  ]
  [
    1n,
    0n
  ]
  [
    4611686018427387904n,
    0n
  ]
  [
    3074457345618258604n,
    1n
  ]
  [
    0n,
    0n
  ]
  [
    3n,
    1n
  ]
  [
    0n,
    0n
  ]
  {
    actual: [
      4611686018427387904n,
      4611686018427387903n
    ],
    expected: [
      4611686018427387904n,
      4611686018427387903n
    ]
  }
  3n
  7n
  0n
  5n
  6917529027641081856n
  {
    actual: 9223372036854775806n,
    expected: 9223372036854775806n
  }
  the leading and trailing zeros, 63 of each for zero
  63n
  62n
  0n
  0n
  31n
  63n
  0n
  62n
  2n
  0n
