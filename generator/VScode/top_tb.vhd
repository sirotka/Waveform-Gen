-- ============================================================================
-- Title       : Waveform Generator (Basic)
-- File        : top_tb.vhd
-- Author      : Klimt, Krupenko
-- Institution : Brno University of Technology (VUT)
-- Faculty     : Faculty of Electrical Engineering and Communication (FEKT)
-- Course      : Digital Electronics 1 / VHDL Project 2026
--
-- Description :
-- This project implements a basic waveform generator on the Nexys A7-50T FPGA
-- board. The system is capable of generating three types of signals:
-- sine, triangle, and square wave.
--
-- The design uses a hybrid architecture:
-- - clk_en generates a clock enable signal (ce)
-- - counter_step implements DDS phase accumulation
-- - waveform modules generate signals based on phase
-- - waveform_mux selects the active waveform
-- - pwm_out converts the signal to PWM for audio output
-- - seg7 displays waveform type and frequency
--
-- User Control :
-- - Buttons are used to change waveform and frequency
-- - Switch enables/disables output
-- - LEDs indicate system state
--
-- Target Device :
-- Digilent Nexys A7-50T (Xilinx Artix-7 FPGA)
--
-- Notes :
-- This project was developed as part of a laboratory assignment.
-- All modules are designed using synchronous logic principles.
--
-- ============================================================================

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
        led    : out std_logic;       -- led0
        seg    : out std_logic_vector(6 downto 0); -- segmenty CA-CG
        an     : out std_logic_vector(7 downto 0); -- anody
        pwm    : out std_logic;       -- Audio výstup
        aud_sd : out std_logic        -- Zapnutí zesilovače
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

begin

    ----------------------------------------------------------------
    -- LOGIKA RESETU
    ----------------------------------------------------------------
    -- Tlačítko C12 dává v klidu '1'. Pro naše moduly potřebujeme '0'.
    -- Po této inverzi bude sig_rst='1' pouze tehdy, když tlačítko fyzicky držíš.
    sig_rst <= not rst;

    -- Ostatní statické výstupy
    aud_sd <= '1'; -- Zesilovač trvale zapnut
    led    <= sw;  -- LED svítí podle spínače

    ----------------------------------------------------------------
    -- DEBOUNCERY (používají náš sig_rst)
    ----------------------------------------------------------------
    deb_u : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnu, btn_press => sig_btnu_p);
    deb_d : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnd, btn_press => sig_btnd_p);
    deb_l : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnl, btn_press => sig_btnl_p);
    deb_r : entity work.debounce port map (clk => clk, rst => sig_rst, btn_in => btnr, btn_press => sig_btnr_p);

    ----------------------------------------------------------------
    -- FSM (přepínání frekvence a vln)
    ----------------------------------------------------------------
    fsm_inst : entity work.fsm_logic
        port map (
            clk => clk, rst => sig_rst,
            btnu => sig_btnu_p, btnd => sig_btnd_p, btnl => sig_btnl_p, btnr => sig_btnr_p,
            waves => sig_waves, freq_step => sig_freq_step
        );

    ----------------------------------------------------------------
    -- GENEROVÁNÍ FÁZE (DDS)
    ----------------------------------------------------------------
    counter_inst : entity work.counter_step
        port map (
            clk => clk, rst => sig_rst,
            ce => sw, freq_step => sig_freq_step,
            phase => sig_phase
        );

    ----------------------------------------------------------------
    -- TVARY VLN
    ----------------------------------------------------------------
    gen_sine : entity work.wave_sine
        port map (clk => clk, phase => sig_phase, wave_out => sig_sine);

    gen_tri : entity work.wave_triangle
        port map (clk => clk, phase => sig_phase, wave_out => sig_tri);

    gen_sqr : entity work.wave_square
        port map (clk => clk, phase => sig_phase, wave_out => sig_sqr);

    ----------------------------------------------------------------
    -- MULTIPLEXER A VÝSTUPNÍ LOGIKA
    ----------------------------------------------------------------
    -- Výběr vlny podle FSM
    sig_mux_out <= sig_sine when sig_waves = "00" else
                   sig_tri  when sig_waves = "01" else
                   sig_sqr  when sig_waves = "10" else
                   x"80"; -- Střední hodnota

    -- Pokud je sw vypnutý ('0'), pošleme do PWM natvrdo 0.
    sig_final_sample <= sig_mux_out when sw = '1' else x"00";

    ----------------------------------------------------------------
    -- PWM A DISPLEJ
    ----------------------------------------------------------------
    pwm_inst : entity work.pwm_out
        port map (
            clk => clk, rst => sig_rst,
            sample => sig_final_sample, pwm => pwm
        );

    seg_inst : entity work.seg7
        port map (
            clk => clk, rst => sig_rst,
            waves => sig_waves, freq_step => sig_freq_step,
            seg => seg, an => an
        );

end architecture behavioral;