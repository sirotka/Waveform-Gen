# Waveform-Gen-Basic
  Waveform Generator Generate multiple waveform types and integrate them into a complete generator. Each student implements one waveform while coordinating output       selection and timing.

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
- counter_step.vhd --> counts the step (phase) for direct digital synthesis, we'll edit counter.vhd from lab4
- debouncer.vhd --> safety module for button
- seg7.vhd --> seg 7 display controller
- wave_sine --> generates sine signal
- wave_square --> generates square signal
- wave_triangle --> generates triangle signal
- pwm_out --> since nexys a7 board doesn't have d/ac converter, we'll use mono audio output and just send pwm signal through it
  
