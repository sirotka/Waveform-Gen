library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_step is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        ce         : in  std_logic; -- Clock enable (controlled by switch)
        freq_step  : in  std_logic_vector(11 downto 0); -- Phase increment from FSM
        phase      : out std_logic_vector(7 downto 0)   -- Output phase for wave generators
    );
end entity counter_step;

architecture Behavioral of counter_step is
    -- Internal 16-bit register for the phase accumulator
    -- Using more bits internally allows for finer frequency control
    signal accum : unsigned(15 downto 0) := (others => '0');
begin

    ----------------------------------------------------------------
    -- Phase Accumulator Process
    ----------------------------------------------------------------
    p_accumulator : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset the accumulator to zero
                accum <= (others => '0');
            elsif ce = '1' then
                -- The core of DDS: instead of +1, we add the step value
                -- This controls how fast the counter overflows
                accum <= accum + unsigned(freq_step);
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Output assignment
    ----------------------------------------------------------------
    -- We take the 8 most significant bits (MSB) as the current phase.
    -- This 8-bit value will cycle from 0 to 255.
    phase <= std_logic_vector(accum(15 downto 8));

end architecture Behavioral;