library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity accumulator is
    port (
        KEY : in std_logic_vector(1 to 2);
        SW : in signed(7 downto 0); -- (-128) ~ 127
        LEDG : out std_logic_vector(9 downto 0)
    );
end accumulator;

architecture signed_8bit_accumulator of accumulator is
    signal clk : std_logic;
    signal reset_btn : std_logic;
    signal a : signed(7 downto 0);
begin
    clk <= KEY(2);
    reset_btn <= KEY(1);

    process (clk, reset_btn)
        variable q : signed(7 downto 0);
        -- variable result : signed(8 downto 0);
        variable result : signed(7 downto 0);
        variable temp : std_logic_vector(2 downto 0);
    begin
        if (reset_btn = '0') then
            result := "00000000";
            LEDG <= "00" & std_logic_vector(result(7 downto 0));
            a <= "00000000";
        elsif (clk'event and clk = '1') then
            a <= SW;
            -- result := resize(a, result'length) + resize(q, result'length);
            result := a + q;

            temp := a(7) & q(7) & result(7);
            if (temp = "110" or temp = "001") then
                LEDG <= "10" & std_logic_vector(result(7 downto 0));
            else
                LEDG <= "00" & std_logic_vector(result(7 downto 0));
            end if;
        end if;

        q := result(7 downto 0);
    end process;

end signed_8bit_accumulator;