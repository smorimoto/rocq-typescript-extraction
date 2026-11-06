import { generate_dune as fiat_crypto_dune } from "../bench/fiat-crypto/gen-dune.ts";
import { generate_dune as compcert_dune } from "./compcert/gen-dune.ts";

const generators = {
  compcert: compcert_dune,
  "fiat-crypto": fiat_crypto_dune,
};

const [generator, upstream] = process.argv.slice(2);

if (
  (generator !== "compcert" && generator !== "fiat-crypto") ||
  upstream === undefined
) {
  throw new Error("Usage: bun gen-dune.ts <compcert|fiat-crypto> <upstream>");
}

try {
  process.stdout.write(generators[generator](upstream));
} catch (error) {
  if (!(error instanceof Error)) {
    throw error;
  }

  console.error(error.message);
  process.exitCode = 1;
}
