-- TODO: reset all registers
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity proc_2 is
	generic (
		mv : std_logic_vector(2 downto 0) := "000";
		mvi : std_logic_vector(2 downto 0) := "001";
		add : std_logic_vector(2 downto 0) := "010";
		dec_G : std_logic_vector(2 downto 0) := "011";
		mvnz : std_logic_vector(2 downto 0) := "100";
		swap : std_logic_vector(2 downto 0) := "101";
		the_xor : std_logic_vector(2 downto 0) := "110";
		shl : std_logic_vector(2 downto 0) := "111"
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
end proc_2;

architecture Behavior of proc_2 is
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
			-- Rin, Clock : in std_logic;
			Rin, Clock, TEMPin : in std_logic;
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
	signal High, IRin, DINout, Ain, Gin, Gout : std_logic;
	signal AddSub : integer; -- AddSub is like operation selector for alu
	signal I : std_logic_vector(2 downto 0);
	signal Xreg, Yreg : std_logic_vector(0 to 7);
	signal R0, R1, R2, R3, R4, R5, R6, R7, A, G : std_logic_vector(8 downto 0);
	signal IR : std_logic_vector(1 to 9);
	signal Sel : std_logic_vector(1 to 10); -- bus selector
	signal Tstep_Q, Tstep_D : State_type;

	signal TEMP : std_logic_vector(8 downto 0);
	signal TEMPin, TEMPout : std_logic;
	signal CFLAG : integer range -1 to 1 := 0; -- Condition flag, used in cmp operation

	signal icur_state : std_logic_vector(3 downto 0);
begin
	-- read input
	Run <= SW(9);
	DIN <= SW(8 downto 0);
	Clock <= KEY(2);
	Resetn <= KEY(1);
	LEDG(9) <= Done;
	LEDG(8 downto 0) <= BusWires;

	-- Show current state on the HEX3
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
			when T2 => -- some instructions end after this time step
				if (Done = '1') then
					Tstep_D <= T0;
				else
					Tstep_D <= T3;
				end if;
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
	controlsignals : process (Tstep_Q, I, Xreg, Yreg, CFLAG)
	begin
		Done <= '0';
		Ain <= '0';
		Gin <= '0';
		Gout <= '0';
		AddSub <= 0;
		IRin <= '0';
		DINout <= '0';
		Rin <= "00000000";
		Rout <= "00000000";
		TEMPin <= '0';
		TEMPout <= '0';

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
					when dec_G => -- dec_G
						Gout <= '1';
						Ain <= '1';
					when mvnz => -- mvnz
						AddSub <= 6; -- compare G with 0, will set CFLAG
					when swap => -- swap
						Rout <= Yreg;
						TEMPin <= '1';
						-- TODO: slt instruction
						-- when slt
					when the_xor =>
						Rout <= Xreg;
						Ain <= '1';
					when shl =>
						Rout <= Xreg;
						Ain <= '1';
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
						AddSub <= 0;
					when dec_G => -- dec_G
						Gin <= '1';
						AddSub <= 2;
						Done <= '1';
					when mvnz => --mnvz, check the CFLAG
						if not (CFLAG = 0) then -- if CFLAG is not 0, that means G != 0
							Rout <= Yreg;
							Rin <= Xreg;
						end if;
						Done <= '1';
					when swap => -- swap
						Rout <= Xreg;
						Rin <= Yreg;
					when the_xor =>
						Rout <= Yreg;
						Gin <= '1';
						AddSub <= 4;
					when shl =>
						DINout <= '1';
						Gin <= '1';
						AddSub <= 5;
					when others => -- sub
						Rout <= Xreg;
						Ain <= '1';
				end case;
			when T3 => -- define signals in time step T3
				case I is
					when add => -- add
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
					when swap => -- swap
						TEMPout <= '1';
						Rin <= Xreg;
						Done <= '1';
					when the_xor =>
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
					when shl =>
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
					when others => -- sub
						Gout <= '1';
						Rin <= Xreg;
						Done <= '1';
				end case;
		end case;
	end process;

	fsmflipflops : process (Clock, Resetn, Tstep_D)
	begin
		if (Resetn = '0') then
			Tstep_Q <= T0;
		elsif (rising_edge(Clock)) then
			Tstep_Q <= Tstep_D;
		end if;

	end process;

	reg_0 : regn port map(BusWires, Rin(0), Clock, '0', R0);
	reg_1 : regn port map(BusWires, Rin(1), Clock, '0', R1);
	reg_2 : regn port map(BusWires, Rin(2), Clock, '0', R2);
	reg_3 : regn port map(BusWires, Rin(3), Clock, '0', R3);
	reg_4 : regn port map(BusWires, Rin(4), Clock, '0', R4);
	reg_5 : regn port map(BusWires, Rin(5), Clock, '0', R5);
	reg_6 : regn port map(BusWires, Rin(6), Clock, '0', R6);
	reg_7 : regn port map(BusWires, Rin(7), Clock, '0', R7);
	reg_A : regn port map(BusWires, Ain, Clock, '0', A);
	reg_IR : regn generic map(n => 9) port map(DIN(8 downto 0), IRin, Clock, '0', IR);
	reg_TEMP : regn generic map(n => 9) port map(BusWires, '0', Clock, TEMPin, TEMP);

	--	alu
	alu : process (AddSub, A, BusWires, Xreg, Yreg, G)
		constant n : integer := to_integer(unsigned(BusWires(2 downto 0)));
		variable ia : integer range 0 to 7 := 0;
		variable temp_A : std_logic_vector(8 downto 0);
	begin
		-- AddSub is:
		-- add when 0
		-- dec when 2
		-- xor when 4
		-- left-shift when 5
		-- cmp_G_zero when 6
		-- cmp when 7
		if AddSub = 0 then -- add
			Sum <= A + BusWires;
		elsif AddSub = 2 then -- dec
			Sum <= A - "000000001";
		elsif AddSub = 4 then -- xor
			Sum <= A xor BusWires;
		elsif AddSub = 5 then -- left-shift int(BusWires) times
			temp_A := A;
			ia := to_integer(unsigned(BusWires(2 downto 0)));
			-- ia := n;
			if ia > 0 then
				for i in BusWires(2 downto 0)'range loop
					if i < ia then
						temp_A := temp_A(7 downto 0) & '0';
						ia := ia - 1;
					end if;
				end loop;
				-- Sum <= temp_A;
			end if;
			-- while ia > 0 loop
			-- 	temp_A(2 downto 0) := temp_A(1 downto 0) & '0';
			-- 	ia := ia - 1;
			-- end loop;
			Sum <= temp_A;
		elsif AddSub = 7 then -- cmp_G_zero
			if Xreg < Yreg then
				CFLAG <= -1;
			elsif Xreg > Yreg then
				CFLAG <= 1;
			else
				CFLAG <= 0; -- if G is equal to 0, then set CFLAG to 0
			end if;
		elsif AddSub = 6 then -- cmp
			if G(2 downto 0) < "000000000" then
				CFLAG <= - 1;
			elsif G(2 downto 0) > "000000000" then
				CFLAG <= 1;
			else
				CFLAG <= 0; -- if G is equal to 0, then set CFLAG to 0
			end if;
		else
			Sum <= A - BusWires;
		end if;

		-- case ia is
		-- 	when 0 => icur_state <= "0000";
		-- 	when 1 => icur_state <= "0001";
		-- 	when 2 => icur_state <= "0010";
		-- 	when 3 => icur_state <= "0011";
		-- 	when 4 => icur_state <= "0100";
		-- 	when 5 => icur_state <= "0101";
		-- 	when 6 => icur_state <= "0110";
		-- 	when 7 => icur_state <= "0111";
		-- 	when others => icur_state <= "1111";
		-- end case;
	end process;

	-- display2 : hex_to_7sd port map(bcd => icur_state, display => HEX2);

	reg_G : regn port map(Sum, Gin, Clock, '0', G);

	-- define the internal processor bus
	Sel <= Rout & Gout & DINout;

	busmux : process (Sel, R0, R1, R2, R3, R4, R5, R6, R7, G, DIN, TEMPout)
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
			if TEMPout = '1' then
				BusWires <= TEMP;
			else
				BusWires <= DIN;
			end if;
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
		Rin, Clock, TEMPin : in std_logic;
		Q : buffer std_logic_vector(n - 1 downto 0));
end regn;

architecture Behavior of regn is
begin
	process (Clock)
	begin
		if Clock'EVENT and Clock = '1' then
			if Rin = '1' then
				Q <= R;
			elsif TEMPin = '1' then
				Q <= R;
			end if;
		end if;
	end process;
end Behavior;