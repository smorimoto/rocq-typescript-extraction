import { defineConfig } from "oxlint";
import antiSlop from "ultracite/oxlint/anti-slop";
import core from "ultracite/oxlint/core";

export default defineConfig({
  extends: [core, antiSlop],
  ignorePatterns: [...(core.ignorePatterns ?? []), "submodules/**"],
  rules: {
    complexity: "off",
    "no-bitwise": ["error", { allow: ["&", "|", "|=", "^", "~", "<<", ">>"] }],
    "typescript/prefer-for-of": "off",
    "unicorn/no-array-sort": "off",
    "unicorn/no-new-array": "off",
    "unicorn/prefer-at": "off",
    "unicorn/prefer-code-point": "off",
  },
});
