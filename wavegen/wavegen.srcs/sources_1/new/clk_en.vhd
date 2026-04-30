-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : clk_en.vhd
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

-------------------------------------------------

entity clk_en is
    generic ( G_MAX : positive := 5 );  --! Number of clock cycles between pulses
    port (
        clk : in  std_logic;  --! Main clock
        rst : in  std_logic;  --! High-active synchronous reset
        ce  : out std_logic   --! One-clock-cycle enable pulse
    );
end entity clk_en;

-------------------------------------------------

architecture Behavioral of clk_en is

    --! Internal counter
    signal sig_cnt : integer range 0 to G_MAX - 1;

begin

    --! Count clock pulses and generate a one-clock-cycle enable pulse
    p_clk_enable : process (clk) is
    begin
        if rising_edge(clk) then  -- Synchronous process
            if rst = '1' then     -- High-active reset
                ce      <= '0';   -- Reset output
                sig_cnt <= 0;     -- Reset internal counter

            elsif sig_cnt = G_MAX-1 then
                ce      <= '1';   -- Set output pulse
                sig_cnt <= 0;     -- Reset internal counter

            else
                ce      <= '0';   -- Clear output
                sig_cnt <= sig_cnt + 1;  --Increment internal counter

            end if;  -- End if for reset/check
        end if;      -- End if for rising_edge
    end process p_clk_enable;

end Behavioral;