library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_seg7 is
-- Testbench nemá žádné porty
end tb_seg7;

architecture Behavioral of tb_seg7 is

    -- Komponenta pro testování (UUT)
    component seg7 is
        Port ( clk       : in  STD_LOGIC;
               rst       : in  STD_LOGIC;
               waves     : in  STD_LOGIC_VECTOR (1 downto 0);
               freq_step : in  STD_LOGIC_VECTOR (11 downto 0);
               seg       : out STD_LOGIC_VECTOR (6 downto 0);
               an        : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

    -- Signály pro propojení s UUT
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal waves     : std_logic_vector(1 downto 0) := "00";
    signal freq_step : std_logic_vector(11 downto 0) := (others => '0');
    signal seg       : std_logic_vector(6 downto 0);
    signal an        : std_logic_vector(7 downto 0);

    -- Definice periody hodin (100 MHz = 10 ns)
    constant clk_period : time := 10 ns;

begin

    -- Instanciace jednotky pod testem (UUT)
    uut: seg7 port map (
        clk       => clk,
        rst       => rst,
        waves     => waves,
        freq_step => freq_step,
        seg       => seg,
        an        => an
    );

    -- Generátor hodin
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process (Testovací scénáře)
    stim_proc: process
    begin		
        -- 1. Reset
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -----------------------------------------------------------
        -- TEST 1: SINE WAVE ("00") a FREKVENCE 1 Hz
        -----------------------------------------------------------
        waves     <= "00"; 
        freq_step <= std_logic_vector(to_unsigned(1, 12));
        
        -- Musíme počkat dostatečně dlouho, aby proběhl multiplexing všech 8 cifer
        -- 8 cifer * 164 us = cca 1.3 ms
        wait for 2 ms;

        -----------------------------------------------------------
        -- TEST 2: SQUARE WAVE ("10") a FREKVENCE 1000 Hz
        -----------------------------------------------------------
        waves     <= "10";
        freq_step <= std_logic_vector(to_unsigned(1000, 12));
        
        wait for 2 ms;

        -----------------------------------------------------------
        -- TEST 3: TRIANGLE WAVE ("01") a FREKVENCE 100 Hz
        -----------------------------------------------------------
        waves     <= "01";
        freq_step <= std_logic_vector(to_unsigned(100, 12));
        
        wait for 2 ms;

        -- Konec simulace
        report "Simulation Finished";
        wait;
    end process;

end Behavioral;