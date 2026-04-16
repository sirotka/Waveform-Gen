library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_wave_square is
-- Testbench has no ports
end entity tb_wave_square;

architecture behavior of tb_wave_square is

    -- Unit Under Test (UUT) declaration
    component wave_square is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        wave_out : out std_logic_vector(7 downto 0)
    );
    end component;

    -- Signals for connecting to UUT
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal ce       : std_logic := '0';
    signal wave_out : std_logic_vector(7 downto 0);
    
    -- Signal to stop the clock and end simulation cleanly
    signal sim_done : boolean := false; 

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test
    uut: wave_square
    port map (
        clk      => clk,
        rst      => rst,
        ce       => ce,
        wave_out => wave_out
    );

    -- Clock generation process
    clk_process : process
    begin
        -- Clock ticks until the simulation is done
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait; -- Process stops here permanently when sim_done = true
    end process;

    -- Main stimulus process
    stim_proc: process
    begin
        -- Initialization and Reset
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        -- Generating slow 'ce' pulses
        -- 256 pulses = 1 full wave period.
        for i in 0 to 1500 loop
            ce <= '1';
            wait for CLK_PERIOD;     -- ce is active for only one clock cycle
            ce <= '0';
            wait for 4 * CLK_PERIOD; -- wait for the next "slow" tick
        end loop;

        -- End of simulation
        report "Simulation of tb_wave_square successfully completed." severity note;
        sim_done <= true; -- Set the done signal to true to stop the clock
        wait;
    end process;

end architecture behavior;