# Waveform-Gen-Basic
Task:
Waveform Generator Generate multiple waveform types and integrate them into a complete generator. Each student implements one waveform while coordinating output selection and timing.

What we want to make:
Basic generator of sine, square and triangle wave, that will send signal through mono audio output. It will show current state (frequency, selected wave) on 7-segments. You will navigate through different waveforms by pressing <> buttons. Frequency should be only selectable from (1, 10, 100, 1000) by pressing ^ button. Switch will be used for controlling output (on/off).

# Detailed functionality
  Buttons:
  We'll be using 4 buttons, 1 in every direction
  - UP -> increasing frequency
  - DOWN -> decreasing frequency
  - RIGHT -> changing waveform
  - LEFT -> changing waveform in the reverse direction

  ###Switch:
  - SW0 -> for turning output ON/OFF

  ###LEDs:
  - LED0 -> will light up when output is active

  ###7segments:
  - AN0-AN2 -> First 3 segments will be used for displaying which function is currently selected, such as (sin, tri, sqr) 
  <img width="291" height="44" alt="image" src="https://github.com/user-attachments/assets/c5fe02f8-ef26-43a7-beb8-43177056f1f3" />
  
  - AN3 -> won't be used
    
  - AN4-AN7 -> 2nd half of the segments will be showing current frequency from: ---1 (1Hz), --10 (10Hz), -100 (100Hz), 1000 (1000Hz)
  <img width="499" height="46" alt="image" src="https://github.com/user-attachments/assets/01af83c4-a4dd-464c-965b-2fe69f829a4c" />

## Architecture

The design is based on a hybrid timing approach combining **Clock Enable (CE)** and **Direct Digital Synthesis (DDS)**.

### How the system works

Buttons → Debounce → FSM → freq_step + sel_wave  
freq_step → counter_step → phase  
phase → wave generators → waveform_mux → output  

### Description

- clk_en generates a slower enable signal (ce)
- fsm_logic controls waveform selection and frequency (freq_step)
- counter_step uses ce and freq_step to generate DDS phase
- waveform generators (wave_sine, wave_triangle, wave_square) generate signals based on phase
- waveform_mux selects the active waveform
- the selected signal is routed to:
  - pwm_out (audio output)
  - seg7 (display)
  - LEDs (debug)

---

## Resource utilization

| Resource | Usage |
|----------|-------|
| LUT      | TBD   |
| FF       | TBD   |

## Week 1 – Architecture Design
### Klimt:
  - Give tasks to the others,
  - Create .xdc file, (constrain)

### Kovář:
  - Create a block Scheme of Waveform Generator
 
### Krupenko:
  - Manage github project,
  - Make a SCRUM structure

# Description of source files in the project

Blocks:

- top.vhd --> main module that uses other modules and connects them together
  ## Top-level

- 📄 [top.vhd](generator/VScode/top.vhd)  
  Main integration module connecting all components

- 📄 [top_tb.vhd](generator/VScode/top_tb.vhd)  
  Testbench for full system simulation
  
### Inputs:
  * clk - 100 MHz system clock from the Nexys A7 board
  * rst - Global reset button, usually a separate button on the board to initialize the system   
  * btnu - Pushbutton for increasing frequency
  * btnd - Pushbutton for decreasing frequency
  * btnl - Pushbutton for switching between waveforms
  * btnr - Pushbutton for switching between waveforms       
  * sw - General enable switch (acts as the clock enable for the generator)

### Outputs:
  * led - Lights up small green diode on the board when switch is on
  * pwm - PWM signal sent to the mono audio jack
  * seg - Display segments
  * an - Display anodes (selects which digit is active)
  * aud_sd - Turns on amplifier so that signal can be "heard"
    
- debounce.vhd --> safety module for button

  - 📄 [debounce.vhd](generator/VScode/debounce.vhd)  
  Button debouncing module (removes noise)

### Inputs:
  * clk - 100 MHz system clock from the Nexys A7 board
  * rst - Reset signal to clear internal shift registers/counters
  * btn_in - Noisy signal from physical button
  
### Outputs:
  * btn_state - A clean, one-clock-cycle pulse indicating a valid press
  * btn_press - Creates one short pulse (10ns) in the moment of press

- clk_en.vhd --> time "slower", converts fast clock signal to slower pulses
  
  - 📄 [clk_en.vhd](generator/VScode/clk_en.vhd)  
  Clock enable generator (creates `ce` signal)

