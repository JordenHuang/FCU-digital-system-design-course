library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity lcd_2 is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(2 downto 0);
        GPIO_0 : out std_logic_vector(21 downto 9); -- connect to lcd pin8 to pin1
        GPIO_1 : out std_logic_vector(21 downto 9)); -- connect to lcd pin16 to pin9  
end lcd_2;

architecture arch of lcd_2 is
    component clock_gen is
        generic (divisor : integer := 50_000_000);
        port (
            clock_in : in std_logic;
            clock_out : out std_logic);
    end component;

    --signal divider:std_logic_vector(9 downto 0);
    signal init_clk : std_logic;
    signal counter : integer range 0 to 24;
    type ddram is array(0 to 15) of std_logic_vector(7 downto 0);
    signal line1 : ddram;

    signal clk_500hz, clk_1hz : std_logic;
    signal lcm_rs, lcm_rw, lcm_en : std_logic;
    signal lcm_db : std_logic_vector(7 downto 0);

    signal show_shift_btn : std_logic;
    signal reset_btn : std_logic;
    signal temp : std_logic_vector(7 downto 0);
    signal shift_count : integer range 0 to 7;
    signal go_right : std_logic := '1';
    constant initial_state : ddram := (x"44", x"31", x"31", x"35", x"38", x"38", x"38", x"39", x"20", x"20", x"20", x"20", x"20", x"20", x"20", x"20");

begin
    clk_u1 : clock_gen generic map(divisor => 100_000) port map(CLOCK_50, clk_500hz);
    clk_u2 : clock_gen generic map(divisor => 50_000_000) port map(CLOCK_50, clk_1hz);

    show_shift_btn <= KEY(2);
    reset_btn <= KEY(1);

    init_clk <= clk_500hz;
    lcm_en <= init_clk;
    --counter
    process (init_clk, show_shift_btn)
    begin
        if show_shift_btn = '0' then
            counter <= 0;
        elsif init_clk'event and init_clk = '1' then
            if counter >= 24 then
                counter <= 8;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process (clk_1hz, show_shift_btn, reset_btn)
    begin
        if (reset_btn = '0') then
            -- Reset
            for i in 15 downto 0 loop
                line1(i) <= "00100000"; -- 
            end loop;
        elsif show_shift_btn = '0' then
            -- When pressed show_shift_btn, set initial state
            line1 <= initial_state;
            go_right <= '1';
            shift_count <= 0;
            temp <= "00100000";
        elsif clk_1hz'event and clk_1hz = '0' then
            -- make whatever on the screen go back and forth
            if go_right = '1' then
                -- Go right
                shift_count <= shift_count + 1;
                if shift_count >= 7 then
                    go_right <= '0';
                    shift_count <= 0;
                end if;

                temp <= line1(15);
                for i in 14 downto 0 loop
                    line1(i + 1) <= line1(i);
                end loop;
                line1(0) <= temp;
            else
                -- Go left
                shift_count <= shift_count + 1;
                if shift_count >= 7 then
                    go_right <= '1';
                    shift_count <= 0;
                end if;

                temp <= line1(0);
                for i in 14 downto 0 loop
                    line1(i) <= line1(i + 1);
                end loop;
                line1(15) <= temp;
            end if;
        end if;
    end process;

    --displayt circuit
    -- display on the LCD module
    process (init_clk)
    begin
        if (init_clk'event and init_clk = '0') then
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