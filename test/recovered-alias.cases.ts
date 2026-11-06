import { print } from "./observe.ts";
import { Applied, Container, Payloads, Read } from "./recovered-alias.ts";
import type { PayloadsItemValue } from "./recovered-alias.ts";

console.log("recovered types and enum bounds resolve nested module aliases");

{
  const chosen: PayloadsItemValue = Container.choose(true);
  const flag: boolean = Container.choose(false);
  const selected: PayloadsItemValue = Container.select(Payloads.primary);
  const other: boolean = Container.select(Payloads.secondary);

  print(chosen);
  print({ actual: selected, expected: chosen });
  print([flag, other]);
}

console.log(
  "a functor substitutes a type reached through a nested module alias"
);

{
  const extracted: PayloadsItemValue = Applied.get0;
  const supplied: string = Read({ Alias: { witness: "payload" } }).get0;

  print(extracted);
  print(supplied);
}
