  $ bun ./nested-type-dependencies.cases.ts
  a function retains its nested functor parameter capture
  13
  'payload'
  constructor fields retain transitive abstract type dependencies
  {
    tag: 'Result',
    value: {
      tag: 'Wrapped',
      value: 7
    }
  }
  {
    tag: 'NoResult'
  }
