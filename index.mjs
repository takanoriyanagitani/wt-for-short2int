import { readFile } from "node:fs/promises";

import { tableFromArrays, tableToIPC } from "apache-arrow";

const wasmName = () => "./s2i.wasm";

const iomain = () =>
  Promise.resolve().then((_) => {
    const wname = wasmName();
    const pwbytes = readFile(wname);
    const pwasm = pwbytes.then(WebAssembly.instantiate);
    const pins = pwasm.then((mi) => mi.instance);
    const pexp = pins.then((ins) => ins.exports);
    return pexp.then((exp) => {
      const {
        memory,
        short2int_page,
      } = exp;

      const fpage = 0x0001_0000;
      const ipage = 0x0002_0000;
      const opage = 0x0003_0000;

      const ipck = new Int16Array(memory.buffer, ipage, 16384);
      const ifor = new Int32Array(memory.buffer, fpage, 512);

      for (let i = 0; i < 512; i++) ifor[i] = 1e6;
      for (let i = 0; i < 16384; i++) ipck[i] = i;

      short2int_page(
        ipage,
        opage,
        fpage,
      );

      const odec = new Int32Array(memory.buffer, opage, 16384);

      const tab = tableFromArrays({
        decoded_head: odec.slice(0, 16),
        decoded_tail: odec.slice(16384 - 16, 16384),
      });

      const ipc = tableToIPC(
        tab,
        "stream",
        null,
      );
      return process.stdout.write(ipc);
    });
  });

iomain()
  .catch(console.error);
