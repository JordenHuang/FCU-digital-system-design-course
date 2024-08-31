library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_1 is
    port (
        CLOCK_50 : in std_logic;
        SW : in std_logic_vector(9 downto 0);
        VGA_HS, VGA_VS : out std_logic;
        VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0));
end vga_1;

architecture arch of vga_1 is
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

    signal clk_25m : std_logic;
    signal show_btn : std_logic;
    signal r : integer range 0 to 525;
    signal c : integer range 0 to 799;
    signal video_on : std_logic;
    signal rout, gout, bout : std_logic_vector(3 downto 0);
    signal set_rgb : std_logic;
begin
    show_btn <= SW(0);

    clock25m : clock_gen
    generic map(divisor => 2)
    port map(
        clock_in => CLOCK_50,
        clock_out => clk_25m
    );

    -- Map pins to VGA_sync component
    sync : VGA_sync port map(
        CLOCK => clk_25m,
        RESET => '1',
        video_on => video_on,
        HOR_SYN => VGA_HS,
        VER_SYN => VGA_VS,
        row_counter => r,
        col_counter => c
    );

    -- Determine show or not
    process (show_btn, video_on)
    begin
        if video_on = '1' then
            if show_btn = '1' then
                set_rgb <= '1';
            else
                set_rgb <= '0';
            end if;
        else
            set_rgb <= '0';
        end if;
    end process;

    -- Determine output color and position
    process (set_rgb)
    begin
        if set_rgb = '1' then
            if (c > 0 and c <= 213) then
                rout <= "1111";
                gout <= "0000";
                bout <= "0000";
            elsif (c > 213 and c <= 426) then
                rout <= "1111";
                gout <= "1111";
                bout <= "1111";
            elsif (c > 426 and c <= 640) then
                rout <= "0000";
                gout <= "0000";
                bout <= "1111";
            else
                null;
            end if;
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