# Waveform-Gen-Basic
Task:
Waveform Generator Generate multiple waveform types and integrate them into a complete generator. Each student implements one waveform while coordinating output selection and timing.

What we want to make:
Basic generator of sine, square and triangle wave, that will send signal through mono audio output. It will show current state (frequency, selected wave...) on seven-segment. You will navigate through different settings by pressing different buttons.
Frequency is only controlable by choosing from (1, 10, 100, 1000) displayed on 7-segments

  # Detailed funcionality
  Buttons:
  We'll be using 5 buttons, 4 in every direction and 1 in the center
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


# TODO 2 week: 
  Klimt
  Give tasks to the others,
  Create .xdc file, (constrain)

  Kovář
  Edit a block Scheme of Waveform Generator
 
  Krupenko:
  Manage github project,
  Make a SCRUM structure

# Description of source files in the project

Blocks:

- top.vhd --> main module that uses other modules and connects them together
  
  Inputs:
  * clk - 100 MHz system clock from the Nexys A7 board
  * btnu - Pushbutton for switching between waveforms
  * rst - Global reset button, usually a separate button on the board to initialize the system             
  * switch - General enable switch (acts as the clock enable for the generator)

  Outputs:
  * pwm - PWM signal sent to the mono audio jack
  * seg7 - Display segments
  * an - Display anodes (selects which digit is active)
    
- debouncer.vhd --> safety module for button

  Inputs:
  * clk - 100 MHz system clock from the Nexys A7 board
  * rst - Reset signal to clear internal shift registers/counters
  * btnu - Noisy signal from physical button
  
  Outputs:
  * btnd - A clean, one-clock-cycle pulse indicating a valid press
  
- fsm_logic.vhd --> brain - switches modules after button press
  
  Inputs:
  * clk - system clock
  * rst - Reset signal to return FSM to its default initial state
  * btnd - trigger coming from the debouncer

  Outputs:
  * waves - A 2-bit control signal ("00" = Sine, "01" = Sawtooth/Triangle, "10" = Square)

- counter_step.vhd --> counts the step (phase) for direct digital synthesis, we'll edit counter.vhd from lab4
  
  Inputs:
  * clk - system clock
  * rst - reset signal to clear the phase back to 0
  * ce - clock enable signal (controlled by a switch; if '0', the counter stops)
 
  Outputs:
  * phase - current phase (an 8-bit value increasing from 0 to 255)

- seg7.vhd --> seg 7 display controller
  
  Inputs:
  * clk - system clock
  * rst - reset signal to initialize the multiplexing counter
  * waves - current state (selected wave) from the FSM
 
  Outputs:
  * seg7 - signals for individual segments (A-G)
  * an - signals to activate specific digits

- wave_sine --> generates sine signal
  
  Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  Outputs:
  * sine - Calculated amplitude for sine wave (sample value from 0 to 255)
  
- wave_square --> generates square signal

  Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  Outputs:
  * square - Calculated amplitude for square wave (sample value from 0 to 255)
  
- wave_triangle --> generates triangle signal

  Inputs:
  * clk - system clock
  * phase - current phase (an 8-bit value increasing from 0 to 255)

  Outputs:
  * triangle - Calculated amplitude for triangle wave (sample value from 0 to 255)

- pwm_out --> since nexys a7 board doesn't have d/ac converter, we'll use mono audio output and just send pwm signal through it
  
  Inputs:
  * clk - system clock
  * sample - current amplitude from the MUX
 
  Outputs:
  * seg7 - signals for individual segments (A-G)
  * pwm - A 1-bit high-speed toggling signal for mono audio out
  

<img width="1670" height="703" alt="schemaprojekt1 drawio" src="https://github.com/user-attachments/assets/b709ef1d-0407-4bb7-90f5-8967a7f56a40" />



# TODO 2 week: 
  Kovář
  Create top-level block diagram
  Define interconnection of all modules
  Prepare top-level entity skeleton
  Implement wave_square.vhd
  Create tb_wave_square.vhd

  Klimt
  Implement fsm_logic.vhd
  Define waveform selection logic
  Define button-based navigation between settings
  Implement wave_triangle.vhd
  Create tb_wave_triangle.vhd

  Krupenko
  Manage GitHub repository structure
  Update README
  Implement wave_sine.vhd using LUT
  Create tb_wave_sine.vhd
  Collect simulation screenshots and Git updates


## TODO – Week 3 (Integration)

### Kovář
- Implement `top.vhd`
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
- Help implement `waveform_mux`
- Update README
- Verify simulation
- Manage Git

---

## Expected result
- working top-level design  
- waveform selection functional  
- output visible on LED / PWM  
- synthesis successful
