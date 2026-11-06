import { defineConfig } from "oxlint";

import defaults from "../../oxlint.config.ts";

export default defineConfig({
  extends: [defaults],
  rules: {
    "eslint/no-self-assign": "off",
    "eslint/no-unneeded-ternary": "off",
    "oxc/branches-sharing-code": "off",
    "unicorn/prefer-ternary": "off",
    "unicorn/text-encoding-identifier-case": "off",
  },
});
