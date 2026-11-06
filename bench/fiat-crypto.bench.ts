import { group } from "mitata";

import { checkResults, workloads } from "./fiat-crypto.support.ts";
import { checkedBench } from "./support.ts";

group("Fiat Crypto / BigInt bigint / 32 operations", () => {
  for (const { field, name, expected, run } of workloads) {
    checkedBench(`${field.name} / ${name}`, run, (results) => {
      checkResults(field, results, expected);
    });
  }
});
