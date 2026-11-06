import { print } from "../observe.ts";
import * as M from "./memory.ts";
import { list } from "./support.ts";

const global = (
  data: M.InitData[],
  readonly = false
): M.Globdef<never, undefined> =>
  M.gvar({
    gvarInfo: undefined,
    gvarInit: list(data),
    gvarReadonly: readonly,
    gvarVolatile: false,
  });

console.log("global initialization rejects unresolved symbol references");

{
  const program: M.Program<undefined, undefined> = {
    progDefs: list([[1n, global([M.initAddrof(99n, 0n)])]]),
    progMain: 1n,
    progPublic: M.nil,
  };

  print({ actual: M.Genv.initMem(program), expected: M.none });
}