### Inputs:
  * clk - 100 MHz system clock from the Nexys A7 board
  * rst - Reset signal to clear internal shift registers/counters
  
### Outputs:
  * ce - one clock-cycle enable pulse

- fsm_logic.vhd --> brain - switches modules after button press
  
  - 📄 [fsm_logic.vhd](generator/VScode/fsm_logic.vhd)  
  Control unit (waveform + frequency selection)

  - 📄 [fsm_logic_tb.vhd](generator/VScode/fsm_logic_tb.vhd)  
  FSM simulation
  
### Inputs:
  * clk - System clock
  * rst - Reset signal to return FSM to its default initial state
  * btnu - Clear signal from debouncer to increase frequency 
  * btnd - Clear signal from debouncer to decrease frequency 
  * btnl - Clear signal from debouncer to change waveform 
  * btnr - Clear signal from debouncer to change waveform

### Outputs:
  * waves - A 2-bit control signal ("00" = Sine, "01" = Triangle, "10" = Square)
  * freq_step - Phase increment value defining the output frequency

- counter_step.vhd --> counts the step (phase) for direct digital synthesis, we'll edit counter.vhd from lab4
  
  - 📄 [counter_step.vhd](generator/VScode/counter_step.vhd)  
  DDS phase accumulator (uses `ce` + `freq_step`)

### Inputs:
  * clk - system clock
  * rst - reset signal to clear the phase back to 0
  * ce - clock enable signal controlled by a switch
  * freq_step - Step size for the counter to change the frequency
 
### Outputs:
  * phase - current phase (an 8-bit value increasing from 0 to 255)

- seg7.vhd --> seg 7 display controller
  
  - 📄 [seg7.vhd](generator/VScode/seg7.vhd)  
  Seven-segment display controller

- 📄 [seg7_tb.vhd](generator/VScode/seg7_tb.vhd)  
  Display simulation
  
### Inputs:
  * clk - System clock
  * rst - Reset signal to initialize the multiplexing counter
  * waves - Current state (selected wave) from the FSM
  * freq_step - Frequency state
 
### Outputs:
  * seg - signals for individual segments (A-G)
  * an - signals to activate specific digits

- wave_sine --> generates sine signal

  - 📄 [wave_sine.vhd](generator/VScode/wave_sine.vhd)  
  Sine generator (LUT-based)

  - 📄 [wave_sine_tb.vhd](generator/VScode/wave_sine_tb.vhd)  
  Sine simulation

  ###Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  ###Outputs:
  * wave_out - Calculated amplitude for sine wave (sample value from 0 to 255)
  
- wave_square --> generates square signal
  
  - 📄 [wave_square.vhd](generator/VScode/wave_square.vhd)  
  Square wave generator

  - 📄 [wave_square_tb.vhd](generator/VScode/wave_square_tb.vhd)  
  Square simulation

  ###Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  ###Outputs:
  * wave_out - Calculated amplitude for square wave (sample value from 0 to 255)
  
- wave_triangle --> generates triangle signal

  - 📄 [wave_triangle.vhd](generator/VScode/wave_triangle.vhd)  
  Triangle wave generator

  - 📄 [wave_triangle_tb.vhd](generator/VScode/wave_triangle_tb.vhd)  
  Triangle simulation
  
  ###Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  ###Outputs:
  * wave_out - Calculated amplitude for triangle wave (sample value from 0 to 255)

- pwm_out --> since nexys a7 board doesn't have d/ac converter, we'll use mono audio output and just send pwm signal through it

  - 📄 [pwm_out.vhd](generator/VScode/pwm_out.vhd)  
  Converts waveform to PWM signal (audio output)
  
  ###Inputs:
  * clk - system clock
  * rst - Reset signal to initialize the multiplexing counter
  * sample - current amplitude from the MUX (top.vhd)
 
  ###Outputs:
  * pwm - A 1-bit high-speed toggling signal for mono audio out
  

<img width="1674" height="702" alt="schemade1 drawio" src="https://github.com/user-attachments/assets/b4be6e1b-3901-4f19-8ca7-24e2a0b95b04" />


## Week 2 – Module Development

### Kovář:
  - Edit top-level block diagram
  - Define interconnection of all modules
  - Prepare top-level entity skeleton
  - Implement wave_square.vhd
  - Create tb_wave_square.vhd

### Klimt:
  - Implement fsm_logic.vhd
  - Define waveform selection logic
  - Define button-based navigation between settings
  - Implement wave_triangle.vhd
  - Create tb_wave_triangle.vhd
  - Create seg7.vhd

