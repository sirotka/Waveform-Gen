library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        waves      : out std_logic_vector(1 downto 0); -- 00=Sin, 01=Saw, 10=Squ
        freq_step  : out std_logic_vector(11 downto 0)
    );
end entity fsm_logic;

architecture Behavioral of fsm_logic is

    -- Waveform states
    type t_wave is (ST_SINE, ST_SAW, ST_SQUARE);
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
                        when ST_SINE   => current_wave <= ST_SAW;
                        when ST_SAW    => current_wave <= ST_SQUARE;
                        when ST_SQUARE => current_wave <= ST_SINE;
                    end case;
                -- Previous waveform (Left)
                elsif btnl = '1' then
                    case current_wave is
                        when ST_SINE   => current_wave <= ST_SQUARE;
                        when ST_SAW    => current_wave <= ST_SINE;
                        when ST_SQUARE => current_wave <= ST_SAW;
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
             "01" when current_wave = ST_SAW  else
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