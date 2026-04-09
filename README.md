# Waveform-Gen-Basic
Task:
Waveform Generator Generate multiple waveform types and integrate them into a complete generator. Each student implements one waveform while coordinating output selection and timing.

What we want to make:
Basic generator of sine, square and triangle wave, that will send signal through mono audio output. It will show current state (frequency, selected wave...) on seven-segment. You will navigate through different settings by     pressing button.


# TODO: 
  Klimt
  Give tasks to the others,
  Create modules for the block scheme and describes them

  Kovář
  Create a Block Scheme of Waveform Generator
 
  Krupenko:
  Manage github project,
  Make a SCRUM structure

# Description of source files in the project

Blocks:

- top.vhd --> main module that uses other modules and connects them together
  Inputs:  * clock - 100 MHz system clock from the Nexys A7 board
           * btnu - Pushbutton for switching between waveforms             
           * switch -

  Outputs: * pwm - PWM signal sent to the mono audio jack
           * seg7 - Display segments
           * led - Display anodes (selects which digit is active)
- fsm_logic.vhd --> brain - switches modules after button press
- counter_step.vhd --> counts the step (phase) for direct digital synthesis, we'll edit counter.vhd from lab4
- debouncer.vhd --> safety module for button
- seg7.vhd --> seg 7 display controller
- wave_sine --> generates sine signal
- wave_square --> generates square signal
- wave_triangle --> generates triangle signal
- pwm_out --> since nexys a7 board doesn't have d/ac converter, we'll use mono audio output and just send pwm signal through it

  <img width="741" height="421" alt="projekt drawio" src="https://github.com/user-attachments/assets/934f5929-7e4b-41dc-a9ed-6645892027fc" />

