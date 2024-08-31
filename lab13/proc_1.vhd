library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity proc_1 is
	generic (
		mv : std_logic_vector(2 downto 0) := "000";
		mvi : std_logic_vector(2 downto 0) := "001";
		add : std_logic_vector(2 downto 0) := "010";
		sub : std_logic_vector(2 downto 0) := "011"

	);
	port (
		-- DIN : in std_logic_vector(8 downto 0);
		-- Resetn, Clock, Run : in std_logic;
		-- Done : buffer std_logic;
		-- BusWires : buffer std_logic_vector(8 downto 0));
		KEY : in std_logic_vector(2 downto 0);
		SW : in std_logic_vector(9 downto 0);
		LEDG : out std_logic_vector(9 downto 0);
		HEX3 : out std_logic_vector(0 to 6)
	);
end proc_1;

architecture Behavior of proc_1 is
	component dec3to8
		port (
			W : in std_logic_vector(2 downto 0);
			En : in std_logic;
			Y : out std_logic_vector(0 to 7));
	end component;

	component regn
		generic (n : integer := 9);
		port (
			R : in std_logic_vector(n - 1 downto 0);
			Rin, Clock : in std_logic;
			Q : buffer std_logic_vector(n - 1 downto 0));
	end component;

	component hex_to_7sd is
		port (
			bcd : in std_logic_vector(3 downto 0);
			display : out std_logic_vector(0 to 6)
		);
	end component;

	signal DIN : std_logic_vector(8 downto 0);
	signal Resetn, Clock, Run : std_logic;
	signal Done : std_logic;
	signal BusWires : std_logic_vector(8 downto 0);

	signal cur_state : std_logic_vector(3 downto 0);

	type State_type is (T0, T1, T2, T3);
	signal Rin, Rout : std_logic_vector(0 to 7);
	signal Sum : std_logic_vector(8 downto 0);
	signal High, IRin, DINout, Ain, Gin, Gout, AddSub : std_logic;
	signal I : std_logic_vector(2 downto 0);
	signal Xreg, Yreg : std_logic_vector(0 to 7);
	signal R0, R1, R2, R3, R4, R5, R6, R7, A, G : std_logic_vector(8 downto 0);
	signal IR : std_logic_vector(1 to 9);
	signal Sel : std_logic_vector(1 to 10); -- bus selector
	signal Tstep_Q, Tstep_D : State_type;
