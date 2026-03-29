# Router 1x3 — UVM Verification Project

A complete Universal Verification Methodology (UVM) testbench for a 1-input, 3-output packet router implemented in Verilog/SystemVerilog. The project covers RTL design, constrained-random stimulus generation, self-checking scoreboards, functional coverage, and SVA assertions.

---

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [RTL Design](#rtl-design)
  - [Top-Level](#top-level-router_topv)
  - [FSM](#finite-state-machine-router_fsmv)
  - [Register Module](#register-module-router_regv)
  - [FIFO](#fifo-router_fifov)
  - [Synchronizer](#synchronizer-router_syncv)
- [Verification Architecture](#verification-architecture)
  - [Interfaces](#interfaces)
  - [Transactions](#transactions)
  - [Agents](#agents)
  - [Sequences](#sequences)
  - [Virtual Sequences & Tests](#virtual-sequences--tests)
  - [Scoreboard](#scoreboard)
  - [Assertions](#sva-assertions)
- [Coverage](#coverage)
- [Simulation Flow](#simulation-flow)
  - [Mentor QuestaSim](#mentor-questasim)
  - [Synopsys VCS](#synopsys-vcs)
- [Makefile Targets](#makefile-targets)

---

## Overview

The Device Under Verification (DUV) is a **1×3 packet router**: it accepts an 8-bit serial data stream from a single source and routes packets to one of three output FIFOs based on a 2-bit destination address embedded in the packet header. Each output port has a 16-deep FIFO and an independent read-enable interface.

Key protocol features:

- **Header byte**: bits `[1:0]` carry the destination address (0, 1, or 2); bits `[7:2]` encode the payload length in bytes.
- **Parity checking**: the transmitter appends a parity byte; the router computes XOR parity over all bytes and flags mismatches on the `err` output.
- **Backpressure**: the router signals `busy` when it cannot accept new data, and stalls until the target FIFO drains.
- **Soft reset per port**: if a slave does not read within 30 clock cycles after `vld_out` is asserted, the corresponding FIFO is soft-reset.

---

## Project Structure

```
Router_project/
├── rtl/                        # Synthesisable Verilog RTL
│   ├── router_top.v            # Top-level integration
│   ├── router_fsm.v            # 8-state control FSM
│   ├── router_reg.v            # Header/parity register logic
│   ├── router_fifo.v           # 16×8 parameterised FIFO
│   ├── router_sync.v           # Address decoder & soft-reset counters
│   ├── master_interface.sv     # SV interface for the input (master) side
│   └── slave_interface.sv      # SV interface for output (slave) ports
│
├── master/                     # UVM master agent
│   ├── master_trans.sv         # Sequence item (transaction)
│   ├── master_agent_config.sv  # Configuration object
│   ├── master_agent.sv         # Agent class
│   ├── master_agent_top.sv     # Agent container (multi-agent wrapper)
│   ├── master_driver.sv        # BFM driver
│   ├── master_monitor.sv       # Passive monitor
│   ├── master_sequencer.sv     # Sequencer
│   └── master_seqs.sv          # small_seq / medium_seq / large_seq
│
├── slave/                      # UVM slave agent
│   ├── slave_trans.sv
│   ├── slave_agent_config.sv
│   ├── slave_agent.sv
│   ├── slave_agent_top.sv
│   ├── slave_driver.sv
│   ├── slave_monitor.sv
│   ├── slave_sequencer.sv
│   └── slave_seqs.sv           # delay_seq
│
├── tb/                         # Testbench environment
│   ├── top.sv                  # Top module — DUV instantiation + SVA assertions
│   ├── router_env.sv           # UVM environment
│   ├── scoreboard.sv           # Self-checking scoreboard + covergroups
│   ├── virtual_sequencer.sv    # Virtual sequencer
│   ├── virtual_seqs.sv         # small / medium / large virtual sequences
│   ├── env_config.sv           # Environment configuration object
│   └── tb_defs.sv              # Global defines
│
├── test/                       # UVM test classes
│   ├── router_pkg.sv           # Package that includes all TB files
│   └── router_test.sv          # router_test, small_test, medium_test, large_test
│
└── sim/                        # Simulation scripts & artefacts
    └── Makefile                # Multi-simulator Makefile (Questa & VCS)
```

---

## RTL Design

### Top-Level (`router_top.v`)

`router_top` instantiates and wires together the four sub-modules:

| Port | Width | Direction | Description |
|---|---|---|---|
| `data_in` | 8 | input | Serial data / header byte |
| `pkt_valid` | 1 | input | Asserted while a valid packet byte is on `data_in` |
| `clock` / `resetn` | 1 | input | Clock and active-low synchronous reset |
| `read_enb_0/1/2` | 1 | input | Read-enable from each slave |
| `data_out_0/1/2` | 8 | output | Data output to each slave |
| `vld_out_0/1/2` | 1 | output | FIFO not-empty flag for each slave |
| `err` | 1 | output | Parity error flag |
| `busy` | 1 | output | Router cannot accept new header |

Three identical `router_fifo` instances serve ports 0, 1, and 2 respectively.

---

### Finite-State Machine (`router_fsm.v`)

The FSM is encoded as a one-hot 8-bit state register with the following states:

| State | Encoding | Description |
|---|---|---|
| `DECODE_ADDRESS` | `8'h01` | Idle — waits for `pkt_valid` and decodes destination |
| `LOAD_FIRST_DATA` | `8'h02` | Loads the header byte into the FIFO |
| `LOAD_DATA` | `8'h04` | Streams payload bytes into the FIFO |
| `LOAD_PARITY` | `8'h08` | Captures the final parity byte |
| `FIFO_FULL_STATE` | `8'h10` | Stalls while target FIFO is full |
| `LOAD_AFTER_FULL` | `8'h20` | Resumes loading after FIFO drains |
| `WAIT_TILL_EMPTY` | `8'h40` | Waits for target FIFO to become empty before starting |
| `CHECK_PARITY_ERROR` | `8'h80` | Evaluates parity and asserts `err` if mismatch |

The `busy` output is asserted in all states except `DECODE_ADDRESS`. A per-port soft-reset (from the synchronizer) returns the FSM to `DECODE_ADDRESS` immediately.

---

### Register Module (`router_reg.v`)

Responsible for:

- **Header capture**: stores the first byte of every new packet.
- **Data muxing (`dout`)**: drives `LOAD_FIRST_DATA` → header byte; `LOAD_DATA` → current `data_in`; `LOAD_AFTER_FULL` → the byte held when the FIFO filled.
- **Parity computation**: running XOR over the header + all payload bytes; compared against the received parity byte to set `err`.
- **Control signals**: generates `parity_done` and `low_packet_valid` used by the FSM.

---

### FIFO (`router_fifo.v`)

A synchronous 16-deep × 9-bit FIFO (bit 8 is a "first-data" flag). Key properties:

- Circular buffer with 5-bit read/write pointers — the MSB is used for the full/empty distinction.
- **Full**: `wr_ptr[4] ≠ rd_ptr[4]` and lower nibbles match.
- **Empty**: `wr_ptr == rd_ptr`.
- An internal `counter` tracks remaining bytes in the current packet; when a header cell is read, the counter is loaded from `mem[rd_ptr][7:2]+1` for correct packet-boundary tracking.
- **Soft reset**: zeroes all memory locations and tri-states `data_out` (sets it to `8'bz`).

---

### Synchronizer (`router_sync.v`)

- **Address registration**: latches `data_in[1:0]` whenever `detect_add` is high.
- **`fifo_full` mux**: routes the full flag of the currently addressed FIFO to the FSM.
- **`write_enb` decoder**: asserts exactly one of the three write-enable lines based on the registered address and the FSM's `write_enb_reg`.
- **`vld_out`**: simply the complement of each FIFO's `empty` flag.
- **Soft-reset watchdog**: a 5-bit counter per port increments every cycle that `vld_out` is asserted but `read_enb` is not. On reaching 29, a one-cycle `soft_reset` pulse is issued and the counter clears.

---

## Verification Architecture

The testbench follows a layered UVM architecture:

```
┌──────────────────────────────────────────────────────┐
│                     router_test                       │
│          (small_test / medium_test / large_test)      │
└────────────────────────┬─────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────┐
│                     router_env                        │
│                                                       │
│  ┌─────────────────┐   ┌────────────────────────────┐ │
│  │ master_agent_top│   │    slave_agent_top          │ │
│  │  └ master_agent │   │  └ slave_agent[0]           │ │
│  │    ├ driver     │   │  └ slave_agent[1]           │ │
│  │    ├ monitor ───┼───┼──► scoreboard (m_fifo)      │ │
│  │    └ sequencer  │   │  └ slave_agent[2]           │ │
│  └─────────────────┘   │    ├ driver                 │ │
│                        │    ├ monitor ───► s_fifo[i] │ │
│                        │    └ sequencer               │ │
│                        └────────────────────────────┘ │
│                                                       │
│  ┌──────────────────────────────────────────────────┐ │
│  │             virtual_sequencer                    │ │
│  └──────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
                         │
         ┌───────────────▼──────────────────┐
         │          top.sv (TB top)          │
         │   DUV: router_top                 │
         │   SVA assertions                  │
         └───────────────────────────────────┘
```

---

### Interfaces

**`master_inf`** — single interface for the input side:

- Driver clocking block: drives `pkt_valid`, `resetn`, `data_in`; samples `busy`.
- Monitor clocking block: samples all four signals passively.

**`slave_inf`** — one interface per output port (three instances: `vif0`, `vif1`, `vif2`):

- Driver clocking block: drives `read_enb`; samples `vld_out`, `data_out`.
- Monitor clocking block: samples all three signals passively.

All interfaces use `default input #1 output #1` clocking skew.

---

### Transactions

**`master_trans`**: captures a full packet as sent by the master — `header`, `payload[]`, and `parity`. The header encodes the destination address in `[1:0]` and byte count in `[7:2]`.

**`slave_trans`**: captures a full packet as received on a slave port — `header`, `payload[]`, and `parity`, reconstructed by the slave monitor from the serial byte stream.

---

### Agents

**Master agent** (`master_agent`):
- Active by default (`UVM_ACTIVE`).
- `master_driver`: drives bytes cycle-by-cycle via the `driver_cb` clocking block, respecting `busy` backpressure.
- `master_monitor`: reconstructs complete packets from the wire-level byte stream and broadcasts them via `monitor_port` (TLM analysis port).

**Slave agent** (`slave_agent`):
- Active by default; one instance per output port.
- `slave_driver`: drives `read_enb` using the `delay_seq` sequence.
- `slave_monitor`: collects bytes from `data_out` whenever `vld_out && read_enb` and publishes completed `slave_trans` objects.

Both agent types are wrapped in an `_agent_top` container that creates and configures multiple sub-agents from an array-based configuration.

---

### Sequences

All master sequences extend `base_seq` (which extends `uvm_sequence #(master_trans)`). The destination address is fetched from `uvm_config_db` and constrained in the randomization:

| Sequence | Payload size (bytes) | Constraint |
|---|---|---|
| `small_seq` | 1–15 | `header[7:2] inside {[1:15]}` |
| `medium_seq` | 16–31 | `header[7:2] inside {[16:31]}` |
| `large_seq` | 32–63 | `header[7:2] inside {[32:63]}` |

The slave uses `delay_seq` to periodically assert `read_enb`, simulating a consumer that may be slow (triggering the watchdog soft-reset path) or fast.

---

### Virtual Sequences & Tests

Three virtual sequences (`small_vseq`, `medium_vseq`, `large_vseq`) fork the corresponding master sequence and the slave `delay_seq` in parallel, ensuring the slave is reading while the master is writing.

The test hierarchy:

| Test class | Virtual sequence | Address |
|---|---|---|
| `router_test` | (base — no run_phase) | — |
| `small_test` | `small_vseq` | random (0–2) |
| `medium_test` | `medium_vseq` | random (0–2) |
| `large_test` | `large_vseq` | random (0–2) |

The test sets the destination address via `uvm_config_db` before starting the virtual sequence so both master and slave sequences target the same port.

---

### Scoreboard

`scoreboard` extends `uvm_scoreboard` and receives packets through two sets of TLM FIFOs:

- `m_fifo` — one FIFO fed by the master monitor.
- `s_fifo[0..2]` — one FIFO per slave monitor.

The `run_phase` runs two parallel `forever` threads:
1. Drains `m_fifo`, prints and samples the `router_S` covergroup.
2. Waits on whichever slave FIFO produces data first (`join_any`), prints and samples `router_D`, then calls `compare()`.

`compare()` checks `header`, `payload`, and `parity` equality between the master and slave transactions, printing pass/fail per field.

---

### SVA Assertions

Eight concurrent SVA properties are bound in `top.sv`:

| Label | Property | Intent |
|---|---|---|
| `C1` | `busy \|=> $stable(data_in)` | Input data must not change while router is busy |
| `C2` | `$rose(pkt_valid) \|=> busy` | Router asserts `busy` one cycle after packet starts |
| `C3–C5` | `vld_out_N \|-> ##[1:29] read_enb_N` | Slave must read within 29 cycles of `vld_out` |
| `C6–C8` | `$fell(vld_out_N) \|=> $fell(read_enb_N)` | `read_enb` must de-assert once FIFO empties |

---

## Coverage

### Functional Covergroups (in `scoreboard`)

**`router_S`** — samples source (master) transaction:

| Coverpoint | Bins |
|---|---|
| `ADDER` — destination address | `address0`, `address1`, `address2` |
| `PAYLOAD` — packet size (header`[7:2]`) | `small_S` (1–16), `medium_S` (17–35), `large_S` (36–63) |
| `ERROR` — parity result | `correct` (0), `wrong_D` (1) |

**`router_D`** — samples destination (slave) transaction:

| Coverpoint | Bins |
|---|---|
| `ADDER_D` | `address0`, `address1`, `address2` |
| `PAYLOAD_D` | `small_D`, `medium_D`, `large_D` |

### Code Coverage (via simulator flags)

Both simulators are invoked with full code-coverage instrumentation:

- **Questa**: `-coverage -sva` → line, toggle, FSM, branch, condition + SVA coverage.
- **VCS**: `-cm line+tgl+fsm+branch+cond` → same metric set; FSDB waveform dumped via Verdi PLI.

---

## Simulation Flow

### Prerequisites

- Mentor QuestaSim **or** Synopsys VCS (with UVM 1.2 or IEEE 1800.2 library).
- For VCS waveform viewing: Synopsys Verdi; the `FSDB_PATH` in the Makefile must point to your Verdi installation.

### Mentor QuestaSim

```bash
cd sim/

# Compile only
make sv_cmp

# Run individual tests
make run_test      # router_test  (base test)
make run_test1     # small_test
make run_test2     # medium_test
make run_test3     # large_test

# Run full regression + merge coverage
make regress

# View waveforms (ModelSim GUI)
make view_wave1    # wave for router_test
make view_wave2    # wave for small_test
make view_wave3    # wave for medium_test
make view_wave4    # wave for large_test

# Open merged HTML coverage report
make cov
```

### Synopsys VCS

```bash
cd sim/

# Switch simulator (edit Makefile or override on command line)
make SIMULATOR=VCS sv_cmp

make SIMULATOR=VCS run_test      # router_test
make SIMULATOR=VCS run_test1     # small_test
make SIMULATOR=VCS run_test2     # medium_test
make SIMULATOR=VCS run_test3     # large_test

make SIMULATOR=VCS regress       # full regression

# View waveforms in Verdi
make SIMULATOR=VCS view_wave1

# Open merged coverage in Verdi
make SIMULATOR=VCS cov
```

---

## Makefile Targets

| Target | Description |
|---|---|
| `help` | Print usage summary |
| `clean` | Remove all logs, coverage databases, waveform files, and compiled libraries |
| `sv_cmp` | Create work library and compile all RTL + TB files |
| `run_test` | Compile + run `router_test` in batch mode; generate HTML coverage |
| `run_test1` | Compile + run `small_test` |
| `run_test2` | Compile + run `medium_test` |
| `run_test3` | Compile + run `large_test` |
| `view_wave1–4` | Open the corresponding waveform file in the simulator GUI |
| `regress` | `clean` → compile → run all four tests → merge coverage |
| `report` | Merge per-test coverage databases into a single report |
| `cov` | Open merged HTML coverage report in browser (Firefox) / Verdi |

Each test run saves its coverage database (`mem_cov1`–`mem_cov4` for Questa; `mem_cov1.vdb`–`mem_cov4.vdb` for VCS). The `report` target merges them and generates a unified HTML report.

---

## Notes

- The Makefile defaults to **Questa** (`SIMULATOR = Questa`). Override with `make SIMULATOR=VCS <target>` for VCS.
- `FSDB_PATH` in the Makefile must be updated to match the local Verdi installation path before running with VCS.
- All tests randomize the destination address per run (`$random % 3`), so repeated runs naturally explore all three output ports.
- The soft-reset watchdog (30-cycle timeout) is exercised whenever the slave `delay_seq` holds `read_enb` low long enough — the `large_test` is most likely to trigger this path due to longer packets.
