-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : counter_step.vhd
-- Author      : Krupenko
-- Institution : Brno University of Technology (VUT)
-- Faculty     : Faculty of Electrical Engineering and Communication (FEKT)
-- Course      : Digital Electronics 1 / VHDL Project 2026
--
-- Description :
-- This project implements a basic waveform generator on the Nexys A7-50T FPGA
-- board. The system is capable of generating three types of signals:
-- sine, triangle, and square wave.
--
-- The design uses a hybrid architecture:
-- - clk_en generates a clock enable signal (ce)
-- - counter_step implements DDS phase accumulation
-- - waveform modules generate signals based on phase
-- - waveform_mux selects the active waveform
-- - pwm_out converts the signal to PWM for audio output
-- - seg7 displays waveform type and frequency
--
-- User Control :
-- - Buttons are used to change waveform and frequency
-- - Switch enables/disables output
-- - LEDs indicate system state
--
-- Target Device :
-- Digilent Nexys A7-50T (Xilinx Artix-7 FPGA)
--
-- Notes :
-- This project was developed as part of a laboratory assignment.
-- All modules are designed using synchronous logic principles.
--
-- ============================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter_step is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        ce         : in  std_logic; -- Clock enable (controlled by switch)
        freq_step  : in  std_logic_vector(11 downto 0); -- Phase increment from FSM
        phase      : out std_logic_vector(7 downto 0)   -- Output phase for wave generators
    );
end entity counter_step;

architecture Behavioral of counter_step is
    -- Internal 16-bit register for the phase accumulator
    -- Using more bits internally allows for finer frequency control
    signal accum : unsigned(15 downto 0) := (others => '0');
begin

    ----------------------------------------------------------------
    -- Phase Accumulator Process
    ----------------------------------------------------------------
    p_accumulator : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset the accumulator to zero
                accum <= (others => '0');
            elsif ce = '1' then
                -- The core of DDS: instead of +1, we add the step value
                -- This controls how fast the counter overflows
                accum <= accum + unsigned(freq_step);
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Output assignment
    ----------------------------------------------------------------
    -- We take the 8 most significant bits (MSB) as the current phase.
    -- This 8-bit value will cycle from 0 to 255.
    phase <= std_logic_vector(accum(15 downto 8));

end architecture Behavioral;
