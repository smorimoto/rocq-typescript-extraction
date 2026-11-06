  $ bun ./nested.cases.ts
  a functor declared in the body of another is a member of the result
  [
    '!',
    4
  ]
  [
    '!',
    true
  ]
  [
    '!',
    true
  ]
  [
    1,
    'a'
  ]
  [
    1,
    true
  ]
  a functor defined as an application applies the other to its arguments
  'a'
  1
  1
  false
  a type of a nested functor takes the parameters of the outer type it names
  {
    tag: 'Box',
    x: '',
    y: 4
  }
  {
    tag: 'Box',
    x: 0,
    y: false
  }
