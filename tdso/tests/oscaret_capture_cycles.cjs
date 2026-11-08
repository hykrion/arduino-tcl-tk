// Run after build_oscaret.ps1:
// node tests/oscaret_capture_cycles.cjs <build>/oscaret.disassembly.txt
// Execute the actual AVR instructions emitted by the compiler, including branches
// and delays. This checks digital timing, not the CA3306's electrical setup/hold.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const listing = fs.readFileSync(process.argv[2], 'utf8');
const instructions = [];
for (const line of listing.split(/\r?\n/)) {
  const match = line.match(/^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2}\s+)+)\s*(\w+)\s*(.*)$/i);
  if (match) {
    const [args, comment = ''] = match[4].split(';');
    instructions.push({address: parseInt(match[1], 16),
      bytes: match[2].trim().split(/\s+/).length, op: match[3],
      args: args.trim().split(/,\s*/),
      target: parseInt((comment.match(/0x([0-9a-f]+)/i) || [])[1], 16)});
  }
}
const code = new Map(instructions.map(i => [i.address, i]));
const reg = name => Number(name.replace('r', ''));
const starts = instructions.filter(i => i.op === 'in' && i.args[0] === 'r20');
assert.equal(starts.length, 12, 'Two slopes for each of six trigger periods');

function execute(start, stop, registers, samples, abortAt = Infinity) {
  let pc = start, cycles = 0, carry = false, zero = false, steps = 0;
  const reads = [], writes = [];
  while (pc !== stop) {
    assert.ok(++steps < 1500000, 'Acquisition must finish or abort');
    const i = code.get(pc);
    assert.ok(i, `Missing instruction at ${pc.toString(16)}`);
    const [a, b] = i.args;
    let next = pc + i.bytes, cost = 1;
    switch (i.op) {
      case 'in':
        registers[reg(a)] = samples(reads.length) | 0xc0;
        reads.push(cycles);
        break;
      case 'andi': registers[reg(a)] &= Number(b); break;
      case 'ldi': registers[reg(a)] = Number(b); break;
      case 'mov': registers[reg(a)] = registers[reg(b)]; break;
      case 'cp': carry = registers[reg(a)] < registers[reg(b)]; break;
      case 'brcs': if (carry) {next = i.target; cost = 2;} break;
      case 'brcc': if (!carry) {next = i.target; cost = 2;} break;
      case 'brne': if (!zero) {next = i.target; cost = 2;} break;
      case 'dec': registers[reg(a)] = (registers[reg(a)] - 1) & 255; zero = registers[reg(a)] === 0; break;
      case 'sbiw': {
        const r = reg(a), n = ((registers[r] | registers[r + 1] << 8) - Number(b)) & 65535;
        registers[r] = n & 255; registers[r + 1] = n >> 8; zero = n === 0; cost = 2;
        break;
      }
      case 'lds':
        assert.equal(Number(b), 0xc0, 'Only UCSR0A may be read in timed loop');
        registers[reg(a)] = reads.length >= abortAt ? 128 : 0; cost = 2;
        break;
      case 'sbrc':
        if (!(registers[reg(a)] & (1 << Number(b)))) {
          const skip = code.get(next); next += skip.bytes; cost = 1 + skip.bytes / 2;
        }
        break;
      case 'rjmp': next = i.target; cost = 2; break;
      case 'st':
        assert.equal(a, 'Z+');
        writes.push(registers[reg(b)]);
        cost = 2;
        break;
      case 'nop': break;
      default: throw Error(`Unsupported instruction ${i.op}`);
    }
    pc = next; cycles += cost;
  }
  return {reads, writes};
}

