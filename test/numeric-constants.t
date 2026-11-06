  $ bun ./numeric-constants.cases.ts
  integer constants retain their value and dynamic constructors
  [
    [
      0n,
      1n
    ],
    17n
  ]
  9007199254740993n
  18446744073709551617n
  -18446744073709551617n
  18446744073709551618n
  [
    [
      0,
      1
    ],
    17
  ]
  {
    actual: 9007199254740991,
    expected: 9007199254740991
  }
  {
    actual: 9007199254740992,
    expected: 9007199254740992
  }
  65537
  -65537
  18
  custom constructors keep their arithmetic
  6n
  6
  -0
  -0
  0
