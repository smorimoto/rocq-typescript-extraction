  $ bun ./primitive-types.cases.ts
  the primitive literals are a bigint, a number, and a string
  42n
  0.5
  'hello'
  {
    count: 3n,
    label: 'three'
  }
  a primitive array literal holds its items and its default
  {
    default: 0n,
    items: [
      1n,
      2n,
      3n
    ]
  }
  {
    default: 'x',
    items: []
  }
  {
    actual: [
      {
        default: 0n,
        items: [
          1n,
          2n,
          3n
        ]
      }
    ],
    expected: [
      {
        default: 0n,
        items: [
          1n,
          2n,
          3n
        ]
      }
    ]
  }
  {
    default: 0n,
    items: []
  }
