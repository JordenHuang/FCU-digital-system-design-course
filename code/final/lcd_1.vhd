library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity lcd_1 is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(2 downto 0);
        GPIO_0 : out std_logic_vector(21 downto 9); -- connect to lcd pin8 to pin1
        GPIO_1 : out std_logic_vector(21 downto 9)); -- connect to lcd pin16 to pin9  
end lcd_1;

architecture arch of lcd_1 is
    component clock_gen is
        generic (divisor : integer := 50_000_000);
        port (
            clock_in : in std_logic;
            clock_out : out std_logic);
    end component;

    --signal divider:std_logic_vector(9 downto 0);
    signal init_clk : std_logic;
    signal counter : integer range 0 to 41;
    type ddram is array(0 to 15) of std_logic_vector(7 downto 0);
    signal line1 : ddram;
    signal line2 : ddram;

    signal clk, clk_500hz : std_logic;
    signal lcm_rs, lcm_rw, lcm_en : std_logic;
    signal lcm_db : std_logic_vector(7 downto 0);
    signal show_btn : std_logic;
    signal reset_btn : std_logic;

begin
    clk_u1 : clock_gen generic map(divisor => 100_000) port map(CLOCK_50, clk_500hz);
    show_btn <= KEY(2);
    reset_btn <= KEY(1);

    --clk <= clk_500hz;

    --divider
    --process(clk,reset)
    --begin
    --	if reset='0' then 
    --		divider<="0000000000";
    --	elsif clk'event and clk='1' then
    --		divider<=divider+1;
    --	end if;
    --end process;
    --init_clk<=divider(0);			--2ms

    init_clk <= clk_500hz;
    lcm_en <= init_clk;
    --counter
    process (init_clk, show_btn, reset_btn)
    begin
        if show_btn = '0' or reset_btn = '0' then
            counter <= 0;
        elsif init_clk'event and init_clk = '1' then
            if counter >= 41 then
                counter <= 25;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    --displayt circuit
    process (init_clk, reset_btn, show_btn)
    begin
        if (reset_btn = '0') then
            for i in 15 downto 0 loop
                line1(i) <= "00100000"; --
                line2(i) <= "00100000"; --
            end loop;
        elsif (show_btn = '0') then
            line1(0) <= "01001001"; --I
            line1(1) <= "01000101"; --E
            line1(2) <= "01000011"; --C
            line1(3) <= "01010011"; --S
            line1(4) <= "00100000"; --
            line1(5) <= "01000100"; --D
            line1(6) <= "01101001"; --i
            line1(7) <= "01100111"; --g
            line1(8) <= "01101001"; --i
            line1(9) <= "01110100"; --t
            line1(10) <= "01100001"; --a
            line1(11) <= "01101100"; --l
            line1(12) <= "00101110"; --.
            line1(13) <= "00101110"; --.
            line1(14) <= "00101110"; --.
            line1(15) <= "00101110"; --.
            line2(0) <= "01010011"; --S
            line2(1) <= "01111001"; --y
            line2(2) <= "01110011"; --s
            line2(3) <= "01110100"; --t
            line2(4) <= "01100101"; --e
            line2(5) <= "01101101"; --m
            line2(6) <= "00100000"; --
            line2(7) <= "01000100"; --D
            line2(8) <= "01100101"; --e
            line2(9) <= "01110011"; --s
            line2(10) <= "01101001"; --i
            line2(11) <= "01100111"; --g
            line2(12) <= "01101110"; --n
            line2(13) <= "00101110"; --.
            line2(14) <= "00101110"; --.
            line2(15) <= "00101110"; --.
        elsif (init_clk'event and init_clk = '0') then
            case counter is
                when 0 to 3 =>
                    lcm_rs <= '0';
                    lcm_rw <= '0';
                    lcm_db <= "00111000"; --function set
                when 4 =>
                    lcm_db <= "00001000"; --off screen
                when 5 =>
                    lcm_db <= "00000001"; --clear screen
                when 6 =>
                    lcm_db <= "00001100"; --on screen
                when 7 =>
                    lcm_db <= "00000110"; --entry mode set	
                when 8 =>
                    lcm_rs <= '0';
                    lcm_db <= "10000000"; --set position 	
                when 9 =>
                    lcm_rs <= '1';
                    lcm_db <= line1(0);
                when 10 =>
                    lcm_db <= line1(1);
                when 11 =>
                    lcm_db <= line1(2);
                when 12 =>
                    lcm_db <= line1(3);
                when 13 =>
                    lcm_db <= line1(4);
                when 14 =>
                    lcm_db <= line1(5);
                when 15 =>
                    lcm_db <= line1(6);
                when 16 =>
                    lcm_db <= line1(7);
                when 17 =>
                    lcm_db <= line1(8);
                when 18 =>
                    lcm_db <= line1(9);
                when 19 =>
                    lcm_db <= line1(10);
                when 20 =>
                    lcm_db <= line1(11);
                when 21 =>
                    lcm_db <= line1(12);
                when 22 =>
                    lcm_db <= line1(13);
                when 23 =>
                    lcm_db <= line1(14);
                when 24 =>
                    lcm_db <= line1(15);
                when 25 =>
                    lcm_rs <= '0'; --set position
                    lcm_db <= "11000000";
                when 26 =>
                    lcm_rs <= '1';
                    lcm_db <= line2(0);
                when 27 =>
                    lcm_db <= line2(1);
                when 28 =>
                    lcm_db <= line2(2);
                when 29 =>
                    lcm_db <= line2(3);
                when 30 =>
                    lcm_db <= line2(4);
                when 31 =>
                    lcm_db <= line2(5);
                when 32 =>
                    lcm_db <= line2(6);
                when 33 =>
                    lcm_db <= line2(7);
                when 34 =>
                    lcm_db <= line2(8);
                when 35 =>
                    lcm_db <= line2(9);
                when 36 =>
                    lcm_db <= line2(10);
                when 37 =>
                    lcm_db <= line2(11);
                when 38 =>
                    lcm_db <= line2(12);
                when 39 =>
                    lcm_db <= line2(13);
                when 40 =>
                    lcm_db <= line2(14);
                when 41 =>
                    lcm_db <= line2(15);
            end case;
        end if;
    end process;

    -- lcd pin3 to pin6
    GPIO_0(13) <= '0';
    GPIO_0(14) <= lcm_rs;
    GPIO_0(15) <= lcm_rw;
    GPIO_0(17) <= lcm_en;
    -- lcd pin7 to pin14	(db0 ~ db7)
    GPIO_0(19) <= lcm_db(0);
    GPIO_0(21) <= lcm_db(1);
    GPIO_1(9) <= lcm_db(2);
    GPIO_1(11) <= lcm_db(3);
    GPIO_1(13) <= lcm_db(4);
    GPIO_1(14) <= lcm_db(5);
    GPIO_1(15) <= lcm_db(6);
    GPIO_1(17) <= lcm_db(7);
    -- lcd pin15 to pin16
    GPIO_1(19) <= '1';
    GPIO_1(21) <= '0'; -- turn on backlight

end arch;