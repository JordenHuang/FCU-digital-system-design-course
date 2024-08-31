library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity greenman is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(2 downto 0);
        GPIO_0 : out std_logic_vector(21 downto 9); -- connect to back-side pin16~pin9 of 8x8 led
        GPIO_1 : out std_logic_vector(21 downto 9) -- connect to front-side pin1~pin8 of 8x8 led
    );
end greenman;

architecture arch of greenman is
    component clock_gen is
        generic (divisor : integer := 25000000); -- 2hz
        port (
            clock_in : in std_logic;
            clock_out : out std_logic
        );
    end component;

    signal clock : std_logic;
    signal one_k_clock : std_logic;

    type LED8x8_type is array (1 to 8) of std_logic_vector(1 to 8); -- each array stores the pattern of a column
    constant man1 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011000", -- . . . * * . . .
        4 => "00011000", -- . . . * * . . .
        5 => "00011000", -- . . . * * . . .
        6 => "00001000", -- . . . . * . . .
        7 => "00010100", -- . . . * . * . .
        8 => "00010100" --  . . . * . * . .
    );
    constant man2 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011000", -- . . . * * . . .
        4 => "00011100", -- . . . * * * . .
        5 => "00111000", -- . . * * * . . .
        6 => "00010100", -- . . . * . * . .
        7 => "00010100", -- . . . * . * . .
        8 => "00100100" --  . . * . . * . .
    );
    constant man3 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011100", -- . . . * * * . .
        4 => "00111010", -- . . * * * . * .
        5 => "00001000", -- . . . . * . . .
        6 => "00010100", -- . . . * . * . .
        7 => "00100100", -- . . * . . * . .
        8 => "00100010" --  . . * . . . * .
    );
    constant man4 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011100", -- . . . * * * . .
        4 => "00111010", -- . . * * * . * .
        5 => "01001001", -- . * . . * . . *
        6 => "00010100", -- . . . * . * . .
        7 => "00100010", -- . . * . . . * .
        8 => "00100010" --  . . * . . . * .
    );
    constant man5 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011110", -- . . . * * * * .
        4 => "00111001", -- . . * * * . . *
        5 => "01001000", -- . * . . * . . .
        6 => "00010100", -- . . . * . * . .
        7 => "00100010", -- . . * . . . * .
        8 => "01000010" --  . * . . . . * .
    );
    constant man6 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011100", -- . . . * * * . .
        4 => "00111010", -- . . * * * . * .
        5 => "01001001", -- . * . . * . . *
        6 => "00010100", -- . . . * . * . .
        7 => "00100010", -- . . * . . . * .
        8 => "00100010" --  . . * . . . * .
    );
    constant man7 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011100", -- . . . * * * . .
        4 => "00111010", -- . . * * * . * .
        5 => "00001000", -- . . . . * . . .
        6 => "00010100", -- . . . * . * . .
        7 => "00100100", -- . . * . . * . .
        8 => "00100010" --  . . * . . . * .
    );
    constant man8 : LED8x8_type := (
        1 => "00111000", -- . . * * * . . .
        2 => "00110000", -- . . * * . . . .
        3 => "00011000", -- . . . * * . . .
        4 => "00011100", -- . . . * * * . .
        5 => "00111000", -- . . * * * . . .
        6 => "00010100", -- . . . * . * . .
        7 => "00010100", -- . . . * . * . .
        8 => "00100100" --  . . * . . * . .
    );

    signal pause_btn : std_logic;
    signal is_pause : std_logic;
    signal scanline : integer range 0 to 7;
    signal row, col : std_logic_vector(1 to 8);
    signal led8x8map : LED8x8_type;
    signal num : integer range 1 to 8 := 1;
begin
    two_hz_clock : clock_gen port map(clock_in => CLOCK_50, clock_out => clock);
    one_k_hz_clock : clock_gen generic map(divisor => 50000) port map(clock_in => CLOCK_50, clock_out => one_k_clock);

    pause_btn <= KEY(2);

    -- Determine which slide of the greenman to show
    process (clock)
    begin
        if clock'event and clock = '1' then
            num <= num + 1;
            if num = 7 then
                num <= 1;
            end if;
        end if;
    end process;

    -- scan circuit
    process (one_k_clock)
    begin
        if one_k_clock'event and one_k_clock = '1' then
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

    -- To pause or not
    process (pause_btn)
    begin
        if pause_btn = '0'then
            if is_pause = '1' then
                is_pause <= '0';
                -- led8x8map <= led8x8map;
            else
                is_pause <= '1';
            end if;
        end if;
    end process;

    -- Show next or not
    process (clock, is_pause)
    begin
        if is_pause = '1' then
            led8x8map <= led8x8map;
        elsif clock'event and clock = '1' then
            case num is
                when 1 => led8x8map <= man1;
                when 2 => led8x8map <= man2;
                when 3 => led8x8map <= man3;
                when 4 => led8x8map <= man4;
                when 5 => led8x8map <= man5;
                when 6 => led8x8map <= man6;
                when 7 => led8x8map <= man7;
                when 8 => led8x8map <= man8;
            end case;
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