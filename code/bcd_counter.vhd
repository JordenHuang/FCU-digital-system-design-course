-- Lab 7-2 2-bit bcd counter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_counter is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(0 to 1);
        HEX2, HEX3 : out std_logic_vector(0 to 6)
    );
end bcd_counter;

architecture behavior of bcd_counter is
    component clock_gen
        generic (divisor : integer := 2);  -- 10000000
        port (
            clock_in : in std_logic;
            clock_out : out std_logic
        );
    end component;
    component bcd_to_7sd
        port (
            bcd : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(0 to 6)
        );
    end component;
    signal clock : std_logic;
    signal index : integer range 0 to 99 := 0;
    signal ones, tens : std_logic_vector(3 downto 0);
begin
    one_hz_clock : clock_gen port map(clock_in => CLOCK_50, clock_out => clock);

    process (clock, KEY(1))
    begin
        if KEY(1) = '0' then
            index <= 0;
            ones <= "0000";
            tens <= "0000";
        elsif clock'event and clock = '1' then
            index <= index + 1;
            if index = 99 then
                index <= 0;
            end if;
            ones <= std_logic_vector(to_unsigned(index mod 10, ones'length));
            tens <= std_logic_vector(to_unsigned(index/10, tens'length));

            -- For debugging, if out of range, show 81
            -- if index > 99 then
            --     tens <= "1000";
            --     ones <= "0001";
            -- end if;
        end if;
    end process;

    counter1 : bcd_to_7sd port map(bcd => ones, display => HEX2);
    counter2 : bcd_to_7sd port map(bcd => tens, display => HEX3);
end behavior;