const periods = new Map();
let cases = 0;
for (const start of starts) {
  const body = instructions.slice(instructions.indexOf(start));
  const comparison = body.find(i => i.op === 'cp');
  const rising = comparison.args[0] === 'r20';
  const levelReg = reg(comparison.args[rising ? 1 : 0]);
  const countInsn = body.find(i => i.op === 'sbiw');
  const countReg = reg(countInsn.args[0]);
  const endBranch = code.get(countInsn.address + countInsn.bytes);
  const stop = endBranch.address + endBranch.bytes;
  for (const level of [1, 32, 63]) {
    // First on the wrong side, then arm, update pretrigger twice, reach equality.
    const before = rising ? level - 1 : Math.min(63, level + 1);
    // A falling edge at 63 is impossible for a 6-bit ADC: test abort instead.
    const impossible = !rising && level === 63;
    const prefix = rising ? [level, 63, before, before, level] : [level, 0, before, before, level];
    const samples = n => n < prefix.length ? prefix[n] : (n * 7) % 64;
    for (const abortAt of [3, 10, Infinity]) {
      const regs = new Uint8Array(32);
      regs[levelReg] = level; regs[countReg] = 254; regs[countReg + 1] = 3;
      const source = impossible ? () => 63 : samples;
      const result = execute(start.address, stop, regs, source, impossible ? 80 : abortAt);
      const period = result.reads[1] - result.reads[0];
      assert.ok([16, 32, 64, 128, 320, 640].includes(period));
      for (let j = 1; j < result.reads.length; j++) {
        assert.equal(result.reads[j] - result.reads[j - 1], period, 'Every sample, including crossing, has identical spacing');
      }
      const completed = (regs[countReg] | regs[countReg + 1] << 8) === 0;
      if (abortAt === Infinity && !impossible) {
        assert.ok(completed);
        assert.deepEqual(result.writes, Array.from({length: 1024}, (_, j) => samples(j + 3)));
        periods.set(period, (periods.get(period) || 0) + 1);
      } else {
        assert.ok(!completed, 'UART must cancel partial captures and waits');
        assert.ok(result.writes.length < 1024);
      }
      cases++;
    }
  }
  // Constant signals on either side must never produce a frame.
  for (const flat of [0, 32, 63]) {
    const regs = new Uint8Array(32);
    regs[levelReg] = 32; regs[countReg] = 254; regs[countReg + 1] = 3;
    const result = execute(start.address, stop, regs, () => flat, 80);
    assert.equal(result.writes.length, 0);
    cases++;
  }
}
assert.deepEqual([...periods.keys()].sort((a, b) => a - b), [16, 32, 64, 128, 320, 640]);
assert.ok([...periods.values()].every(n => n === 5));

// Locate timed blocks by instructions, since LTO may inline or rename wrappers.
const covered = new Set();
for (const start of starts) {
  const body = instructions.slice(instructions.indexOf(start));
  const countInsn = body.find(i => i.op === 'sbiw');
  const branch = code.get(countInsn.address + countInsn.bytes);
  for (const i of body) {
    if (i.address > branch.address) break;
    covered.add(i.address);
  }
}
const fastSymbol = listing.split(/\r?\n/).find(line =>
  /^[0-9a-f]+ </i.test(line) && line.includes('<Oscar::aquire_and_send_5Msps()'));
assert.ok(fastSymbol, 'Fast capture must remain a separate function with LTO');
const fastBody = instructions.filter(i => i.address >= parseInt(fastSymbol, 16));
const fastStart = fastBody.findIndex(i => i.op === 'in');
const fastBlock = fastBody.slice(fastStart, fastStart + 2048);
assert.equal(fastBlock.filter(i => i.op === 'in').length, 1024);
assert.equal(fastBlock.filter(i => i.op === 'st').length, 1024);
for (const i of fastBlock) covered.add(i.address);
const fastResult = execute(fastBlock[0].address, fastBlock.at(-1).address + fastBlock.at(-1).bytes,
  new Uint8Array(32), n => n % 64);
assert.deepEqual(fastResult.writes, Array.from({length: 1024}, (_, n) => (n % 64) | 192));
for (let j = 1; j < fastResult.reads.length; j++) {
  assert.equal(fastResult.reads[j] - fastResult.reads[j - 1], 3);
}
const freeStarts = instructions.filter(i => i.op === 'in' &&
  i.args[0] === 'r18' && Number(i.args[1]) === 6 && !covered.has(i.address));
assert.equal(freeStarts.length, 7, 'Seven remaining free-running loops');
const freePeriods = [];
for (const start of freeStarts) {
  const body = instructions.slice(instructions.indexOf(start));
  const countInsn = body.find(i => i.op === 'sbiw');
  const branch = code.get(countInsn.address + countInsn.bytes);
  const regs = new Uint8Array(32);
  regs[reg(countInsn.args[0]) + 1] = 4;
  const result = execute(start.address, branch.address + branch.bytes, regs, n => n % 64);
  assert.deepEqual(result.writes, Array.from({length: 1024}, (_, n) => n % 64));
  const period = result.reads[1] - result.reads[0];
  for (let j = 1; j < result.reads.length; j++) {
    assert.equal(result.reads[j] - result.reads[j - 1], period);
  }
  freePeriods.push(period);
}
assert.deepEqual(freePeriods.sort((a, b) => a - b), [8, 16, 32, 64, 128, 320, 640]);
console.log(`OSCARET: ${cases} AVR trigger timing/edge/UART cases and eight free-running rates passed.`);
