# Smart 4-Floor Lift Controller

A four-floor lift controller implemented in Verilog HDL and targeted at the **TUL PYNQ-Z2 FPGA development board** (Xilinx Zynq-7020, `xc7z020clg400-1`). The controller uses a directional **SCAN (elevator) scheduling** approach to service floor requests along its current direction of travel before reversing.

This project was developed as part of **ECE2002 – Digital Electronics Lab, Monsoon 2026**, at Shiv Nadar University.

## Features

- Four-floor request handling using a pending-request bitmap.
- Finite State Machine (FSM) for idle, upward travel, downward travel, door-open and door-hold states.
- Directional SCAN scheduling with lookahead for requests along the current travel path.
- Synchronous controller logic driven by the board's 125 MHz clock.
- Two-flip-flop synchronisation for asynchronous switch inputs.
- Debouncing and rising-edge detection for mechanical push-button inputs.
- LED status outputs for floor position, movement direction and door state.
- Configurable movement, door and debounce timing parameters for faster simulation.

## Hardware

| Resource | Function |
|---|---|
| PYNQ-Z2 / Zynq-7020 FPGA | Target device |
| 125 MHz oscillator | Main clock |
| BTN0–BTN3 | Floor-call inputs (floors 0–3) |
| SW0 | Reset control |
| SW1 | Door-hold control |
| LD0–LD3 | One-hot floor-position indication |
| RGB LED LD4 | Cabin / door status |
| RGB LED LD5 | Direction / alert status |

The pin assignments and I/O standards are defined in [`constraints/lift_pins.xdc`](constraints/lift_pins.xdc).

## Repository layout

```text
smart-lift-controller/
├── README.md
├── src/
│   ├── debounce.v
│   ├── lift_fsm.v
│   └── lift_top.v
├── constraints/
│   └── lift_pins.xdc
├── simulation/
│   └── tb_lift_top.v
├── docs/
│   ├── project-report.pdf
│   └── presentation.pdf
└── .gitignore
```

## RTL modules

- **`lift_top.v`** – Top-level integration. Synchronises switch inputs, instantiates the button debouncers and connects the controller to the board I/O.
- **`lift_fsm.v`** – Main lift controller FSM, request tracking, directional scheduling, floor transitions and LED status encoding.
- **`debounce.v`** – Two-stage input synchronisation, digital stability counter and single-cycle rising-edge pulse generation for push buttons.

## Simulation

The testbench is in `simulation/tb_lift_top.v`. It instantiates `lift_top` with shortened timing parameters so that movement and door behaviour can be exercised more quickly in simulation.

Compile the three RTL modules together with the testbench using a Verilog simulator such as **Icarus Verilog**:

```bash
iverilog -g2012 -s tb_lift_top -o lift_sim \
  src/debounce.v src/lift_fsm.v src/lift_top.v \
  simulation/tb_lift_top.v
vvp lift_sim
```

The testbench uses `$display`/`$monitor` output; inspect the source for the scenarios and expected signal behaviour. The provided testbench is a functional simulation aid, not a formal verification suite.

## Build with Vivado

1. Create or open a Vivado RTL project targeting `xc7z020clg400-1`.
2. Add all three files from `src/` as design sources.
3. Add `constraints/lift_pins.xdc` as the constraints file.
4. Set `lift_top` as the top-level module.
5. Run synthesis, implementation and bitstream generation.
6. Program the PYNQ-Z2 board with the generated bitstream.

The default timing parameters correspond to the 125 MHz board clock. The simulation testbench overrides these parameters with smaller values.

## Project documentation

- [`docs/project-report.pdf`](docs/project-report.pdf) – Project report, architecture, hardware mapping and contribution breakdown.
- [`docs/presentation.pdf`](docs/presentation.pdf) – Project presentation.

## Team and individual contribution

This was a team project. The report records the team's contributions. **Hemang Jindal's contribution** was the lift controller FSM (`lift_fsm.v`), directional SCAN scheduling, request queue and floor transitions. Please refer to the report for the full team contribution breakdown.

## Tools and technologies

Verilog HDL · FPGA · Xilinx Vivado · PYNQ-Z2 · Finite State Machines · Digital Logic Design
