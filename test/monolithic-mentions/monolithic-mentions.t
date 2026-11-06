  $ bun ./monolithic-mentions.cases.ts
  mapped code in the same file names Point and origin
  [
    2,
    {
      px: 0,
      py: 0
    }
  ]
  {
    actual: [
      {
        px: 1,
        py: 2
      }
    ],
    expected: [
      {
        px: 1,
        py: 2
      }
    ]
  }
  'Point'
  {
    actual: {
      px: 1,
      py: 2
    },
    expected: {
      px: 1,
      py: 2
    }
  }
  {
    actual: {
      px: 1,
      py: 2
    },
    expected: {
      px: 1,
      py: 2
    }
  }
  {
    actual: {
      px: {
        px: 1,
        py: 2
      },
      py: {
        px: 1,
        py: 2
      }
    },
    expected: {
      px: {
        px: 1,
        py: 2
      },
      py: {
        px: 1,
        py: 2
      }
    }
  }
