-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : fsm_logic_tb.vhd
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

entity fsm_logic_tb is
end entity fsm_logic_tb;

architecture sim of fsm_logic_tb is
    signal clk_tb       : std_logic := '0';
    signal rst_tb       : std_logic := '0';
    signal btnu_tb      : std_logic := '0';
    signal btnd_tb      : std_logic := '0';
    signal btnl_tb      : std_logic := '0';
    signal btnr_tb      : std_logic := '0';
    signal waves_tb     : std_logic_vector(1 downto 0);
    signal freq_step_tb : std_logic_vector(11 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin

    uut: entity work.fsm_logic
        port map (
            clk => clk_tb, rst => rst_tb,
            btnu => btnu_tb, btnd => btnd_tb,
            btnl => btnl_tb, btnr => btnr_tb,
            waves => waves_tb, freq_step => freq_step_tb
        );

    clk_tb <= not clk_tb after CLK_PERIOD / 2;

    stim_proc: process
    begin
        -- 1. Reset
        rst_tb <= '1';
        wait for CLK_PERIOD * 2;
        rst_tb <= '0';
        wait for CLK_PERIOD * 5;

        ------------------------------------------------------------
        -- TEST FREKVENCE (4x Nahoru, 4x Dolů)
        ------------------------------------------------------------
        -- Cesta nahoru: 10 -> 100 -> 1000 -> 1 -> 10
        for i in 1 to 4 loop
            btnu_tb <= '1'; wait for CLK_PERIOD; btnu_tb <= '0';
            wait for CLK_PERIOD * 3;
        end loop;

        wait for 100 ns; -- Mezera v grafu pro přehlednost

        -- Cesta dolů: 10 -> 1 -> 1000 -> 100 -> 10
        for i in 1 to 4 loop
            btnd_tb <= '1'; wait for CLK_PERIOD; btnd_tb <= '0';
            wait for CLK_PERIOD * 3;
        end loop;

        ------------------------------------------------------------
        -- TEST PRŮBĚHŮ (3x Doprava, 3x Doleva)
        ------------------------------------------------------------
        -- Doprava: Sine(00) -> Tri(01) -> Sqr(10) -> Sine(00)
        for i in 1 to 3 loop
            btnr_tb <= '1'; wait for CLK_PERIOD; btnr_tb <= '0';
            wait for CLK_PERIOD * 3;
        end loop;

        wait for 100 ns;

        -- Doleva: Sine(00) -> Sqr(10) -> Tri(01) -> Sine(00)
        for i in 1 to 3 loop
            btnl_tb <= '1'; wait for CLK_PERIOD; btnl_tb <= '0';
            wait for CLK_PERIOD * 3;
        end loop;

        wait;
    end process;
end architecture sim;