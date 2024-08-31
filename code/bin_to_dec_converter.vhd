-- Lab 4-1
-- A binary to decimal converter

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity bin_to_dec_converter is
    port(
        SW : in STD_LOGIC_VECTOR(3 downto 0);
        HEX0, HEX1 : out STD_LOGIC_VECTOR(0 to 6)
    );
end bin_to_dec_converter;

architecture behavior of bin_to_dec_converter is
    signal v : STD_LOGIC_VECTOR(3 downto 0);
    signal display_0 : STD_LOGIC_VECTOR(0 to 6);
    signal display_1 : STD_LOGIC_VECTOR(0 to 6);
begin
    v(3 downto 0) <= SW(3 downto 0);

    process(v, display_0, display_1)
    begin
        case v is
            -- 0
            when "0000" => display_0 <= "0000001";  -- 0
                           display_1 <= "0000001";  -- 0
            -- 1
            when "0001" => display_0 <= "1001111";  -- 1
                           display_1 <= "0000001";  -- 0
            -- 2
            when "0010" => display_0 <= "0010010";  -- 2
                           display_1 <= "0000001";  -- 0
            -- 3
            when "0011" => display_0 <= "0000110";  -- 3
                           display_1 <= "0000001";  -- 0
            -- 4
            when "0100" => display_0 <= "1001100";  -- 4
                           display_1 <= "0000001";  -- 0
            -- 5
            when "0101" => display_0 <= "0100100";  -- 5
                           display_1 <= "0000001";  -- 0
            -- 6
            when "0110" => display_0 <= "0100000";  -- 6
                           display_1 <= "0000001";  -- 0
            -- 7
            when "0111" => display_0 <= "0001111";  -- 7
                           display_1 <= "0000001";  -- 0
            -- 8
            when "1000" => display_0 <= "0000000";  -- 8
                           display_1 <= "0000001";  -- 0
            -- 9
            when "1001" => display_0 <= "0001100";  -- 9
                           display_1 <= "0000001";  -- 0
            -- 10
            when "1010" => display_0 <= "0000001";  -- 0
                           display_1 <= "1001111";  -- 1
            -- 11
            when "1011" => display_0 <= "1001111";  -- 1
                           display_1 <= "1001111";  -- 1
            -- 12
            when "1100" => display_0 <= "0010010";  -- 2
                           display_1 <= "1001111";  -- 1
            -- 13
            when "1101" => display_0 <= "0000110";  -- 3
                           display_1 <= "1001111";  -- 1
            -- 14
            when "1110" => display_0 <= "1001100";  -- 4
						   display_1 <= "1001111";  -- 1
            -- 15
            when "1111" => display_0 <= "0100100";  -- 5
                           display_1 <= "1001111";  -- 1
        end case;
    end process;

    HEX0(0 to 6) <= display_0(0 to 6);
    HEX1(0 to 6) <= display_1(0 to 6);
end behavior;
