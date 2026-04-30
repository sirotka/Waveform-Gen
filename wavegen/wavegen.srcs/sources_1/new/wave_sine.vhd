-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : wave_sine.vhd
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

entity wave_sine is
    port (
        clk      : in  std_logic;
        phase    : in  std_logic_vector(7 downto 0);
        wave_out : out std_logic_vector(7 downto 0)
    );
end entity wave_sine;

architecture behavioral of wave_sine is

    -- 16-point sine LUT
    type t_sine_lut is array (0 to 15) of std_logic_vector(7 downto 0);
    constant C_SINE_LUT : t_sine_lut := (
        x"80", x"B0", x"DA", x"F5", x"FF", x"F5", x"DA", x"B0",
        x"80", x"50", x"26", x"0B", x"00", x"0B", x"26", x"50"
    );

begin
    
    p_lut_read : process(clk)
    begin
        if rising_edge(clk) then
            -- 8bit phase / 16 = upper 4 bits
            wave_out <= C_SINE_LUT(to_integer(unsigned(phase(7 downto 4))));
        end if;
    end process;

end architecture behavioral;