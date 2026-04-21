# Waveform-Gen-Basic
Task:
Waveform Generator Generate multiple waveform types and integrate them into a complete generator. Each student implements one waveform while coordinating output selection and timing.

What we want to make:
Basic generator of sine, square and triangle wave, that will send signal through mono audio output. It will show current state (frequency, selected wave) on 7-segments. You will navigate through different waveforms by pressing <> buttons. Frequency should be only choosable from (1, 10, 100, 1000) by pressing ^ button. Switch will be used for controlling output (on/off).

  # Detailed funcionality
  Buttons:
  We'll be using 4 buttons, 1 in every direction
  - UP -> increasing frequency
  - DOWN -> decreasing frequency
  - RIGHT -> changing waveform
  - LEFT -> changing waveform in the reverse direction

  Switch:
  - SW0 -> for turning output ON/OFF

  LEDs:
  - LED0 -> will light up when output is active

  7segments:
  - AN0-AN2 -> First 3 segments will be used for displaying which function is currently selected, such as (sin, tri, sqr) 
  - AN3 -> won't be used
  - AN4-AN7 -> 2nd half of the segments will be showing current frequency in one of states from: 0001 (1Hz), 0010 (10Hz), 0100 (100Hz), 1000 (1000Hz)
  <img width="288" height="44" alt="image" src="https://github.com/user-attachments/assets/b5c56192-0150-4124-96ba-df5e8b74932f" />


# TODO 1 week: 
  Klimt:
  Give tasks to the others,
  Create .xdc file, (constrain)

  Kovář:
  Create a block Scheme of Waveform Generator
 
  Krupenko:
  Manage github project,
  Make a SCRUM structure

# Description of source files in the project

Blocks:

- top.vhd --> main module that uses other modules and connects them together
  
  Inputs:
  * clk - 100 MHz system clock from the Nexys A7 board
  * btnu - Pushbutton for increasing frequency
  * btnd - Pushbutton for decreasing frequency
  * btnl - Pushbutton for switching between waveforms
  * btnr - Pushbutton for switching between waveforms
  * rst - Global reset button, usually a separate button on the board to initialize the system             
  * sw - General enable switch (acts as the clock enable for the generator)

  Outputs:
  * pwm - PWM signal sent to the mono audio jack
  * seg7 - Display segments
  * an - Display anodes (selects which digit is active)
    
- debouncer.vhd --> safety module for button

  Inputs:
  * clk - 100 MHz system clock from the Nexys A7 board
  * rst - Reset signal to clear internal shift registers/counters
  * btn_in - Noisy signal from physical button
  
  Outputs:
  * btn - A clean, one-clock-cycle pulse indicating a valid press
  
- fsm_logic.vhd --> brain - switches modules after button press
  
  Inputs:
  * clk - System clock
  * rst - Reset signal to return FSM to its default initial state
  * btnu - Trigger coming from the debouncer
  * btnd                --//--
  * btnl                --//--
  * btnr                --//--

  Outputs:
  * waves - A 2-bit control signal ("00" = Sine, "01" = Sawtooth/Triangle, "10" = Square)
  * freq_step - Phase increment value defining the output frequency

- counter_step.vhd --> counts the step (phase) for direct digital synthesis, we'll edit counter.vhd from lab4
  
  Inputs:
  * clk - system clock
  * rst - reset signal to clear the phase back to 0
  * ce - clock enable signal (controlled by a switch; if '0', the counter stops)
  * freq_step - Step size for the counter to change the frequency
 
  Outputs:
  * phase - current phase (an 8-bit value increasing from 0 to 255)

- seg7.vhd --> seg 7 display controller
  
  Inputs:
  * clk - System clock
  * rst - Reset signal to initialize the multiplexing counter
  * waves - Current state (selected wave) from the FSM
  * freq_step - Frequency state
 
  Outputs:
  * seg - signals for individual segments (A-G)
  * an - signals to activate specific digits

- wave_sine --> generates sine signal
  
  Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  Outputs:
  * wave_out - Calculated amplitude for sine wave (sample value from 0 to 255)
  
- wave_square --> generates square signal

  Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  Outputs:
  * wave_out - Calculated amplitude for square wave (sample value from 0 to 255)
  
- wave_triangle --> generates triangle signal

  Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  Outputs:
  * wave_out - Calculated amplitude for triangle wave (sample value from 0 to 255)

- pwm_out --> since nexys a7 board doesn't have d/ac converter, we'll use mono audio output and just send pwm signal through it
  
  Inputs:
  * clk - system clock
  * sample - current amplitude from the MUX
 
  Outputs:
  * pwm - A 1-bit high-speed toggling signal for mono audio out
  

<img width="1670" height="703" alt="schemaprojekt1 drawio" src="https://github.com/user-attachments/assets/b709ef1d-0407-4bb7-90f5-8967a7f56a40" />



# TODO 2 week: 
  Kovář:
  Edit top-level block diagram
  Define interconnection of all modules
  Prepare top-level entity skeleton
  Implement wave_square.vhd
  Create tb_wave_square.vhd

  Klimt:
  Implement fsm_logic.vhd
  Define waveform selection logic
  Define button-based navigation between settings
  Implement wave_triangle.vhd
  Create tb_wave_triangle.vhd
  Create seg7.vhd

  Krupenko:
  Manage GitHub repository structure
  Update README
  Implement wave_sine.vhd using LUT
  Create tb_wave_sine.vhd
  Collect simulation screenshots and Git updates

## Simulation (wave_sine)

The sine generator was verified using Vivado (XSIM).

Observed behavior:
- clock is stable (10 ns period)
- reset initializes the output to x"80"
- waveform updates only when `ce` is active
- output follows LUT values and is periodic

See waveform screenshot below.

## TODO – Week 3 (Integration)

### Kovář
- Help implement `waveform_mux`
- Connect all modules
- Ensure compatibility with `.xdc`
- Run synthesis

---

### Klimt
- Integrate `fsm_logic`
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
