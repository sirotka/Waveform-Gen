-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : seg7_tb.vhd
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

entity seg7_tb is
end entity seg7_tb;

architecture sim of seg7_tb is
    -- Signály
    signal clk_tb       : std_logic := '0';
    signal rst_tb       : std_logic := '0';
    signal waves_tb     : std_logic_vector(1 downto 0) := "00";
    signal freq_step_tb : std_logic_vector(11 downto 0) := x"00A"; -- Default 10
    signal seg_tb       : std_logic_vector(6 downto 0);
    signal an_tb        : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instance modulu
    uut: entity work.seg7
        port map (
            clk       => clk_tb,
            rst       => rst_tb,
            waves     => waves_tb,
            freq_step => freq_step_tb,
            seg       => seg_tb,
            an        => an_tb
        );

    -- Hodiny
    clk_tb <= not clk_tb after CLK_PERIOD / 2;

    -- Stimulus
    stim_proc: process
    begin
        -- 1. Reset
        rst_tb <= '1';
        wait for 100 ns;
        rst_tb <= '0';
        wait for 100 ns;

        ------------------------------------------------------------
        -- TEST 1: Sinus (00) a 1 Hz
        ------------------------------------------------------------
        waves_tb     <= "00";
        freq_step_tb <= std_logic_vector(to_unsigned(1, 12));
        wait for 1 ms; -- Čas na protočení všech aktivních anod

        ------------------------------------------------------------
        -- TEST 2: Triangle (01) a 10 Hz
        ------------------------------------------------------------
        waves_tb     <= "01";
        freq_step_tb <= std_logic_vector(to_unsigned(10, 12));
        wait for 1 ms;

        ------------------------------------------------------------
        -- TEST 3: Square (10) a 100 Hz
        ------------------------------------------------------------
        waves_tb     <= "10";
        freq_step_tb <= std_logic_vector(to_unsigned(100, 12));
        wait for 1 ms;

        ------------------------------------------------------------
        -- TEST 4: Square (10) a 1000 Hz
        ------------------------------------------------------------
        freq_step_tb <= std_logic_vector(to_unsigned(1000, 12));
        wait for 1 ms;

        wait;
    end process;

end architecture sim;