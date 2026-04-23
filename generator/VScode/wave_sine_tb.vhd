-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : wave_sine_tb.vhd
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

entity wave_sine_tb is
-- Testbench nemá žádné porty
end entity wave_sine_tb;

architecture sim of wave_sine_tb is

    -- 1. Deklarace signálů pro propojení s testovaným modulem (UUT)
    signal clk_tb      : std_logic := '0';
    signal phase_tb    : std_logic_vector(7 downto 0) := (others => '0');
    signal wave_out_tb : std_logic_vector(7 downto 0);

    -- Definice periody hodin (100 MHz = 10 ns)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 2. Instance testovaného modulu (Unit Under Test)
    uut : entity work.wave_sine
        port map (
            clk      => clk_tb,
            phase    => phase_tb,
            wave_out => wave_out_tb
        );

    -- 3. Generátor hodin
    p_clk_gen : process
    begin
        while now < 10 ms loop -- Simulace poběží 10ms (dost na několik period)
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- 4. Stimulus proces (mění fázi)
    p_stimulus : process
    begin
        -- Počkáme na stabilizaci
        wait for CLK_PERIOD * 10;

        -- Projdeme celou tabulku (0 až 255) několikrát dokola
        for j in 0 to 5 loop
            for i in 0 to 255 loop
                phase_tb <= std_logic_vector(to_unsigned(i, 8));
                wait for CLK_PERIOD; -- Změna fáze s každým taktem
            end loop;
        end loop;

        -- Konec simulace
        report "Simulation OK";
        wait;
    end process;

end architecture sim;