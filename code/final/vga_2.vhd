library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_2 is
    port (
        CLOCK_50 : in std_logic;
        PS2_KBCLK : in std_logic;
        PS2_KBDAT : in std_logic;
        VGA_HS, VGA_VS : out std_logic;
        VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0));
end vga_2;

architecture arch of vga_2 is
    component VGA_sync is
        port (
            CLOCK, RESET : in std_logic;
            HOR_SYN, VER_SYN, video_on : out std_logic;
            row_counter : out integer range 0 to 525;
            col_counter : out integer range 0 to 799);
    end component;
    component clock_gen is
        generic (divisor : integer := 50000000);
        port (
            clock_in : in std_logic;
            clock_out : out std_logic
        );
    end component;
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

    signal clk_25m : std_logic;
    signal clk_10 : std_logic;
    signal reset_btn : std_logic := '1';
    signal r : integer range 0 to 525;
    signal c : integer range 0 to 799;
    signal square_r : integer range 0 to 525 := 0;
    signal square_c : integer range 0 to 799 := 0;
    signal video_on : std_logic;
    signal rout, gout, bout : std_logic_vector(3 downto 0);
    signal set_rgb : std_logic;

    signal has_new : std_logic;
    signal ascii_code : std_logic_vector(6 downto 0);
    signal ascii_code_to_output : std_logic_vector(7 downto 0);
    constant UP : std_logic_vector(7 downto 0) := x"41";
    constant DOWN : std_logic_vector(7 downto 0) := x"42";
    constant LEFT : std_logic_vector(7 downto 0) := x"44";
    constant RIGHT : std_logic_vector(7 downto 0) := x"43";
begin

    ps2_keyboard_code : ps2_keyboard_to_ascii
    port map(
        clk => CLOCK_50,
        ps2_clk => PS2_KBCLK,
        ps2_data => PS2_KBDAT,
        ascii_new => has_new,
        ascii_code => ascii_code
    );

    ascii_code_to_output <= '0' & ascii_code;

    clock25m : clock_gen
    generic map(divisor => 2)
    port map(
        clock_in => CLOCK_50,
        clock_out => clk_25m
    );

    clock10 : clock_gen
    generic map(divisor => 2500000)
    port map(
        clock_in => CLOCK_50,
        clock_out => clk_10
    );

    -- Map pins to VGA_sync component
    sync : VGA_sync port map(
        CLOCK => clk_25m,
        RESET => reset_btn,
        video_on => video_on,
        HOR_SYN => VGA_HS,
        VER_SYN => VGA_VS,
        row_counter => r,
        col_counter => c
    );

    -- Determine show or not
    process (video_on)
    begin
        if video_on = '1' then
            set_rgb <= '1';
        else
            set_rgb <= '0';
        end if;
    end process;

    -- Determine position
    process (has_new, ascii_code_to_output)
    begin
        if has_new'event and has_new = '1' then
            if (ascii_code_to_output = UP) then
                if (square_r >= 20) then
                    square_r <= square_r - 20;
                end if;
            elsif (ascii_code_to_output = DOWN) then
                if (square_r < 460) then
                    square_r <= square_r + 20;
                end if;
            elsif (ascii_code_to_output = LEFT) then
                if (square_c >= 20) then
                    square_c <= square_c - 20;
                end if;
            elsif (ascii_code_to_output = RIGHT) then
                if (square_c < 620) then
                    square_c <= square_c + 20;
                end if;
            -- else
            --     square_r <= 0;
            --     square_c <= 0;
            end if;
        end if;
    end process;

    -- Determine output color
    process (set_rgb)
    begin
        if set_rgb = '1' then
            if (r >= square_r and r <= (square_r + 20)) then
                if (c >= square_c and c <= (square_c + 20)) then
                    rout <= "1111";
                    gout <= "1111";
                    bout <= "1111";
                else
                    rout <= "0000";
                    gout <= "0000";
                    bout <= "0000";
                end if;
            else
                rout <= "0000";
                gout <= "0000";
                bout <= "0000";
            end if;
            -- rout <= "1111";
            -- gout <= "1111";
            -- bout <= "1111";
        else
            rout <= "0000";
            gout <= "0000";
            bout <= "0000";
        end if;
    end process;

    VGA_R <= rout;
    VGA_G <= gout;
    VGA_B <= bout;
end arch;