import { bitwiseChecksum, byteChecksum } from "../bench/runtime.support.ts";
import { print } from "./observe.ts";

console.log("primitive benchmark checksums handle empty, zero and wide inputs");

print(byteChecksum(""));

print(byteChecksum("\u0000\u007F\u0080\u00FF"));

print(bitwiseChecksum([]));

print(bitwiseChecksum([0]));

print(bitwiseChecksum([-1]));

print(bitwiseChecksum([2 ** 40, 0]));
