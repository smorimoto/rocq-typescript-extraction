  $ bun ./big-nats.cases.ts
  recursion on nat goes through the match function, on bigint
  120n
  2432902008176640000n
  55n
  comparisons return boolean
  true
  false
  true
  false
  arithmetic keeps nat's meaning at zero
  4n
  2n
  7n
  7n
  0n
  4n
  positive and Z are bigint too, exact beyond 2^53
  2361183241434822606848n
  -5n
  min and max
  2n
  5n
  10n
