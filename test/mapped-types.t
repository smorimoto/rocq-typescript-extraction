  $ bun ./mapped-types.cases.ts
  monolithic: a consumer names a type mentioned only by mapped code
  3
  {
    actual: [
      {
        px: 1,
        py: 2
      },
      {
        px: 4,
        py: 6
      }
    ],
    expected: [
      {
        px: 1,
        py: 2
      },
      {
        px: 4,
        py: 6
      }
    ]
  }
  [
    {
      px: 0,
      py: 0
    },
    {
      px: 1,
      py: 1
    }
  ]
  separate: a consumer names a type mentioned only by mapped code
  3
  {
    actual: [
      {
        px: 1,
        py: 2
      },
      {
        px: 4,
        py: 6
      }
    ],
    expected: [
      {
        px: 1,
        py: 2
      },
      {
        px: 4,
        py: 6
      }
    ]
  }
  [
    {
      px: 0,
      py: 0
    },
    {
      px: 1,
      py: 1
    }
  ]
  a separate mapped result retains its named type
  {
    actual: [
      {
        px: 1,
        py: 2
      },
      {
        px: 4,
        py: 6
      }
    ],
    expected: [
      {
        px: 1,
        py: 2
      },
      {
        px: 4,
        py: 6
      }
    ]
  }
