library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dice_better is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(2 downto 0);
        GPIO_0 : out std_logic_vector(21 downto 9); -- connect to back-side pin16~pin9 of 8x8 led
        GPIO_1 : out std_logic_vector(21 downto 9) -- connect to front-side pin1~pin8 of 8x8 led
    );
end dice_better;

architecture arch of dice_better is
    component clock_gen is
        generic (divisor : integer := 50000); -- 1k hz
        port (
            clock_in : in std_logic;
            clock_out : out std_logic
        );
    end component;

    signal clock : std_logic;

    type LED8x8_type is array (1 to 8) of std_logic_vector(1 to 8); -- each array stores the pattern of a column
    constant dice_zero : LED8x8_type := (
        1 => "00000000", -- . . . . . . . .
        2 => "00000000", -- . . . . . . . .
        3 => "00000000", -- . . . . . . . .
        4 => "00000000", -- . . . . . . . .
        5 => "00000000", -- . . . . . . . .
        6 => "00000000", -- . . . . . . . .
        7 => "00000000", -- . . . . . . . .
        8 => "00000000" --  . . . . . . . .
    );
    constant dice_one : LED8x8_type := (
        1 => "00000000", -- . . . . . . . .
        2 => "00000000", -- . . . . . . . .
        3 => "00000000", -- . . . . . . . .
        4 => "00011000", -- . . . * * . . .
        5 => "00011000", -- . . . * * . . .
        6 => "00000000", -- . . . . . . . .
        7 => "00000000", -- . . . . . . . .
        8 => "00000000" --  . . . . . . . .
    );
    constant dice_two : LED8x8_type := (
        1 => "00000000", -- . . . . . . . .
        2 => "01100000", -- . * * . . . . .
        3 => "01100000", -- . * * . . . . .
        4 => "00000000", -- . . . . . . . .
        5 => "00000000", -- . . . . . . . .
        6 => "00000110", -- . . . . . * * .
        7 => "00000110", -- . . . . . * * .
        8 => "00000000" --  . . . . . . . .
    );
    constant dice_three : LED8x8_type := (
        1 => "00000000", -- . . . . . . . .
        2 => "01100000", -- . * * . . . . .
        3 => "01100000", -- . * * . . . . .
        4 => "00011000", -- . . . * * . . .
        5 => "00011000", -- . . . * * . . .
        6 => "00000110", -- . . . . . * * .
        7 => "00000110", -- . . . . . * * .
        8 => "00000000" --  . . . . . . . .
    );
    constant dice_four : LED8x8_type := (
        1 => "01100110", -- . * * . . * * .
        2 => "01100110", -- . * * . . * * .
        3 => "00000000", -- . . . . . . . .
        4 => "00000000", -- . . . . . . . .
        5 => "00000000", -- . . . . . . . .
        6 => "00000000", -- . . . . . . . .
        7 => "01100110", -- . * * . . * * .
        8 => "01100110" --  . * * . . * * .
    );
    constant dice_five : LED8x8_type := (
        1 => "01100110", -- . * * . . * * .
        2 => "01100110", -- . * * . . * * .
        3 => "00000000", -- . . . . . . . .
        4 => "00011000", -- . . . * * . . .
        5 => "00011000", -- . . . * * . . .
        6 => "00000000", -- . . . . . . . .
        7 => "01100110", -- . * * . . * * .
        8 => "01100110" --  . * * . . * * .
    );
    constant dice_six : LED8x8_type := (
        1 => "01100110", -- . * * . . * * .
        2 => "01100110", -- . * * . . * * .
        3 => "00000000", -- . . . . . . . .
        4 => "01100110", -- . * * . . * * .
        5 => "01100110", -- . * * . . * * .
        6 => "00000000", -- . . . . . . . .
        7 => "01100110", -- . * * . . * * .
        8 => "01100110" --  . * * . . * * .
    );

    signal reset_btn : std_logic;
    signal show_dice : std_logic;
    signal scanline : integer range 0 to 7;
    signal row, col : std_logic_vector(1 to 8);
    signal led8x8map : LED8x8_type := dice_zero;
    signal num : integer range 0 to 6 := 0;
begin
    one_k_hz_clock : clock_gen port map(clock_in => CLOCK_50, clock_out => clock);

    reset_btn <= KEY(1);
    show_dice <= KEY(2);

    -- Determine the dice number to show
    process (clock, reset_btn)
    begin
        if reset_btn = '0' then
            num <= 0;
        elsif clock'event and clock = '1' then
            num <= num + 1;
            if num = 6 then
                num <= 1;
            end if;
        end if;
    end process;

    -- scan circuit
    process (clock, reset_btn)
    begin
        if reset_btn = '0' then
            scanline <= 0;
        elsif clock'event and clock = '1' then
            if scanline = 7 then
                scanline <= 0;
            else
                scanline <= scanline + 1;
            end if;
        end if;
    end process;

    -- display circuit
    with scanline select
        row <= "01111111" when 0,
        "10111111" when 1,
        "11011111" when 2,
        "11101111" when 3,
        "11110111" when 4,
        "11111011" when 5,
        "11111101" when 6,
        "11111110" when 7,
        "11111111" when others;

    with scanline select
        col <= led8x8map(1) when 0,
        led8x8map(2) when 1,
        led8x8map(3) when 2,
        led8x8map(4) when 3,
        led8x8map(5) when 4,
        led8x8map(6) when 5,
        led8x8map(7) when 6,
        led8x8map(8) when 7,
        "00000000" when others;

    -- Show or not show
    process (reset_btn, show_dice)
    begin
        if reset_btn = '0' then
            led8x8map <= dice_zero;
        else
            if show_dice'event and show_dice = '0' then
                case num is
                    when 0 => led8x8map <= dice_zero;
                    when 1 => led8x8map <= dice_one;
                    when 2 => led8x8map <= dice_two;
                    when 3 => led8x8map <= dice_three;
                    when 4 => led8x8map <= dice_four;
                    when 5 => led8x8map <= dice_five;
                    when 6 => led8x8map <= dice_six;
                    when others => led8x8map <= dice_zero;
                end case;
            end if;
        end if;
    end process;

    -- back-side
    GPIO_0(21) <= col(8);
    GPIO_0(19) <= col(7);
    GPIO_0(17) <= row(2);
    GPIO_0(15) <= col(1);
    GPIO_0(14) <= row(4);
    GPIO_0(13) <= col(6);
    GPIO_0(11) <= col(4);
    GPIO_0(9) <= row(1);
    -- front-side
    GPIO_1(21) <= row(5);
    GPIO_1(19) <= row(7);
    GPIO_1(17) <= col(2);
    GPIO_1(15) <= col(3);
    GPIO_1(14) <= row(8);
    GPIO_1(13) <= col(5);
    GPIO_1(11) <= row(6);
    GPIO_1(9) <= row(3);
end arch;