begin
	-- read input
	Run <= SW(9);
	DIN <= SW(8 downto 0);
	Clock <= KEY(2);
	Resetn <= KEY(1);
	LEDG(9) <= Done;
	LEDG(8 downto 0) <= BusWires;

	cur_state <= "0000" when Tstep_Q = T0 else
		"0001" when Tstep_Q = T1 else
		"0010" when Tstep_Q = T2 else
		"0011" when Tstep_Q = T3;
	display : hex_to_7sd port map(bcd => cur_state, display => HEX3);

	High <= '1';
	I <= IR(1 to 3);
	decX : dec3to8 port map(W => IR(4 to 6), En => High, Y => Xreg);
	decY : dec3to8 port map(W => IR(7 to 9), En => High, Y => Yreg);

	statetable : process (Tstep_Q, Run, Done)
	begin
		case Tstep_Q is
			when T0 => -- data is loaded into IR in this time step
				if (Run = '0') then
					Tstep_D <= T0;
				else
					Tstep_D <= T1;
				end if;
			when T1 => -- some instructions end after this time step	
				if (Done = '1') then
					Tstep_D <= T0;
				else
					Tstep_D <= T2;
				end if;
			when T2 => -- always go to T3 after this
				Tstep_D <= T3;
			when T3 => -- instructions end after this time step	
				Tstep_D <= T0;
		end case;
	end process;
	-- Instruction Table
	-- 	000: mv		Rx,Ry		: Rx <- [Ry]
	-- 	001: mvi	Rx,#D		: Rx <- D
	-- 	010: add	Rx,Ry		: Rx <- [Rx] + [Ry]
	-- 	011: sub	Rx,Ry		: Rx <- [Rx] - [Ry]
	-- 	OPCODE format: III XXX YYY, where 
	-- 	III = instruction, XXX = Rx, and YYY = Ry. For mvi,
	-- 	a second word of data is loaded from DIN
	--
	controlsignals : process (Tstep_Q, I, Xreg, Yreg)
	begin
		Done <= '0';
		Ain <= '0';
		Gin <= '0';
		Gout <= '0';
		AddSub <= '0';
		IRin <= '0';
		DINout <= '0';
		Rin <= "00000000";
		Rout <= "00000000";
		case Tstep_Q is
			when T0 => -- store DIN in IR as long as Tstep_Q = 0
				IRin <= '1';
			when T1 => -- define signals in time step T1
				case I is
					when mv => -- mv Rx,Ry
						Rout <= Yreg;
						Rin <= Xreg;
						Done <= '1';
					when mvi => -- mvi Rx,#D
						-- data is required to be on DIN
						DINout <= '1';
						Rin <= Xreg;
						Done <= '1';
					when add => -- add
						Rout <= Xreg;
						Ain <= '1';
						-- WHEN "011" => -- sub
					when others => -- sub
						Rout <= Xreg;
						Ain <= '1';
						-- WHEN OTHERS => ; 
				end case;
			when T2 => -- define signals in time step T2
				case I is
					when add => -- add
						Rout <= Yreg;
						Gin <= '1';
						-- WHEN "011" => -- sub
					when others => -- sub
						Rout <= Yreg;
						AddSub <= '1';
						Gin <= '1';
						-- WHEN OTHERS => ; 
				end case;
			when T3 => -- define signals in time step T3
				case I is
					when add => -- add
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
						-- WHEN "011" => -- sub
					when others => -- sub
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
						-- WHEN OTHERS => ;
				end case;
		end case;
	end process;

	fsmflipflops : process (Clock, Resetn, Tstep_D)
	begin
		if (Resetn = '0') then
			-- TODO: reset all registers
			Tstep_Q <= T0;
		elsif (rising_edge(Clock)) then
			Tstep_Q <= Tstep_D;
		end if;

	end process;

	reg_0 : regn port map(BusWires, Rin(0), Clock, R0);
	reg_1 : regn port map(BusWires, Rin(1), Clock, R1);
	reg_2 : regn port map(BusWires, Rin(2), Clock, R2);
	reg_3 : regn port map(BusWires, Rin(3), Clock, R3);
	reg_4 : regn port map(BusWires, Rin(4), Clock, R4);
	reg_5 : regn port map(BusWires, Rin(5), Clock, R5);
	reg_6 : regn port map(BusWires, Rin(6), Clock, R6);
	reg_7 : regn port map(BusWires, Rin(7), Clock, R7);
	reg_A : regn port map(BusWires, Ain, Clock, A);
	reg_IR : regn generic map(n => 9) port map(DIN(8 downto 0), IRin, Clock, IR);

	--	alu
	alu : process (AddSub, A, BusWires)
	begin
		if AddSub = '0' then
			Sum <= A + BusWires;
		else
			Sum <= A - BusWires;
		end if;
	end process;

	reg_G : regn port map(Sum, Gin, Clock, G);

	-- define the internal processor bus
	Sel <= Rout & Gout & DINout;

	busmux : process (Sel, R0, R1, R2, R3, R4, R5, R6, R7, G, DIN)
	begin
		if Sel = "1000000000" then
			BusWires <= R0;
		elsif Sel = "0100000000" then
			BusWires <= R1;
		elsif Sel = "0010000000" then
			BusWires <= R2;
		elsif Sel = "0001000000" then
			BusWires <= R3;
		elsif Sel = "0000100000" then
			BusWires <= R4;
		elsif Sel = "0000010000" then
			BusWires <= R5;
		elsif Sel = "0000001000" then
			BusWires <= R6;
		elsif Sel = "0000000100" then
			BusWires <= R7;
		elsif Sel = "0000000010" then
			BusWires <= G;
		else
			BusWires <= DIN;
		end if;
	end process;
end Behavior;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
library ieee;
use ieee.std_logic_1164.all;

entity dec3to8 is
	port (
		W : in std_logic_vector(2 downto 0);
		En : in std_logic;
		Y : out std_logic_vector(0 to 7));
end dec3to8;

architecture Behavior of dec3to8 is
begin
	process (W, En)
	begin
		if En = '1' then
			case W is
				when "000" => Y <= "10000000";
				when "001" => Y <= "01000000";
				when "010" => Y <= "00100000";
				when "011" => Y <= "00010000";
				when "100" => Y <= "00001000";
				when "101" => Y <= "00000100";
				when "110" => Y <= "00000010";
				when "111" => Y <= "00000001";
			end case;
		else
			Y <= "00000000";
		end if;
	end process;
end Behavior;

library ieee;
use ieee.std_logic_1164.all;

entity regn is
	generic (n : integer := 9);
	port (
		R : in std_logic_vector(n - 1 downto 0);
		Rin, Clock : in std_logic;
		Q : buffer std_logic_vector(n - 1 downto 0));
end regn;

architecture Behavior of regn is
begin
	process (Clock)
	begin
		if Clock'EVENT and Clock = '1' then
			if Rin = '1' then
				Q <= R;
			end if;
		end if;
	end process;
end Behavior;