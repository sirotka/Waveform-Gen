-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : wave_triangle.vhd
-- Author      : Klimt
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

entity wave_triangle is
    port (
        clk      : in  std_logic;
        phase    : in  std_logic_vector(7 downto 0); -- Vstup z counter_step
        wave_out : out std_logic_vector(7 downto 0)  -- Trojúhelníkový výstup
    );
end entity wave_triangle;

architecture behavioral of wave_triangle is
    signal sig_phase_unsigned : unsigned(7 downto 0);
begin

    sig_phase_unsigned <= unsigned(phase);

    p_triangle_gen : process(clk)
    begin
        if rising_edge(clk) then
            -- MSB fáze určuje, zda jsme v rostoucí nebo klesající části
            if phase(7) = '0' then
                -- První polovina: Rosteme (vynásobíme 2, abychom využili celý rozsah 0-255)
                -- phase 0..127 -> output 0..254
                wave_out <= std_logic_vector(sig_phase_unsigned(6 downto 0) & '0');
            else
                -- Druhá polovina: Klesáme
                -- phase 128..255 -> output 254..0
                wave_out <= std_logic_vector(not (sig_phase_unsigned(6 downto 0) & '0'));
            end if;
        end if;
    end process;

end architecture behavioral;