library ieee;
use ieee.std_logic_1164.all;

entity two_to_4_7_segment_displays is
    port (
    cin : in std_logic_vector(1 downto 0);
    hex0 : out std_logic_vector(0 to 6);
    hex1 : out std_logic_vector(0 to 6);
    hex2 : out std_logic_vector(0 to 6);
    hex3 : out std_logic_vector(0 to 6)
);
end two_to_4_7_segment_displays;

architecture behavior of two_to_4_7_segment_displays is
begin
    hex3 <= "1000010" when cin = "00" else
            "1111111";
    hex2 <= "0110000" when cin = "01" else
            "1111111";
    hex1 <= "0000001" when cin = "10" else
            "1111111";
    hex0 <= "1111111";
end behavior;
