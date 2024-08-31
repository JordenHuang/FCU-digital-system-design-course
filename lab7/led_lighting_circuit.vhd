-- Lab 7-1 LED lighting circuit

library ieee;
use ieee.std_logic_1164.all;

entity led_lighting_circuit is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(0 to 1);
        LEDG : out std_logic_vector(7 downto 0)
    );
end led_lighting_circuit;

architecture behavior of led_lighting_circuit is
    component clock_gen
        generic (divisor : integer := 4);--50000000
        port (
            clock_in : in std_logic;
            clock_out : out std_logic
        );
    end component;
    signal clock : std_logic;
    signal index : integer range 0 to 7 := 7;
    signal leds : std_logic_vector(7 downto 0);
begin
    one_hz_clock : clock_gen port map(clock_in => CLOCK_50, clock_out => clock);

    LEDG <= leds;
    process (clock, KEY(1))
    begin
        if KEY(1) = '0' then
            index <= 7;
            leds <= "00000000";
        elsif clock'event and clock = '1' then
            index <= index - 1;
            leds(index+1) <= '0';
            leds(index) <= '1';
        end if;
    end process;

    -- process (index, KEY(1))
    -- begin
    --     if KEY(1) = '0' then
    --         leds <= "00000000";
    --     else
    --         -- leds(index + 1) <= '0';
    --         -- leds(index) <= '1';
    --     end if;
    -- end process;
end behavior;