### Krupenko:
  - Manage GitHub repository structure
  - Update README
  - Implement wave_sine.vhd using LUT
  - Create tb_wave_sine.vhd
  - Collect simulation screenshots and Git updates

## Simulation

### fsm_logic
- Shows reaction (outputs: waves, freq_step) on the current state set by buttons up, down, left, right (inputs: btnu, btnd, btnl, btnr)
- The circle navigation logic should be seen from the picture (sin -> tri -> sqr -> sin...)

<img width="521" height="283" alt="fsm_logic_tb" src="https://github.com/user-attachments/assets/25e98a90-3656-4f8a-b596-61c411440cbb" />

### seg7
- It should show every possible combination that should be displayed, unfortunately, we didn't manage to show all output states at once, but if you zoom enough, it looks like it works
<img width="521" height="283" alt="seg7_tb" src="https://github.com/user-attachments/assets/d1d30261-daee-4c52-99a3-774247b7fe3c" />

### wave_sine
- We changed wave_out to analog, so it's displayed as real sine wave, interpolation style is Linear
- Upon closer inspection (after zoom), you could see very smooth sine wave 
<img width="521" height="283" alt="wave_sine_tb" src="https://github.com/user-attachments/assets/14bbdd64-7f5c-4e3c-ab0b-65df04ec5f2b" />

### wave_square
- After changing interpolation style to 'Hold' instead of 'Linear', square wave can be seen
<img width="521" height="283" alt="wave_square_tb" src="https://github.com/user-attachments/assets/94f38786-59f6-4c6e-a660-65a2e23aa69d" />

### wave_triangle
- Triangle wave (wave_out is set to Linear interpolation again)
<img width="521" height="283" alt="wave_triangle_tb" src="https://github.com/user-attachments/assets/47fb8c06-257d-41a1-aadf-0ef3d47c6746" />


## Week 3 – Integration

### Kovář
- Help implement `top.vhd`
- Connect all modules
- Ensure compatibility with `.xdc`
- Update schematic

---

### Klimt
- Integrate `fsm_logic`
- Create `top.vhd`
- Connect buttons and control signals
- Implement waveform switching

---

### Krupenko
- Integrate `wave_sine`
- Implement `top.vhd`
- Update README
- Verify simulation
- Manage Git

---

## Expected result
- working top-level design  
- waveform selection functional  
- output visible on LED / PWM  
- synthesis successful

---

### Completed work
- Created initial version of `top.vhd`
- Connected core modules:
  - `clk_en`
  - `fsm_logic`
  - `wave_sine`, `wave_square`, `wave_triangle`
  - `pwm_out`
- Unified signal interfaces between modules (clk, rst, ce)
- Implemented waveform selection using `sel_wave`
- Verified correct data flow:
  - buttons → FSM → control signals
  - `clk_en` → `ce_wave`
  - waveform modules → `waveform_mux`
  - mux output → PWM / LED
- Tested integration in simulation (basic functionality verified)
- Updated block diagram to reflect real

---

## Week 4 (Tuning, Debugging, Code Optimization, Git Documentation)

### Kovář
- Finalize top-level block diagram so it exactly matches implemented modules
- Help finish `top.vhd` interconnection
- Check consistency between README, schematic, and actual signal names
- Help verify `.xdc` compatibility with top-level ports
- Assist with synthesis/debugging in Vivado

### Klimt
- Debug and tune `fsm_logic`
- Verify correct waveform switching:
  - sine -> triangle -> square -> sine
- Verify frequency switching:
  - 1 -> 10 -> 100 -> 1000
- Debug button handling with `debounce`
- Help validate `seg7` outputs in simulation and hardware

### Krupenko
- Finish integration of waveform path in `top.vhd`
- Connect:
  - `clk_en`
  - `counter_step`
  - waveform generators
  - mux
  - `pwm_out`
- Verify full-system simulation (`top_tb.vhd`)
- Update README:
  - architecture description
  - week 3 progress
  - simulation results
- Manage Git:
  - commits
  - structure
  - documentation cleanup

## Expected result for Week 4
- Completed `top.vhd`
- Successful synthesis
- Correct waveform generation in hardware
- Working waveform and frequency switching
- Display output functional
- PWM output functional
- Updated README and Git documentation
- Fixed inconsistencies between modules (signal naming, I/O)

### Current state
- Top-level structure is functional
- Waveform selection works
- All waveform generators are integrated
- Simulation of individual modules is verified
- Partial system-level simulation completed
