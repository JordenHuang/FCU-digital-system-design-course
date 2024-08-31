library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sequence_detector_2 is
    port (
        SW : in std_logic_vector(9 downto 0);
        KEY : in std_logic_vector(2 downto 0);
        LEDG : out std_logic_vector(9 downto 0)
    );
end sequence_detector_2;

architecture arch of sequence_detector_2 is
    type state_type is (s0, s1, s2, s3, s4, s5, s6, s7, s8);
    signal present_state, next_state : state_type;
    constant led_s0 : std_logic_vector(3 downto 0) := "0000";
    constant led_s1 : std_logic_vector(3 downto 0) := "0001";
    constant led_s2 : std_logic_vector(3 downto 0) := "0010";
    constant led_s3 : std_logic_vector(3 downto 0) := "0011";
    constant led_s4 : std_logic_vector(3 downto 0) := "0100";
    constant led_s5 : std_logic_vector(3 downto 0) := "0101";
    constant led_s6 : std_logic_vector(3 downto 0) := "0110";
    constant led_s7 : std_logic_vector(3 downto 0) := "0111";
    constant led_s8 : std_logic_vector(3 downto 0) := "1111";
    -- signal present_state, next_state : std_logic_vector(3 downto 0);
    signal w, clk, reset_btn : std_logic;
    signal present_state_led : std_logic_vector(3 downto 0);
begin
    w <= SW(0);
    clk <= KEY(2);
    reset_btn <= KEY(1);

    process (w, present_state)
    begin
        case present_state is
            when s0 =>
                if w = '0' then
                    next_state <= s1;
                else
                    next_state <= s5;
                end if;
            when s1 =>
                if w = '0' then
                    next_state <= s2;
                else
                    next_state <= s5;
                end if;
            when s2 =>
                if w = '0' then
                    next_state <= s3;
                else
                    next_state <= s5;
                end if;
            when s3 =>
                if w = '0' then
                    next_state <= s4;
                else
                    next_state <= s5;
                end if;
            when s4 =>
                if w = '0' then
                    next_state <= s4;
                else
                    next_state <= s5;
                end if;

            when s5 =>
                if w = '0' then
                    next_state <= s1;
                else
                    next_state <= s6;
                end if;
            when s6 =>
                if w = '0' then
                    next_state <= s1;
                else
                    next_state <= s7;
                end if;
            when s7 =>
                if w = '0' then
                    next_state <= s1;
                else
                    next_state <= s8;
                end if;
            when s8 =>
                if w = '0' then
                    next_state <= s1;
                else
                    next_state <= s8;
                end if;
        end case;
    end process;

    process (clk, reset_btn)
    begin
        if reset_btn = '0' then
            present_state <= s0;
            present_state_led <= "0000";
        elsif clk'event and clk = '0' then
            present_state <= next_state;
            -- present_state_led <= next_state;
            case next_state is
                when s0 =>
                    present_state_led <= led_s0;
                when s1 =>
                    present_state_led <= led_s1;
                when s2 =>
                    present_state_led <= led_s2;
                when s3 =>
                    present_state_led <= led_s3;
                when s4 =>
                    present_state_led <= led_s4;
                when s5 =>
                    present_state_led <= led_s5;
                when s6 =>
                    present_state_led <= led_s6;
                when s7 =>
                    present_state_led <= led_s7;
                when s8 =>
                    present_state_led <= led_s8;

            end case;
        end if;
    end process;

    LEDG(9) <= '1' when (present_state = s4 or present_state = s8) else
    '0';
    LEDG(7 downto 4) <= present_state_led;
end arch;