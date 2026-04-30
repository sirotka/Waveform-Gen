library IEEE;
use IEEE.std_logic_1164.all;

entity debounce is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        btn_in     : in  std_logic;  -- Bouncey input from physical button
        btn_state  : out std_logic;  -- Debounced level
        btn_press  : out std_logic   -- 1-clock pulse for FSM
    );
end entity debounce;

architecture Behavioral of debounce is

    ----------------------------------------------------------------
    -- Constants
    ----------------------------------------------------------------
    constant C_SHIFT_LEN : positive := 4;  -- Number of stable samples required
    -- 100 MHz / 200_000 = 500 Hz (sample every 2 ms)
    constant C_MAX       : positive := 200_000; 

    ----------------------------------------------------------------
    -- Internal signals
    ----------------------------------------------------------------
    signal ce_sample : std_logic;
    signal sync0     : std_logic;
    signal sync1     : std_logic;
    signal shift_reg : std_logic_vector(C_SHIFT_LEN-1 downto 0) := (others => '0');
    signal debounced : std_logic := '0';
    signal delayed   : std_logic := '0';

    ----------------------------------------------------------------
    -- Component declaration
    ----------------------------------------------------------------
    component clk_en is
        generic ( G_MAX : positive );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic
        );
    end component clk_en;
    
begin

    ----------------------------------------------------------------
    -- Clock enable instance (External module)
    ----------------------------------------------------------------
    clock_enable_inst : clk_en
        generic map ( G_MAX => C_MAX )
        port map (
            clk => clk,
            rst => rst,
            ce  => ce_sample
        );

    ----------------------------------------------------------------
    -- Synchronizer + debounce logic
    ----------------------------------------------------------------
    p_debounce : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sync0     <= '0';
                sync1     <= '0';
                shift_reg <= (others => '0');
                debounced <= '0';
                delayed   <= '0';
            else
                -- 1. Input synchronizer (prevents metastability)
                sync0 <= btn_in;
                sync1 <= sync0;

                -- 2. Sample and shift logic
                if ce_sample = '1' then
                    -- Shift history
                    shift_reg <= shift_reg(C_SHIFT_LEN-2 downto 0) & sync1;

                    -- Update debounced state only if all bits in history are the same
                    if shift_reg = (shift_reg'range => '1') then
                        debounced <= '1';
                    elsif shift_reg = (shift_reg'range => '0') then
                        debounced <= '0';
                    end if;
                end if;

                -- 3. Edge detection delay
                delayed <= debounced;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Outputs
    ----------------------------------------------------------------
    btn_state <= debounced;

    -- Generates a 1-clock-cycle pulse when button is confirmed as pressed
    -- Perfect for FSM state transitions
    btn_press <= debounced and not(delayed);

end architecture Behavioral;