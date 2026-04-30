----------------------------------------------------------------------------------
-- Company: VUT FEKT Brno
-- Engineer: Klimt
-- 
-- Create Date: 2026
-- Design Name: Waveform Generator Top Module
-- Module Name: top - behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
    port (
        clk    : in  std_logic;       -- 100 MHz clock
        rst    : in  std_logic;       -- Pin C12 (Active Low)
        btnu   : in  std_logic;       -- Freq UP
        btnd   : in  std_logic;       -- Freq DOWN
        btnl   : in  std_logic;       -- Wave PREV
        btnr   : in  std_logic;       -- Wave NEXT
        sw     : in  std_logic;       -- Output ON/OFF
        
        -- Outputs
        led    : out std_logic;       -- LED0 (Visual frequency indicator)
        seg    : out std_logic_vector(6 downto 0); -- segments CA-CG
        an     : out std_logic_vector(7 downto 0); -- anodes
        pwm    : out std_logic;       -- Audio output (AUX Jack)
        aud_sd : out std_logic;       -- Audio amplifier enable
        ja_1   : out std_logic        -- PMOD JA Pin 1 (for Logic Analyzer)
    );
end entity top;

architecture behavioral of top is

    -- Pomocný signál pro otočený reset
    signal sig_rst : std_logic;

    -- Interní signály pro pulzy z tlačítek
    signal sig_btnu_p, sig_btnd_p, sig_btnl_p, sig_btnr_p : std_logic;

    -- Signály z FSM
    signal sig_waves     : std_logic_vector(1 downto 0);
    signal sig_freq_step : std_logic_vector(11 downto 0);

    -- Signály pro fázi a vzorky
    signal sig_phase     : std_logic_vector(7 downto 0);
    signal sig_sine      : std_logic_vector(7 downto 0);
    signal sig_tri       : std_logic_vector(7 downto 0);
    signal sig_sqr       : std_logic_vector(7 downto 0);
    signal sig_mux_out   : std_logic_vector(7 downto 0);
    signal sig_final_sample : std_logic_vector(7 downto 0);
    
    -- Pomocné hodinové signály
    signal sig_ce_dds    : std_logic; -- Puls z clk_en
    signal sig_dds_en    : std_logic; -- Povolení pro counter_step
    signal sig_pwm_out   : std_logic; -- Interní PWM signál

begin

    ----------------------------------------------------------------
    -- LOGIKA RESETU A STATICKÝCH SIGNÁLŮ
    ----------------------------------------------------------------
    sig_rst <= not rst;
    aud_sd  <= '1'; 

    ----------------------------------------------------------------
    -- CLOCK ENABLE PRO DDS (Zamezení aliasingu)
    ----------------------------------------------------------------
    -- G_MAX => 1000 znamená frekvenci vzorkování 100 kHz.
    -- To dává PWM modulu (256 taktů) dostatek času na stabilizaci vzorku.
    clk_en_dds : entity work.clk_en
        generic map (
            G_MAX => 1000
        )
        port map (
            clk => clk,
            rst => sig_rst,
            ce  => sig_ce_dds -- Opraveno z ce_out na ce
        );

    -- Logika pro povolení kroku DDS
    sig_dds_en <= sig_ce_dds and sw;

    ----------------------------------------------------------------
    -- DEBOUNCERY
    ----------------------------------------------------------------
    deb_u : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnu, btn_press => sig_btnu_p);
    deb_d : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnd, btn_press => sig_btnd_p);
    deb_l : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnl, btn_press => sig_btnl_p);
    deb_r : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnr, btn_press => sig_btnr_p);

    ----------------------------------------------------------------
    -- FSM (Volba vlny a frekvence)
    ----------------------------------------------------------------
    fsm_inst : entity work.fsm_logic
        port map (
            clk => clk, rst => sig_rst,
            btnu => sig_btnu_p, btnd => sig_btnd_p, btnl => sig_btnl_p, btnr => sig_btnr_p,
            waves => sig_waves, freq_step => sig_freq_step
        );

    ----------------------------------------------------------------
    -- DDS (Generování fáze)
    ----------------------------------------------------------------
    counter_inst : entity work.counter_step
        port map (
            clk       => clk, 
            rst       => sig_rst,
            ce        => sig_dds_en, 
            freq_step => sig_freq_step,
            phase     => sig_phase
        );

    ----------------------------------------------------------------
    -- TABULKY VZORKŮ
    ----------------------------------------------------------------
    gen_sine : entity work.wave_sine port map (clk => clk, phase => sig_phase, wave_out => sig_sine);
    gen_tri  : entity work.wave_triangle port map (clk => clk, phase => sig_phase, wave_out => sig_tri);
    gen_sqr  : entity work.wave_square port map (clk => clk, phase => sig_phase, wave_out => sig_sqr);

    ----------------------------------------------------------------
    -- MULTIPLEXER
    ----------------------------------------------------------------
    sig_mux_out <= sig_sine when sig_waves = "00" else
                   sig_tri  when sig_waves = "01" else
                   sig_sqr  when sig_waves = "10" else
                   x"80";

    sig_final_sample <= sig_mux_out when sw = '1' else x"00";

    ----------------------------------------------------------------
    -- PWM MODULÁTOR
    ----------------------------------------------------------------
    pwm_inst : entity work.pwm_out
        port map (
            clk    => clk, 
            rst    => sig_rst,
            sample => sig_final_sample, 
            pwm    => sig_pwm_out 
        );

    ----------------------------------------------------------------
    -- VÝSTUPNÍ MOSTEK
    ----------------------------------------------------------------
    pwm  <= sig_pwm_out;
    ja_1 <= sig_pwm_out;
    led  <= sig_pwm_out; 

    ----------------------------------------------------------------
    -- DISPLEJ
    ----------------------------------------------------------------
    seg_inst : entity work.seg7
        port map (
            clk       => clk, 
            rst       => sig_rst,
            waves     => sig_waves, 
            freq_step => sig_freq_step,
            seg       => seg, 
            an        => an
        );

end architecture behavioral;