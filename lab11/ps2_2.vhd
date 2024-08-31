library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ps2_2 is
    port (
        CLOCK_50 : in std_logic;
        PS2_KBCLK : in std_logic;
        PS2_KBDAT : in std_logic;
        KEY : in std_logic_vector(2 downto 0);
        LEDG : out std_logic_vector(7 downto 0)
    );
end ps2_2;

architecture arch of ps2_2 is
    --declare PS2 keyboard interface component
    component ps2_keyboard_to_ascii is
        generic (
            clk_freq : integer := 50_000_000; --system clock frequency in Hz
            ps2_debounce_counter_size : integer := 8); --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
        port (
            clk : in std_logic; --system clock input
            ps2_clk : in std_logic; --clock signal from PS2 keyboard
            ps2_data : in std_logic; --data signal from PS2 keyboard
            ascii_new : out std_logic; --output flag indicating new ASCII value
            ascii_code : out std_logic_vector(6 downto 0)); --ASCII value
    end component;
    component hex_to_7sd is
        port (
            bcd : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(0 to 6)
        );
    end component;

    signal reset_btn : std_logic;
    signal number : std_logic_vector(7 downto 0) := "10000000";
    signal has_new : std_logic;
    signal ascii_code : std_logic_vector(6 downto 0);
begin
    ps2_keyboard_code : ps2_keyboard_to_ascii
    port map(
        clk => CLOCK_50,
        ps2_clk => PS2_KBCLK,
        ps2_data => PS2_KBDAT,
        ascii_new => has_new,
        ascii_code => ascii_code
    );

    reset_btn <= KEY(1);

    process (reset_btn, has_new)
    begin
        if reset_btn = '0' then
            number <= "10000000";
        elsif has_new'event and has_new = '1' then
            if ("0" & ascii_code) = x"30" then -- Rotate right
                number <= number(0) & number(7 downto 1);
            elsif ("0" & ascii_code) = x"31" then -- Roatate left
                number <= number(6 downto 0) & number(7);
            end if;
        end if;
    end process;

    LEDG <= number;
end arch;