-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : seg7.vhd
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;

entity seg7 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           waves : in STD_LOGIC_VECTOR (1 downto 0);
           freq_step : in STD_LOGIC_VECTOR (11 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0));
end seg7;

architecture Behavioral of seg7 is

-- Refresh counter for multiplexing (approx. 1ms per digit)
    -- 100MHz / 2^17 results in approx 760Hz refresh rate
    signal ref_cnt : unsigned(16 downto 0) := (others => '0');
    signal digit_sel : std_logic_vector(2 downto 0); -- selects one of 8 digits
    
    signal current_data : std_logic_vector(6 downto 0);

begin

    -- 1. Refresh Counter for Multiplexing
    p_refresh : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ref_cnt <= (others => '0');
            else
                ref_cnt <= ref_cnt + 1;
            end if;
        end if;
    end process;

    -- Use the 3 most significant bits to switch between 8 anodes
    digit_sel <= std_logic_vector(ref_cnt(16 downto 14));

    -- 2. Multiplexing Logic (Anodes and Data)
    p_mux : process(digit_sel, waves, freq_step)
    begin
    
        an <= (others => '1');
        current_data <= "1111111";

        case digit_sel is
            --------------------------------------------------------
            -- Waveform Display (AN0, AN1, AN2)
            --------------------------------------------------------
            when "000" => -- AN0 (Rightmost of the first group)
                an(0) <= '0';
                case waves is
                    when "00"   => current_data <= "1101010"; -- 'n'
                    when "01"   => current_data <= "1111011"; -- 'i'
                    when "10"   => current_data <= "1100011"; -- 'u'
                    when others => current_data <= "1111111";
                end case;

            when "001" => -- AN1
                an(1) <= '0';
                case waves is
                    when "00"   => current_data <= "1101111"; -- 'i'
                    when "01"   => current_data <= "1111010"; -- 'r'
                    when "10"   => current_data <= "0001100"; -- 'q'
                    when others => current_data <= "1111111";
                end case;

            when "010" => -- AN2
                an(2) <= '0';
                case waves is
                    when "00"   => current_data <= "0100100"; -- 'S'
                    when "01"   => current_data <= "1111000"; -- 't'
                    when "10"   => current_data <= "0100100"; -- 'S'
                    when others => current_data <= "1111111";
                end case;

            --------------------------------------------------------
            -- AN3: Unused
            --------------------------------------------------------
            when "011" =>
                an(3) <= '1'; -- Stay OFF

            --------------------------------------------------------
            -- Frequency Display (AN4 - AN7)
            --------------------------------------------------------
          when "100" => -- AN4 (ones)
                an(4) <= '0'; 
                if unsigned(freq_step) = 1 then
                    current_data <= "1001111"; -- '1' (for 1 Hz)
                else
                    current_data <= "0000001"; -- '0' (for 10, 100, 1000 Hz)
                end if;

            when "101" => -- AN5 (tens)
                if unsigned(freq_step) = 10 then 
                    an(5) <= '0';
                    current_data <= "1001111"; -- '1' (for 10 Hz)
                elsif unsigned(freq_step) > 10 then
                    an(5) <= '0';
                    current_data <= "0000001"; -- '0' (for 100, 1000 Hz)
                else
                    an(5) <= '1'; -- turned off for 1 Hz
                end if;

            when "110" => -- AN6 (hundreds)
                if unsigned(freq_step) = 100 then
                    an(6) <= '0';
                    current_data <= "1001111"; -- '1' (for 100 Hz)
                elsif unsigned(freq_step) > 100 then
                    an(6) <= '0';
                    current_data <= "0000001"; -- '0' (for 1000 Hz)
                else
                    an(6) <= '1'; -- turned off for 1 a 10 Hz
                end if;

            when "111" => -- AN7 (thousands)
                if unsigned(freq_step) = 1000 then
                    an(7) <= '0';
                    current_data <= "1001111"; -- for '1' (pro 1000 Hz)
                else
                    an(7) <= '1'; -- turned off for everything else
                end if;

            when others =>
                an <= (others => '1');
        end case;
    end process;
            
    seg <= current_data;

end architecture Behavioral;