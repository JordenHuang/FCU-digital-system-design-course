library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    port (
        KEY : in std_logic_vector(1 to 2);
        HEX0, HEX3 : out std_logic_vector(0 to 6)
    );
end counter;

architecture dual_counter of counter is
    component bcd_to_7sd
        port (
            bcd : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(0 to 6)
        );
    end component;
    signal temp1 : integer range 0 to 10;
    signal clk : std_logic;
    signal reset_btn : std_logic;
    signal count1, count2 : std_logic_vector(3 downto 0);
begin
    clk <= KEY(2);
    reset_btn <= KEY(1);

    -- Counter 1: with signal
    process (clk, reset_btn)
    begin
        if (reset_btn = '1') then
            if (clk'event and clk = '1' and reset_btn = '1') then
                temp1 <= temp1 + 1;
                if (temp1 = 9) then
                    temp1 <= 0;
                end if;
            end if;
        else
            temp1 <= 0;
        end if;
        count1 <= std_logic_vector(to_unsigned(temp1, count1'length));
    end process;

    -- Counter 2: with variable
    process (clk, reset_btn)
        variable temp2 : integer range 0 to 10;
    begin
        if (reset_btn = '1') then
            if (clk'event and clk = '1') then
                temp2 := temp2 + 1;
                if (temp2 = 10) then
                    temp2 := 0;
                end if;
            end if;
        else
            temp2 := 0;
        end if;
        count2 <= std_logic_vector(to_unsigned(temp2, count2'length));
    end process;

    counter1 : bcd_to_7sd port map(bcd => count1, display => HEX0);
    counter2 : bcd_to_7sd port map(bcd => count2, display => HEX3);
end dual_counter;