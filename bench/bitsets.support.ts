/** Independent boolean-array DP for bounded, nonnegative benchmark weights. */
export const reachableSums = (weights: readonly number[]): bigint => {
  const total = weights.reduce((sum, weight) => sum + weight, 0);
  const reachable = Array.from({ length: total + 1 }, () => false);
  reachable[0] = true;

  for (const weight of weights) {
    for (let sum = total; sum >= weight; sum -= 1) {
      reachable[sum] ||= reachable[sum - weight] === true;
    }
  }

  const binary = reachable
    .toReversed()
    .map((present) => (present ? "1" : "0"))
    .join("");

  return BigInt(`0b${binary}`);
};
