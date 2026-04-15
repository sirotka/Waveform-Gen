library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wave_sine is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        wave_out : out std_logic_vector(7 downto 0)
    );
end entity wave_sine;

architecture behavioral of wave_sine is

    -- 16-point sine LUT (8-bit, offset binary 0–255)
    type t_sine_lut is array (0 to 15) of std_logic_vector(7 downto 0);

    constant C_SINE_LUT : t_sine_lut := (
        x"80", -- 128
        x"B0", -- 176
        x"DA", -- 218
        x"F5", -- 245
        x"FF", -- 255
        x"F5", -- 245
        x"DA", -- 218
        x"B0", -- 176
        x"80", -- 128
        x"50", -- 80
        x"26", -- 38
        x"0B", -- 11
        x"00", -- 0
        x"0B", -- 11
        x"26", -- 38
        x"50"  -- 80
    );

    signal sig_index : integer range 0 to 15 := 0;
    signal sig_wave  : std_logic_vector(7 downto 0);

begin

    -- index counter
    p_index : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sig_index <= 0;
            else
                if ce = '1' then
                    if sig_index = 15 then
                        sig_index <= 0;
                    else
                        sig_index <= sig_index + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- LUT output
    sig_wave <= C_SINE_LUT(sig_index);

    wave_out <= sig_wave;

end architecture behavioral;