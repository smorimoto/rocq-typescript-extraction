  $ bun ./arrays.cases.ts
  make fills the items with the default and caps the length
  4194303n
  {
    default: 7n,
    items: [
      7n,
      7n,
      7n
    ]
  }
  {
    default: 7n,
    items: []
  }
  {
    actual: 4194303n,
    expected: 4194303n
  }
  {
    actual: 4194303n,
    expected: 4194303n
  }
  {
    actual: 4194303n,
    expected: 4194303n
  }
  get reads an item, and the default out of range
  1n
  3n
  0n
  0n
  0n
  3n
  3n
  0n
  5n
  an array of a type with undefined values keeps its default apart
  [
    '0',
    '1'
  ]
  undefined
  undefined
  2n
