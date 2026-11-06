  $ bun ./tuples.cases.ts
  a tuple is an array
  [
    1,
    'a'
  ]
  [
    1,
    [
      'a',
      true
    ]
  ]
  a tuple pattern reads the elements
  [
    'a',
    1
  ]
  'a'
  'a'
  [
    'a',
    1
  ]
  a match on a tag inside a tuple is a conditional
  {
    actual: [
      {
        tag: 'Positive'
      },
      1
    ],
    expected: [
      {
        tag: 'Positive'
      },
      1
    ]
  }
  {
    actual: [
      {
        tag: 'NegativeOrZero'
      },
      'a'
    ],
    expected: [
      {
        tag: 'NegativeOrZero'
      },
      'a'
    ]
  }
