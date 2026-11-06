import { expect, test } from "bun:test";

import * as M from "./memory.ts";
import { array, list, present } from "./support.ts";

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

test("stores wrap to 32 bits and preserve every prior memory state", () => {
  const [empty, block] = M.Mem.alloc(M.Mem.empty, -16n, 32n);
  const values = [0n, 1n, -1n, 2n ** 31n, 2n ** 32n + 7n, 2n ** 60n + 19n];
  let memory = empty;

  const versions = values.map((value) => {
    memory = present(M.storeInt(memory, block, 0n, value));

    return { memory, value };
  });

  for (const { memory: version, value } of versions) {
    expect(present(M.loadInt(version, block, 0n))).toBe(
      BigInt.asUintN(32, value)
    );
  }

  expect(M.Mem.load(M.mint32, empty, block, 0n)).toEqual(M.some(M.vundef));
  expect(M.Mem.load(M.mint32, memory, block, -20n)).toEqual(M.none);
  expect(M.Mem.load(M.mint32, memory, block, 1n)).toEqual(M.none);
  expect(M.Mem.load(M.mint32, memory, block, 32n)).toEqual(M.none);
});

test("byte copies preserve little-endian values and signed loads", () => {
  const [allocated, block] = M.Mem.alloc(M.Mem.empty, 0n, 16n);
  const memory = present(M.storeInt(allocated, block, 0n, 0x89_ab_cd_efn));
  const bytes = present(M.Mem.loadbytes(memory, block, 0n, 4n));
  expect(array(bytes)).toEqual([0xefn, 0xcdn, 0xabn, 0x89n].map(M.byte0));
  const copied = present(M.Mem.storebytes(memory, block, 8n, bytes));
  expect(present(M.loadInt(copied, block, 8n))).toBe(0x89_ab_cd_efn);
  expect(M.Mem.load(M.mint8signed, copied, block, 8n)).toEqual(
    M.some(M.vint(0xff_ff_ff_efn))
  );
  expect(M.Mem.load(M.mint8unsigned, copied, block, 8n)).toEqual(
    M.some(M.vint(0xefn))
  );
  expect(M.Mem.load(M.mint32, memory, block, 8n)).toEqual(M.some(M.vundef));
});

test("partial free only invalidates that range of that block", () => {
  const [first, block] = M.Mem.alloc(M.Mem.empty, 0n, 16n);
  const [allocated, other] = M.Mem.alloc(first, 0n, 16n);
  let memory = present(M.storeInt(allocated, other, 4n, 99n));

  for (const offset of [0n, 4n, 8n, 12n]) {
    memory = present(M.storeInt(memory, block, offset, offset + 10n));
  }

  const freed = present(M.Mem.free(memory, block, 4n, 8n));
  expect(M.loadInt(freed, block, 4n)).toEqual(M.none);
  expect(M.storeInt(freed, block, 4n, 1n)).toEqual(M.none);
  expect(M.Mem.free(freed, block, 4n, 8n)).toEqual(M.none);

  for (const offset of [0n, 8n, 12n]) {
    expect(present(M.loadInt(freed, block, offset))).toBe(offset + 10n);
  }

  expect(present(M.loadInt(freed, other, 4n))).toBe(99n);
  expect(present(M.loadInt(memory, block, 4n))).toBe(14n);
});

test("permission changes retain readable bytes but reject writes and frees", () => {
  const [allocated, block] = M.Mem.alloc(M.Mem.empty, 0n, 16n);
  const memory = present(M.storeInt(allocated, block, 0n, 42n));
  const readonly = present(M.Mem.dropPerm(memory, block, 0n, 8n, M.readable));
  expect(present(M.loadInt(readonly, block, 0n))).toBe(42n);
  expect(M.storeInt(readonly, block, 0n, 7n)).toEqual(M.none);
  expect(M.Mem.free(readonly, block, 0n, 8n)).toEqual(M.none);
  expect(M.storeInt(readonly, block, 8n, 7n).tag).toBe("Some");
  expect(M.storeInt(memory, block, 0n, 7n).tag).toBe("Some");
});

test("many partial frees keep the captured bounds of each update", () => {
  const [allocated, block] = M.Mem.alloc(M.Mem.empty, 0n, 1024n);
  let memory = allocated;

  for (let offset = 0n; offset < 1024n; offset += 8n) {
    memory = present(M.Mem.free(memory, block, offset, offset + 4n));
  }

  for (let offset = 0n; offset < 1024n; offset += 4n) {
    expect(M.Mem.load(M.mint32, memory, block, offset).tag).toBe(
      offset % 8n === 0n ? "None" : "Some"
    );
    expect(M.Mem.load(M.mint32, allocated, block, offset).tag).toBe("Some");
  }
});

test("global initialization resolves forward pointers and read-only data", () => {
  const program: M.Program<undefined, undefined> = {
    progDefs: list([
      [1n, global([M.initAddrof(2n, 4n)])],
      [2n, global([M.initInt32(42n), M.initInt32(73n)], true)],
      [3n, global([M.initSpace(16n)])],
    ]),
    progMain: 1n,
    progPublic: list([1n, 2n]),
  };

  const env = M.Genv.globalenv(program);
  const memory = present(M.Genv.initMem(program));
  const pointer = present(M.Genv.findSymbol(env, 1n));
  const data = present(M.Genv.findSymbol(env, 2n));
  const zero = present(M.Genv.findSymbol(env, 3n));
  expect(M.Mem.load(M.mint64, memory, pointer, 0n)).toEqual(
    M.some(M.vptr(data, 4n))
  );
  expect(present(M.loadInt(memory, data, 4n))).toBe(73n);
  expect(M.storeInt(memory, data, 0n, 0n)).toEqual(M.none);
  expect(present(M.loadInt(memory, zero, 12n))).toBe(0n);

  const bytes = present(M.Mem.loadbytes(memory, pointer, 0n, 8n));
  const copied = present(M.Mem.storebytes(memory, zero, 0n, bytes));
  expect(M.Mem.load(M.mint64, copied, zero, 0n)).toEqual(
    M.some(M.vptr(data, 4n))
  );
  expect(present(M.loadInt(memory, zero, 0n))).toBe(0n);
});
