library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wave_square is
port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    ce       : in  std_logic;
    wave_out : out std_logic_vector(7 downto 0)
);
end entity wave_square;

architecture rtl of wave_square is
    -- 8-bit internal counter for period generation
    signal counter : unsigned(7 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Synchronous reset
                counter  <= (others => '0');
                wave_out <= x"00";
            else
                -- Normal operation, reacts only to clock enable
                if ce = '1' then
                    counter <= counter + 1;
                    
                    -- Output depends on the MSB
                    if counter(7) = '0' then
                        wave_out <= x"00";
                    else
                        wave_out <= x"FF";
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture rtl;