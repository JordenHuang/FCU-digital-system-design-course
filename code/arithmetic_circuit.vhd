-- Lab 5
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity arithmetic_circuit is
    port (
        SW : in std_logic_vector(7 downto 0);
        KEY : in std_logic_vector(0 to 2);
        HEX0, HEX1 : out std_logic_vector(0 to 6);
        LEDG : out std_logic_vector(9 downto 0)
    );
end arithmetic_circuit;

architecture behavior of arithmetic_circuit is
    component bcd_to_7sd
        port (
            bcd : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(0 to 6)
        );
    end component;
    signal a, b, result, final_result : std_logic_vector(7 downto 0);
    signal bcd_t : std_logic_vector(3 downto 0);
    signal bcd_o : std_logic_vector(7 downto 0);
    signal press : std_logic;
begin
    process (SW, KEY, result, press, a, b, final_result)
    begin
        press <= '0';
        bcd_t <= "1111";
        bcd_o <= "11111111";
        LEDG <= "0000000000";
        final_result <= "00000000";

        -- Extend 4-bit input into 8-bit
        if (SW(7) = '1') then
            a <= "1111" & SW(7 downto 4);
        else
            a <= "0000" & SW(7 downto 4);
        end if;
        if (SW(3) = '1') then
            b <= "1111" & SW(3 downto 0);
        else
            b <= "0000" & SW(3 downto 0);
        end if;

        -- Check condition to do corresponding arithmetic operation
        if (KEY = "011") then -- do addition
            result <= a + b;
            press <= '1';
        elsif (KEY = "101") then -- do subtraction
            result <= a - b;
            press <= '1';
        elsif (KEY = "110") then -- do multiply
            result <= SW(7 downto 4) * SW(3 downto 0);
            press <= '1';
        else
            result <= "00000000";
        end if;

        if (result(7) = '1') then -- if result is negative
            LEDG(9) <= '1';
            final_result <= (not result) + "00000001";
        else
            final_result <= result;
        end if;

        if (press = '1') then -- if the button has pressed
            if (final_result < "00001010") then -- if result less than 10
                bcd_t <= "0000";
                bcd_o <= final_result;
            elsif (final_result < "00010100") then -- if result less than 20
                bcd_t <= "0001";
                bcd_o <= final_result - "00001010";
            elsif (final_result < "00011110") then -- if result less than 30
                bcd_t <= "0010";
                bcd_o <= final_result - "00010100";
            elsif (final_result < "00101000") then -- if result less than 40
                bcd_t <= "0011";
                bcd_o <= final_result - "00011110";
            elsif (final_result < "00110010") then -- if result less than 50
                bcd_t <= "0100";
                bcd_o <= final_result - "00101000";
            elsif (final_result < "00111100") then -- if result less than 60
                bcd_t <= "0101";
                bcd_o <= final_result - "00110010";
            elsif (final_result < "01000110") then -- if result less than 70
                bcd_t <= "0110";
                bcd_o <= final_result - "00111100";
            end if;
        end if;

        -- LEDG(7 downto 0) <= final_result;  -- For debugging
    end process;

    digit0 : bcd_to_7sd port map(bcd => bcd_o(3 downto 0), display => HEX0);
    digit1 : bcd_to_7sd port map(bcd => bcd_t, display => HEX1);

end behavior;