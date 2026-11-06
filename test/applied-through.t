  $ bun ./applied-through.cases.ts
  a functor of a body applied through applications of the outer one
  {
    tag: 'Box',
    x: 1,
    y: true
  }
  [
    [
      1,
      true
    ],
    1
  ]
  {
    tag: 'Box',
    x: 1,
    y: 's'
  }
  [
    [
      1,
      true
    ],
    null
  ]
  {
    actual: [
      [
        1,
        true
      ],
      1
    ],
    expected: [
      [
        1,
        true
      ],
      1
    ]
  }
  a partial application reached through an application
  [
    [
      1,
      true
    ],
    1
  ]
  [
    [
      1,
      true
    ],
    's'
  ]
  a functor of a functor signature applied through a parameter
  {
    tag: 'Box',
    x: 1,
    y: true
  }
  {
    tag: 'Box',
    x: 'a',
    y: 2
  }
  a functor of a parameter's module type applied through it
  {
    tag: 'Box',
    x: 1,
    y: true
  }
  {
    tag: 'Box',
    x: 'k',
    y: 3
  }
  [
    'u',
    4
  ]
