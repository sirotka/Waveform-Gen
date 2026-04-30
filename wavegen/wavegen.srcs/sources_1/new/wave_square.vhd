-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : wave_square.vhd
-- Author      : Kovář
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

entity wave_square is
    port (
        clk      : in  std_logic;
        phase    : in  std_logic_vector(7 downto 0); -- Input from phase accumulator
        wave_out : out std_logic_vector(7 downto 0)  -- Square wave output
    );
end entity wave_square;

architecture behavioral of wave_square is
begin

    p_square_gen : process(clk)
    begin
        if rising_edge(clk) then
            -- MSB of phase (bit 7) determines the half-cycle
            -- phase(7) = '0' covers 0 to 127
            -- phase(7) = '1' covers 128 to 255
            if phase(7) = '0' then
                wave_out <= x"00"; -- Low level (0)
            else
                wave_out <= x"FF"; -- High level (255)
            end if;
        end if;
    end process;

end architecture behavioral;