library ieee;
use ieee.std_logic_1164.all;

entity tb_wave_sine is
end tb_wave_sine;

architecture tb of tb_wave_sine is

    component wave_sine
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            ce       : in  std_logic;
            wave_out : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal ce       : std_logic := '0';
    signal wave_out : std_logic_vector(7 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbClock    : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : wave_sine
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            wave_out => wave_out
        );

    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stimuli : process
    begin
        ce  <= '0';
        rst <= '1';
        wait for 20 ns;

        rst <= '0';
        wait for 20 ns;

        for i in 0 to 31 loop
            ce <= '1';
            wait for TbPeriod;
            ce <= '0';
            wait for 2 * TbPeriod;
        end loop;

        wait for 20 ns;
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_wave_sine of tb_wave_sine is
    for tb
    end for;
end cfg_tb_wave_sine;