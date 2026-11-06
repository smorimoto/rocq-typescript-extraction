  $ bun ./floats.cases.ts
  the constants of PrimFloat
  Infinity
  -Infinity
  NaN
  1
  0
  -0
  2
  classify tells the nine classes apart
  'PNormal'
  'NNormal'
  'PSubn'
  'NSubn'
  'PSubn'
  'NSubn'
  'PNormal'
  'PZero'
  'NZero'
  'PInf'
  'NInf'
  'NaN'
  the comparisons, with NaN not comparable and the zeros equal
  'FLt'
  'FGt'
  'FEq'
  'FNotComparable'
  'FNotComparable'
  'FEq'
  'FEq'
  'FLt'
  true
  false
  false
  true
  false
  false
  the Leibniz equality tells the zeros apart and the NaNs not
  false
  true
  true
  false
  true
  next_up and next_down step through the zeros, the extremes, and NaN
  {
    actual: 5e-324,
    expected: 5e-324
  }
  {
    actual: 5e-324,
    expected: 5e-324
  }
  {
    actual: -5e-324,
    expected: -5e-324
  }
  {
    actual: -5e-324,
    expected: -5e-324
  }
  -0
  0
  Infinity
  -Infinity
  -1.7976931348623155e+308
  1.7976931348623155e+308
  Infinity
  {
    actual: -1.7976931348623157e+308,
    expected: -1.7976931348623157e+308
  }
  -Infinity
  {
    actual: 1.7976931348623157e+308,
    expected: 1.7976931348623157e+308
  }
  1.0000000000000002
  0.9999999999999999
  -0.9999999999999999
  -1.0000000000000002
  2.225073858507202e-308
  2.225073858507201e-308
  NaN
  NaN
  frshiftexp splits a float into a mantissa in [0.5, 1) and a shifted exponent
  [
    0.5,
    2102n
  ]
  [
    0.75,
    2103n
  ]
  [
    -0.75,
    2103n
  ]
  [
    0.5,
    1028n
  ]
  [
    0.5,
    1080n
  ]
  [
    0.9999999999999999,
    3125n
  ]
  [
    0,
    0n
  ]
  [
    Infinity,
    0n
  ]
  [
    -Infinity,
    0n
  ]
  -0
  0n
  NaN
  0n
  ldshiftexp scales by a power of two, rounding once in the subnormal range
  1
  2
  0.5
  0
  Infinity
  Infinity
  96
  8.98846567431158e+307
  Infinity
  Infinity
  0
  Infinity
  {
    actual: 5e-324,
    expected: 5e-324
  }
  {
    actual: 5e-324,
    expected: 5e-324
  }
  {
    actual: 5e-324,
    expected: 5e-324
  }
  2.6469779601696886e-23
  8
  normfr_mantissa reads the mantissa of a float in [0.5, 1) and gives 0 elsewhere
  6755399441055744n
  4503599627370496n
  0n
  6755399441055744n
  0n
  0n
  0n
  of_uint63 rounds to the nearest float, ties to even
  9223372036854776000
  9007199254740992
  9007199254740996
  0
  4611686018427388000
  the arithmetic is IEEE 754 arithmetic
  {
    actual: 1.4142135623730951,
    expected: 1.4142135623730951
  }
  NaN
  1
  0
  -0
  NaN
  3
  -1
  4
  Infinity
  NaN
  -Infinity
  the predicates of PrimFloat extract through the realisers
  true
  false
  true
  true
  false
  true
  true
  false
  true
  a float literal is the lone argument of a call
  true
