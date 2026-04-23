-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : pwm.vhd
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

entity pwm_out is
    port (
        clk    : in  std_logic;                    -- 100 MHz system clock
        rst    : in  std_logic;                    -- Global reset
        sample : in  std_logic_vector(7 downto 0); -- Input from the MUX (0-255)
        pwm    : out std_logic                     -- 1-bit output to AUD_PWM (A11 on Nexys A7)
    );
end entity pwm_out;

architecture behavioral of pwm_out is
    -- 8-bit counter (cycles 0 to 255)
    -- This defines our PWM resolution (2^8 = 256 steps)
    signal sig_cnt : unsigned(7 downto 0) := (others => '0');
begin

    -- PWM Generation Process
    p_pwm : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sig_cnt <= (others => '0');
                pwm     <= '0';
            else
                -- The counter constantly increments at every clock cycle (100MHz)
                sig_cnt <= sig_cnt + 1;

                -- PWM Comparator:
                -- If current counter value is less than the sample, output is HIGH.
                -- This creates the duty cycle proportional to the sample value.
                if sig_cnt < unsigned(sample) then
                    pwm <= '1';
                else
                    pwm <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;