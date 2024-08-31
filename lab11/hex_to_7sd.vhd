library ieee;
use ieee.std_logic_1164.all;

entity hex_to_7sd is
    port( bcd : in std_logic_vector(3 downto 0);
        display : out std_logic_vector(0 to 6)
        );
end hex_to_7sd;

architecture behavior of hex_to_7sd is
begin
    process(bcd)
    begin
        case bcd is
            when "0000" => display <= "0000001";  -- 0
            when "0001" => display <= "1001111";  -- 1
            when "0010" => display <= "0010010";  -- 2
            when "0011" => display <= "0000110";  -- 3
            when "0100" => display <= "1001100";  -- 4
            when "0101" => display <= "0100100";  -- 5
            when "0110" => display <= "0100000";  -- 6
            when "0111" => display <= "0001111";  -- 7
            when "1000" => display <= "0000000";  -- 8
            when "1001" => display <= "0001100";  -- 9
            when "1010" => display <= "0001000";  -- A
            when "1011" => display <= "1100000";  -- B
            when "1100" => display <= "1110010";  -- C
            when "1101" => display <= "1000010";  -- D
            when "1110" => display <= "0110000";  -- E
            when "1111" => display <= "0111000";  -- F
            when others => display <= "1111111";  -- others
        end case;
    end process;
end behavior;