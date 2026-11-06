From compcert.common Require Import Memory Globalenvs.
From CompCertTests Require Import Programs.
From TypeScriptExtraction Require Import BigInt.

Set Warnings "+typescript-extraction-unchecked-casts".

TypeScript Extraction "memory.ts"
  Mem.empty Mem.alloc Mem.free Mem.load Mem.loadbytes Mem.storebytes Mem.drop_perm
  store_int load_int Genv.init_mem Genv.globalenv Genv.find_symbol.
