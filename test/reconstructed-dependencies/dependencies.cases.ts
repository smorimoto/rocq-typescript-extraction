import { print } from "../observe.ts";
import * as Monolithic from "./monolithic.ts";
import * as Separate from "./payloads.ts";

for (const [name, api] of [
  ["monolithic", Monolithic],
  ["separate", Separate],
] as const) {
  console.log(`${name}: recovered constructors close their own dependencies`);
  print(api.inspect(true, api.parcel(true, api.numbered(3n))));
  print(api.inspect(true, api.parcel(true, api.unnumbered)));

  console.log(`${name}: reconstructed types retain custom inductive mappings`);
  print(api.mappedRead(true, true));
  print(api.mappedRead(true, false));

  console.log(
    `${name}: module member signatures recover their private dependencies`
  );
  const reader = api.Use({ readSecret: (b) => b });
  print(reader.ready(api.secretValue(5n)));
  print(reader.ready(api.noSecret));
}
