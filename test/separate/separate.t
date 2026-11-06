  $ bun ./separate.cases.ts
  a module imports the types and constructors of another file
  6
  {
    actual: {
      tag: 'True'
    },
    expected: {
      tag: 'True'
    }
  }
  2
  a library of several words is extracted to a kebab-case file
  [
    2,
    4
  ]
  [
    2,
    4
  ]
  a parameter named after a binding of another file leaves it alone
  [
    4,
    8
  ]
  2
  4
  a module of the extracted file keeps its object and its types
  2
  0
