import { inspect } from "node:util";

export const print = <Value>(value: Value): void => {
  console.log(
    inspect(value, {
      colors: false,
      compact: false,
      customInspect: false,
      depth: null,
      maxArrayLength: null,
      maxStringLength: null,
      sorted: true,
    })
  );
};
