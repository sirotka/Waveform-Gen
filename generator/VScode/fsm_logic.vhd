-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : fsm_logic.vhd
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

entity fsm_logic is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        -- Clean pulses from debouncers
        btnu       : in  std_logic; -- Frequency UP
        btnd       : in  std_logic; -- Frequency DOWN
        btnl       : in  std_logic; -- Waveform PREV
        btnr       : in  std_logic; -- Waveform NEXT
        -- Control signals for other modules
        waves      : out std_logic_vector(1 downto 0); -- 00=Sin, 01=Tri, 10=Squ
        freq_step  : out std_logic_vector(11 downto 0)
    );
end entity fsm_logic;

architecture Behavioral of fsm_logic is

    -- Waveform states
    type t_wave is (ST_SINE, ST_TRIANGLE, ST_SQUARE);
    signal current_wave : t_wave := ST_SINE;

    -- Frequency states (increments for the phase accumulator)
    type t_freq is (F_1HZ, F_10HZ, F_100HZ, F_1000HZ);
    signal current_freq : t_freq := F_10HZ;

begin

    ----------------------------------------------------------------
    -- Waveform Selection Logic (btnl / btnr)
    ----------------------------------------------------------------
    p_wave_state : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_wave <= ST_SINE;
            else
                -- Next waveform (Right)
                if btnr = '1' then
                    case current_wave is
                        when ST_SINE   => current_wave <= ST_TRIANGLE;
                        when ST_TRIANGLE    => current_wave <= ST_SQUARE;
                        when ST_SQUARE => current_wave <= ST_SINE;
                    end case;
                -- Previous waveform (Left)
                elsif btnl = '1' then
                    case current_wave is
                        when ST_SINE   => current_wave <= ST_SQUARE;
                        when ST_TRIANGLE    => current_wave <= ST_SINE;
                        when ST_SQUARE => current_wave <= ST_TRIANGLE;
                    end case;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Frequency Selection Logic (btnu / btnd)
    ----------------------------------------------------------------
    p_freq_state : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_freq <= F_10HZ; -- Default frequency
            else
                -- Increase frequency (Up)
                if btnu = '1' then
                    case current_freq is
                        when F_1HZ    => current_freq <= F_10HZ;
                        when F_10HZ   => current_freq <= F_100HZ;
                        when F_100HZ  => current_freq <= F_1000HZ;
                        when F_1000HZ => current_freq <= F_1HZ;
                    end case;
                -- Decrease frequency (Down)
                elsif btnd = '1' then
                    case current_freq is
                        when F_1HZ    => current_freq <= F_1000HZ;
                        when F_10HZ   => current_freq <= F_1HZ;
                        when F_100HZ  => current_freq <= F_10HZ;
                        when F_1000HZ => current_freq <= F_100HZ;
                    end case;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Output Mapping
    ----------------------------------------------------------------
    
    -- Waveform selection vector
    waves <= "00" when current_wave = ST_SINE else
             "01" when current_wave = ST_TRIANGLE  else
             "10"; -- ST_SQUARE

    -- Frequency step mapping
    -- (Actual values to be adjusted based on phase accumulator width)
    with current_freq select
        freq_step <= std_logic_vector(to_unsigned(1, 12))    when F_1HZ,
                     std_logic_vector(to_unsigned(10, 12))   when F_10HZ,
                     std_logic_vector(to_unsigned(100, 12))  when F_100HZ,
                     std_logic_vector(to_unsigned(1000, 12)) when F_1000HZ,
                     (others => '0')                         when others;

end architecture Behavioral;