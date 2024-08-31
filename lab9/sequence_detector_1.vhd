library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sequence_detector_1 is
    port (
        SW : in std_logic_vector(9 downto 0);
        KEY : in std_logic_vector(2 downto 0);
        LEDG : out std_logic_vector(9 downto 0)
    );
end sequence_detector_1;

architecture arch of sequence_detector_1 is
    type state_type is (a, b, c, d, e);
    signal present_state, next_state : state_type;
    signal x, clk, reset_btn : std_logic;
    signal present_state_led : std_logic_vector(2 downto 0);
begin
    x <= SW(0);
    clk <= KEY(2);
    reset_btn <= KEY(1);

    process (x, present_state)
    begin
        case present_state is
            when a =>
                if x = '0' then
                    next_state <= a;
                else
                    next_state <= b;
                end if;
            when b =>
                if x = '0' then
                    next_state <= c;
                else
                    next_state <= b;
                end if;
            when c =>
                if x = '0' then
                    next_state <= a;
                else
                    next_state <= d;
                end if;
            when d =>
                if x = '0' then
                    next_state <= c;
                else
                    next_state <= e;
                end if;
            when e =>
                if x = '0' then
                    next_state <= c;
                else
                    next_state <= b;
                end if;
        end case;
    end process;

    process (clk, reset_btn)
    begin
        if reset_btn = '0' then
            present_state <= a;
            present_state_led <= "000";
        elsif clk'event and clk = '0' then
            present_state <= next_state;
            present_state_led <= present_state_led(1 downto 0) & x;
        end if;
    end process;

    LEDG(9) <= '1' when present_state = e else '0';
    LEDG(7 downto 5) <= present_state_led;
end arch;