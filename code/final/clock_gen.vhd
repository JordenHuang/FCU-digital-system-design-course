-- Lab8 component
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clock_gen is
    generic( divisor: integer := 50000000);
    port(
            clock_in : in std_logic;
            clock_out : out std_logic
        );
end clock_gen;

architecture arch of clock_gen is
    signal count_1hz : integer range 0 to divisor/2 := 0;
    signal clk_1hz : std_logic;
begin
    clock_out <= clk_1hz;

    process(clock_in)
    begin
        if clock_in'event and clock_in = '1' then
            if count_1hz < (divisor/2 - 1) then
                count_1hz <= count_1hz + 1;
            else
                count_1hz <= 0;
                clk_1hz <= not clk_1hz;
            end if;
        end if;
    end process;
end arch;
