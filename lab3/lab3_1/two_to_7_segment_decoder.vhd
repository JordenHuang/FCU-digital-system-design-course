library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity two_to_7_segment_decoder is
    port (
    c0, c1 : in STD_LOGIC;
    y_out : out STD_LOGIC_VECTOR(0 to 6)
    -- a, b, c, d, e, f, g : out STD_LOGIC
);
end two_to_7_segment_decoder;

architecture behavior of two_to_7_segment_decoder is
    signal cin : STD_LOGIC_VECTOR(1 downto 0);
begin
	cin <= c1 & c0;
    with cin select
        y_out <= "1000010" when "00",
                 "0110000" when "01",
                 "0000001" when "10",
                 "1111111" when "11";
end behavior;
