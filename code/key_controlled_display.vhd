-- Lab 4-2
-- A key-controlled displayed circuit

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity key_controlled_display is
    port(
        SW : in std_logic_vector(0 to 5);
        KEY : in std_logic_vector(0 to 1);
        HEX0, HEX1 : out STD_LOGIC_VECTOR(0 to 6);
        LEDG : out std_logic_vector(3 downto 0)
    );
end key_controlled_display;

architecture behavior of key_controlled_display is
    signal a, b : std_logic_vector(3 downto 0);
    signal a_plus_b : std_logic_vector(3 downto 0);
    signal display_0 : STD_LOGIC_VECTOR(0 to 6);
    signal display_1 : STD_LOGIC_VECTOR(0 to 6);
    signal led_result : std_logic_vector(3 downto 0);
begin
    a <= '0' & SW(2) & SW(1) & SW(0);
    b <= '0' & SW(5) & SW(4) & SW(3);
    a_plus_b <= a + b;
    
    process(a_plus_b)
    begin
        display_0 <= "1111111";  -- nothing displayed
        display_1 <= "1111111";  -- nothing displayed
        led_result <= "0000";    -- LEDs off

        if KEY(0) = '0' and KEY(1) = '1' then
            if a_plus_b = "0000" then     -- 0
                display_0 <= "0000001";     -- 0
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "0001" then  -- 1
                display_0 <= "1001111";     -- 1
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "0010" then  -- 2
                display_0 <= "0010010";     -- 2
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "0011" then  -- 3
                display_0 <= "0000110";     -- 3
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "0100" then  -- 4
                display_0 <= "1001100";     -- 4
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "0101" then  -- 5
                display_0 <= "0100100";     -- 5
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "0110" then  -- 6
                display_0 <= "0100000";     -- 6
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "0111" then  -- 7
                display_0 <= "0001111";     -- 7
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "1000" then  -- 8
                display_0 <= "0000000";     -- 8
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "1001" then  -- 9
                display_0 <= "0001100";     -- 9
                display_1 <= "0000001";     -- 0
            elsif a_plus_b = "1010" then  -- 10
                display_0 <= "0000001";     -- 0
                display_1 <= "1001111";     -- 1
            elsif a_plus_b = "1011" then  -- 11
                display_0 <= "1001111";     -- 1
                display_1 <= "1001111";     -- 1
            elsif a_plus_b = "1100" then  -- 12
                display_0 <= "0010010";     -- 2
                display_1 <= "1001111";     -- 1
            elsif a_plus_b = "1101" then  -- 13
                display_0 <= "0000110";     -- 3
                display_1 <= "1001111";     -- 1
            elsif a_plus_b = "1110" then  -- 14
                display_0 <= "1001100";     -- 4
                display_1 <= "1001111";     -- 1
            elsif a_plus_b = "1111" then  -- 15
                display_0 <= "0100100";     -- 5
                display_1 <= "1001111";     -- 1
            end if;
        elsif KEY(0) = '1' and KEY(1) = '0' then
            led_result <= a_plus_b(3 downto 0);
        end if;
    end process;

    HEX0(0 to 6) <= display_0(0 to 6);
    HEX1(0 to 6) <= display_1(0 to 6);
    LEDG(3 downto 0) <= led_result;
end behavior;
