# 🐍 Snake Game on Basys3 FPGA

This project implements the classic **Snake Game** entirely in **parameterized Verilog** on a **Basys3 FPGA**.  
It features smooth VGA graphics, PS/2 keyboard input, and a 7-segment score display — all running from a 100 MHz system clock.

---

## 🎯 Features
- **Smooth 20 Hz gameplay** with pixel-accurate VGA rendering at 800×600 @ 72 Hz
- **PS/2 keyboard input** for arrow key control (with 180° reversal prevention)
- **Random food generation** via 13-bit Galois LFSR with collision avoidance
- **Collision detection** for walls and self-intersections
- **Score counter** in 4-digit BCD on 7-segment display
- **Game Over screen** with 16-level grayscale fade/invert effect
- Fully modular, parameterized Verilog design


---

## 🖥 Hardware Requirements
- **Board:** Digilent Basys3 FPGA
- **Display:** VGA monitor (800×600 @ 72 Hz)
- **Input:** PS/2 keyboard
- **Output:** Onboard 4-digit 7-segment display
- **Clock:** 100 MHz onboard oscillator

---

## ⚙️ System Architecture
The design is divided into three main stages:

1. **Input Stage**  
   - **Debouncer** filters btnC reset input.  
   - **Ps2_Interface** reads PS/2 scancodes at falling PS2Clk edges.  
   - **Direction_Decoder** maps arrow keys to 2-bit directions and blocks 180° reversals.

2. **Logic Stage**  
   - **Game_FSM**: 3-state synchronous Mealy FSM controlling frame timing, updates, scoring, and game-over state.  
   - **Snake_Logic**: Maintains and updates the snake’s body.  
   - **Food_Generator**: LFSR-based pseudo-random food placement avoiding collisions.  
   - **Collision_Detector**: Detects food consumption and collisions.  
   - **Score_Counter**: Cascaded BCD counters for 4-digit score.

3. **Output Stage**  
   - **Snake_Renderer**: Draws snake, food, or “GAME OVER” text with fade effect.  
   - **VGA_Interface**: Generates VGA syncs and pixel coordinates.  
   - **Seg_7_Display**: Multiplexes and drives the score display.

---

## 🚀 How to Build and Run
1. Open **Vivado** and create a new RTL project.
2. Add all `.v` source files from `src/` and constraints from `constraints/`.
3. Set **Top Module** to `SnakeTop`.
4. Synthesize, implement, and generate the bitstream.
5. Program the Basys3 FPGA.
6. Connect PS/2 keyboard and VGA monitor, then press **btnC** to start.

---

## 🔍 Key Parameters
- **GRID_W / GRID_H**: Grid size (100×75)
- **POS_BITS**: Index bit-width for grid (13 bits)
- **MAX_LEN**: Max snake length (100 segments)
- **TICKS_PER_FRAME**: Frame rate (default 5,000,000 → 20 Hz at 100 MHz)

---

## 📝 Notes
- Two secondary clocks are used (PS2Clk, VGA pixel clock) and directly drive registers — Vivado flags these, but they are isolated and intentional.
- Timing report shows all constraints met with positive setup/hold slack.

---
