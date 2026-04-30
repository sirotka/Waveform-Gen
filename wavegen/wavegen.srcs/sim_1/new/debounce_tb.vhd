library IEEE;
use IEEE.std_logic_1164.all;

entity tb_debounce is
end entity tb_debounce;

architecture sim of tb_debounce is

    component debounce is
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            btn_in    : in  std_logic;
            btn_state : out std_logic;
            btn_press : out std_logic
        );
    end component;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal btn_in    : std_logic := '0';
    signal btn_state : std_logic;
    signal btn_press : std_logic;

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

begin

    uut : debounce
        port map (
            clk       => clk,
            rst       => rst,
            btn_in    => btn_in,
            btn_state => btn_state,
            btn_press => btn_press
        );

    -- Clock generation
    p_clk : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    p_stim : process
    begin
        -- Reset
        rst <= '1';
        btn_in <= '0';
        wait for 100 ns;
        rst <= '0';

        -- Wait a little
        wait for 1 ms;

        -- Simulate button press with bounce
        btn_in <= '1';
        wait for 100 us;
        btn_in <= '0';
        wait for 80 us;
        btn_in <= '1';
        wait for 60 us;
        btn_in <= '0';
        wait for 40 us;
        btn_in <= '1';

        -- Hold button pressed long enough for debounce to confirm it
        wait for 12 ms;

        -- Simulate button release with bounce
        btn_in <= '0';
        wait for 100 us;
        btn_in <= '1';
        wait for 80 us;
        btn_in <= '0';
        wait for 60 us;
        btn_in <= '1';
        wait for 40 us;
        btn_in <= '0';

        -- Hold released long enough
        wait for 12 ms;

        wait;
    end process;

end architecture sim;