import { referenceResults } from "./reference.ts";
import { array } from "./support.ts";

for (const row of array(referenceResults)) {
  console.log(array(row).join(","));
}
