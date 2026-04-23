-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : wave_square_tb.vhd
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

entity wave_square_tb is
end entity wave_square_tb;

architecture sim of wave_square_tb is
    signal clk_tb      : std_logic := '0';
    signal phase_tb    : std_logic_vector(7 downto 0) := (others => '0');
    signal wave_out_tb : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instance Unit Under Test
    uut : entity work.wave_square
        port map (
            clk      => clk_tb,
            phase    => phase_tb,
            wave_out => wave_out_tb
        );

    -- Clock generator
    p_clk_gen : process
    begin
        while now < 5 ms loop
            clk_tb <= '0'; wait for CLK_PERIOD / 2;
            clk_tb <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus
   p_stimulus : process
    begin
        -- 1. Počáteční čekání
        wait for CLK_PERIOD * 10;

        -- 2. Cyklus pro postupné měnění fáze
        -- POZOR: Musí tu být ten 'wait', jinak se čas v simulaci nepohne!
        for j in 0 to 100 loop  -- Uděláme 100 period, ať je co vidět
            for i in 0 to 255 loop
                phase_tb <= std_logic_vector(to_unsigned(i, 8));
                wait for CLK_PERIOD; -- KLÍČOVÝ ŘÁDEK: Simulátor čeká na další takt hodin
            end loop;
        end loop;

        -- Zastavení simulace
        wait;
    end process;
end architecture sim;