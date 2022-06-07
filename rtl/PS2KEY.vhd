--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity PS2KEY is
	port (
		KEYMATY		: in  std_logic_vector(9 downto 0);
		PS2KBDAT	: in  std_logic;
		PS2KBCLK	: in  std_logic;
		CTRLKEYDAT	: in  std_logic_vector(7 downto 0);
		CTRLKEYENB	: in  std_logic;
		KEYSCANENB	: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		KEYMATX		: out std_logic_vector(7 downto 0);
		FUNCKEY		: out std_logic_vector(23 downto 0)
	);
end PS2KEY;

architecture RTL of PS2KEY is

	signal kbdat_f1		: std_logic;
	signal kbdat_f2		: std_logic;
	signal kbclk_f1		: std_logic;
	signal kbclk_f2		: std_logic;
	signal kbclk_f3		: std_logic;

	signal rstcnt		: std_logic_vector(11 downto 0);
	signal indt			: std_logic_vector(10 downto 0);
	signal keydt		: std_logic_vector(7 downto 0);
	signal sftcnt		: std_logic_vector(3 downto 0);
	signal endflag		: std_logic;
	signal e1flag		: std_logic;
	signal expflag		: std_logic;
	signal offflag		: std_logic;

	signal ctrlenb_f1	: std_logic;
	signal ctrlenb_f2	: std_logic;
	signal ctrlenb_f3	: std_logic;
	signal ctrlenb_r	: std_logic;
	signal ctrlenb_r_f1	: std_logic;
	signal ctrlenb_f	: std_logic;
	signal ctrlenb_f_f1	: std_logic;
	signal ctrl_push	: std_logic;
	signal ctrl_release	: std_logic;
	signal ctrldata_f1	: std_logic_vector(7 downto 0);

	type keymat_type is array (9 downto 0) of std_logic_vector(7 downto 0);
	signal onkey		: keymat_type;

	signal keymatx_i	: std_logic_vector(7 downto 0);
	signal funckey_i	: std_logic_vector(23 downto 0);

begin

-- input latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			kbdat_f1 <= '1';
			kbdat_f2 <= '1';
			kbclk_f1 <= '1';
			kbclk_f2 <= '1';
			kbclk_f3 <= '1';
		elsif (CLK'event and CLK = '1') then
			kbdat_f1 <= PS2KBDAT;
			kbdat_f2 <= kbdat_f1;
			kbclk_f1 <= PS2KBCLK;
			kbclk_f2 <= kbclk_f1;
			kbclk_f3 <= kbclk_f2;
		end if;
	end process;

-- reset counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rstcnt <= X"000";
		elsif (CLK'event and CLK = '1') then
			if (kbclk_f2 = '0') then
				rstcnt <= X"000";
			else
				rstcnt <= rstcnt + 1;
			end if;
		end if;
	end process;


-- input data latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			indt   <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			if (kbclk_f2 = '0' and kbclk_f3 = '1') then
				indt(10) <= kbdat_f2;
				indt(9 downto 0) <= indt(10 downto 1);
			end if;
		end if;
	end process;

	keydt <= indt(8 downto 1);

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sftcnt  <= "0000";
			endflag <= '1';
		elsif (CLK'event and CLK = '1') then
			if (kbclk_f2 = '0' and kbclk_f3 = '1') then
				if (sftcnt = "1010") then
					sftcnt  <= "0000";
					endflag <= '1';
				else
					sftcnt  <= sftcnt + 1;
					endflag <= '0';
				end if;
			elsif (rstcnt = X"FFF") then
				sftcnt  <= "0000";
				endflag <= '0';
			else
				endflag <= '0';
			end if;

		end if;
	end process;

-- expansion key and release key detect
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			e1flag  <= '0';
			expflag <= '0';
			offflag <= '0';
		elsif (CLK'event and CLK = '1') then
			if (endflag = '1') then
				if    (keydt = X"E1") then
					if (e1flag = '1') then
						e1flag  <= '0';
						expflag <= '0';
						offflag <= '0';
					else
						e1flag  <= '1';
						expflag <= '0';
						offflag <= '0';
					end if;
				elsif (keydt = X"E0") then
					expflag <= '1';
					offflag <= '0';
				elsif (keydt = X"F0") then
					offflag <= '1';
				else
					expflag <= '0';
					offflag <= '0';
				end if;
			end if;
		end if;
	end process;


-- input data latch from ctrl register
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			ctrlenb_f1 <= '0';
			ctrlenb_f2 <= '0';
			ctrlenb_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			ctrlenb_f1 <= CTRLKEYENB;
			ctrlenb_f2 <= ctrlenb_f1;
			ctrlenb_f3 <= ctrlenb_f2;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			ctrlenb_r <= '0';
			ctrlenb_f <= '0';
		elsif (CLK'event and CLK = '1') then
			if (ctrlenb_f2 = '1' and ctrlenb_f3 = '0') then
				ctrlenb_r <= '1';
			elsif (KEYSCANENB = '0') then
				ctrlenb_r <= '0';
			end if;

			if (ctrlenb_f2 = '0' and ctrlenb_f3 = '1') then
				ctrlenb_f <= '1';
			elsif (KEYSCANENB = '0') then
				ctrlenb_f <= '0';
			end if;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			ctrlenb_r_f1 <= '0';
			ctrlenb_f_f1 <= '0';
			ctrldata_f1  <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			ctrlenb_r_f1 <= ctrlenb_r;
			ctrlenb_f_f1 <= ctrlenb_f;
			if (ctrlenb_f2 = '1' and ctrlenb_f3 = '0') then
				ctrldata_f1 <= CTRLKEYDAT;
			end if;
		end if;
	end process;

	ctrl_push    <= '1' when (ctrlenb_r = '0' and ctrlenb_r_f1 = '1') else '0';
	ctrl_release <= '1' when (ctrlenb_f = '0' and ctrlenb_f_f1 = '1') else '0';


-- key push scan
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			onkey <= (others => (others => '0'));
		elsif (CLK'event and CLK = '1') then
			if (endflag = '1') then
				if    (e1flag  = '1') then

					case keydt is
						when X"77" => onkey(9)(0) <= not offflag;	-- ‚©‚È(Pause)
						when others =>
							onkey(0)(0) <= '0';
							onkey(0)(4) <= '0';
							onkey(0)(5) <= '0';
							onkey(0)(6) <= '0';
							onkey(0)(7) <= '0';
							onkey(7)(4) <= '0';
							onkey(7)(7) <= '0';
							onkey(9)(7) <= '0';
					end case;

				elsif (expflag = '0') then

					case keydt is
						when X"14" => onkey(0)(1) <= not offflag;	-- CTRL
						when X"12" => onkey(0)(2) <= not offflag;	-- SHIFT
						when X"59" => onkey(0)(2) <= not offflag;	-- SHIFT
						when X"11" => onkey(0)(3) <= not offflag;	-- GRAPH
						when X"16" => onkey(1)(0) <= not offflag;	-- 1
						when X"69" => onkey(1)(0) <= not offflag;	-- 1(ten)
						when X"15" => onkey(1)(1) <= not offflag;	-- Q
						when X"1c" => onkey(1)(2) <= not offflag;	-- A
						when X"1a" => onkey(1)(3) <= not offflag;	-- Z
						when X"42" => onkey(1)(4) <= not offflag;	-- K
						when X"43" => onkey(1)(5) <= not offflag;	-- I
						when X"3e" => onkey(1)(6) <= not offflag;	-- 8
						when X"75" => onkey(1)(6) <= not offflag;	-- 8(ten)
						when X"41" => onkey(1)(7) <= not offflag;	-- ,
						when X"1e" => onkey(2)(0) <= not offflag;	-- 2
						when X"72" => onkey(2)(0) <= not offflag;	-- 2(ten)
						when X"1d" => onkey(2)(1) <= not offflag;	-- W
						when X"1b" => onkey(2)(2) <= not offflag;	-- S
						when X"22" => onkey(2)(3) <= not offflag;	-- X
						when X"4b" => onkey(2)(4) <= not offflag;	-- L
						when X"44" => onkey(2)(5) <= not offflag;	-- O
						when X"46" => onkey(2)(6) <= not offflag;	-- 9
						when X"7d" => onkey(2)(6) <= not offflag;	-- 9(ten)
						when X"49" => onkey(2)(7) <= not offflag;	-- .
						when X"71" => onkey(2)(7) <= not offflag;	-- .(ten)
						when X"26" => onkey(3)(0) <= not offflag;	-- 3
						when X"7a" => onkey(3)(0) <= not offflag;	-- 3(ten)
						when X"24" => onkey(3)(1) <= not offflag;	-- E
						when X"23" => onkey(3)(2) <= not offflag;	-- D
						when X"21" => onkey(3)(3) <= not offflag;	-- C
						when X"4c" => onkey(3)(4) <= not offflag;	-- ;
						when X"79" => onkey(3)(4) <= not offflag;
						              onkey(0)(2) <= not offflag;	-- +(ten)
						when X"4d" => onkey(3)(5) <= not offflag;	-- P
						when X"05" => onkey(3)(6) <= not offflag;	-- F1
						when X"4a" => onkey(3)(7) <= not offflag;	-- /
						when X"25" => onkey(4)(0) <= not offflag;	-- 4
						when X"6b" => onkey(4)(0) <= not offflag;	-- 4(ten)
						when X"2d" => onkey(4)(1) <= not offflag;	-- R
						when X"2b" => onkey(4)(2) <= not offflag;	-- F
						when X"2a" => onkey(4)(3) <= not offflag;	-- V
						when X"52" => onkey(4)(4) <= not offflag;	-- :
						when X"7c" => onkey(4)(4) <= not offflag;
						              onkey(0)(2) <= not offflag;	-- *(ten)
						when X"54" => onkey(4)(5) <= not offflag;	-- @
						when X"06" => onkey(4)(6) <= not offflag;	-- F2
						when X"51" => onkey(4)(7) <= not offflag;	-- _
						when X"2e" => onkey(5)(0) <= not offflag;	-- 5
						when X"73" => onkey(5)(0) <= not offflag;	-- 5(ten)
						when X"2c" => onkey(5)(1) <= not offflag;	-- T
						when X"34" => onkey(5)(2) <= not offflag;	-- G
						when X"32" => onkey(5)(3) <= not offflag;	-- B
						when X"5d" => onkey(5)(4) <= not offflag;	-- ]
						when X"5b" => onkey(5)(5) <= not offflag;	-- [
						when X"04" => onkey(5)(6) <= not offflag;	-- F3
						when X"29" => onkey(5)(7) <= not offflag;	-- SPACE
						when X"36" => onkey(6)(0) <= not offflag;	-- 6
						when X"74" => onkey(6)(0) <= not offflag;	-- 6(ten)
						when X"35" => onkey(6)(1) <= not offflag;	-- Y
						when X"33" => onkey(6)(2) <= not offflag;	-- H
						when X"31" => onkey(6)(3) <= not offflag;	-- N
						when X"4e" => onkey(6)(4) <= not offflag;	-- -
						when X"7b" => onkey(6)(4) <= not offflag;	-- -
						when X"55" => onkey(6)(5) <= not offflag;	-- ^
						when X"0c" => onkey(6)(6) <= not offflag;	-- F4
						when X"45" => onkey(6)(7) <= not offflag;	-- 0
						when X"70" => onkey(6)(7) <= not offflag;	-- 0(ten)
						when X"3d" => onkey(7)(0) <= not offflag;	-- 7
						when X"6c" => onkey(7)(0) <= not offflag;	-- 7(ten)
						when X"3c" => onkey(7)(1) <= not offflag;	-- U
						when X"3b" => onkey(7)(2) <= not offflag;	-- J
						when X"3a" => onkey(7)(3) <= not offflag;	-- M
						when X"6a" => onkey(7)(5) <= not offflag;	-- \
						when X"03" => onkey(7)(6) <= not offflag;	-- F5
						when X"5a" => onkey(8)(0) <= not offflag;	-- RETURN
						when X"0d" => onkey(8)(6) <= not offflag;	-- TAB
						when X"76" => onkey(8)(7) <= not offflag;	-- ESC
						when X"0e" => onkey(9)(0) <= not offflag;	-- ‚©‚È
						when X"77" => onkey(9)(0) <= not offflag;	-- ‚©‚È(Pause)
						when X"66" => onkey(9)(2) <= not offflag;	-- BS
						when X"58" => onkey(9)(6) <= not offflag;	-- CAPS
						when others =>
							onkey(0)(0) <= '0';
							onkey(0)(4) <= '0';
							onkey(0)(5) <= '0';
							onkey(0)(6) <= '0';
							onkey(0)(7) <= '0';
							onkey(7)(4) <= '0';
							onkey(7)(7) <= '0';
							onkey(9)(7) <= '0';
					end case;

				else

					case keydt is
						when X"14" => onkey(0)(1) <= not offflag;	-- CTRL
						when X"11" => onkey(0)(3) <= not offflag;	-- GRAPH
						when X"4a" => onkey(3)(7) <= not offflag;	-- /(ten)
						when X"5a" => onkey(8)(0) <= not offflag;	-- RETURN(ten)
						when X"69" => onkey(8)(1) <= not offflag;	-- STOP
						when X"75" => onkey(8)(2) <= not offflag;	-- ª
						when X"72" => onkey(8)(3) <= not offflag;	-- «
						when X"74" => onkey(8)(4) <= not offflag;	-- ¨
						when X"6b" => onkey(8)(5) <= not offflag;	-- ©
						when X"70" => onkey(9)(1) <= not offflag;	-- INS
						when X"71" => onkey(9)(2) <= not offflag;	-- DEL
						when X"7d" => onkey(9)(3) <= not offflag;	-- PAGE
						when X"6c" => onkey(9)(4) <= not offflag;	-- HOME
						when X"7a" => onkey(9)(5) <= not offflag;	-- MODE
						when others =>
							onkey(0)(0) <= '0';
							onkey(0)(4) <= '0';
							onkey(0)(5) <= '0';
							onkey(0)(6) <= '0';
							onkey(0)(7) <= '0';
							onkey(7)(4) <= '0';
							onkey(7)(7) <= '0';
							onkey(9)(7) <= '0';
					end case;

				end if;
			else
				if (ctrl_push = '1' or ctrl_release = '1') then
					case ctrldata_f1 is

						when X"01" => onkey(1)(2) <= not ctrl_release;	-- A
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"02" => onkey(5)(3) <= not ctrl_release;	-- B
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"03" => onkey(3)(3) <= not ctrl_release;	-- C
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"04" => onkey(3)(2) <= not ctrl_release;	-- D
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"05" => onkey(3)(1) <= not ctrl_release;	-- E
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"06" => onkey(4)(2) <= not ctrl_release;	-- F
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"07" => onkey(5)(2) <= not ctrl_release;	-- G
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"08" => onkey(6)(2) <= not ctrl_release;	-- H
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"09" => onkey(1)(5) <= not ctrl_release;	-- I
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"0a" => onkey(7)(2) <= not ctrl_release;	-- J
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"0b" => onkey(1)(4) <= not ctrl_release;	-- K
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"0c" => onkey(2)(4) <= not ctrl_release;	-- L
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"0d" => onkey(7)(3) <= not ctrl_release;	-- M
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"0e" => onkey(6)(3) <= not ctrl_release;	-- N
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"0f" => onkey(2)(5) <= not ctrl_release;	-- O
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"10" => onkey(3)(5) <= not ctrl_release;	-- P
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"11" => onkey(1)(1) <= not ctrl_release;	-- Q
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"12" => onkey(4)(1) <= not ctrl_release;	-- R
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"13" => onkey(2)(2) <= not ctrl_release;	-- S
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"14" => onkey(5)(1) <= not ctrl_release;	-- T
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"15" => onkey(7)(1) <= not ctrl_release;	-- U
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"16" => onkey(4)(3) <= not ctrl_release;	-- V
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"17" => onkey(2)(1) <= not ctrl_release;	-- W
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"18" => onkey(2)(3) <= not ctrl_release;	-- X
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"19" => onkey(6)(1) <= not ctrl_release;	-- Y
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"1a" => onkey(1)(3) <= not ctrl_release;	-- Z
						              onkey(0)(1) <= not ctrl_release;	-- CTRL
						when X"1b" => onkey(8)(7) <= not ctrl_release;	-- ESC
						when X"1c" => onkey(8)(4) <= not ctrl_release;	-- ¨
						when X"1d" => onkey(8)(5) <= not ctrl_release;	-- ©
						when X"1e" => onkey(8)(2) <= not ctrl_release;	-- ª
						when X"1f" => onkey(8)(3) <= not ctrl_release;	-- «
						when X"20" => onkey(5)(7) <= not ctrl_release;	-- SPACE
						when X"21" => onkey(1)(0) <= not ctrl_release;	-- !
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"22" => onkey(2)(0) <= not ctrl_release;	-- "
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"23" => onkey(3)(0) <= not ctrl_release;	-- #
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"24" => onkey(4)(0) <= not ctrl_release;	-- $
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"25" => onkey(5)(0) <= not ctrl_release;	-- %
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"26" => onkey(6)(0) <= not ctrl_release;	-- &
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"27" => onkey(7)(0) <= not ctrl_release;	-- '
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"28" => onkey(1)(6) <= not ctrl_release;	-- (
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"29" => onkey(2)(6) <= not ctrl_release;	-- )
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"2a" => onkey(4)(4) <= not ctrl_release;	-- :
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"2b" => onkey(3)(4) <= not ctrl_release;	-- ;
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"2c" => onkey(1)(7) <= not ctrl_release;	-- ,
						when X"2d" => onkey(6)(4) <= not ctrl_release;	-- -
						when X"2e" => onkey(2)(7) <= not ctrl_release;	-- .
						when X"2f" => onkey(3)(7) <= not ctrl_release;	-- /
						when X"30" => onkey(6)(7) <= not ctrl_release;	-- 0
						when X"31" => onkey(1)(0) <= not ctrl_release;	-- 1
						when X"32" => onkey(2)(0) <= not ctrl_release;	-- 2
						when X"33" => onkey(3)(0) <= not ctrl_release;	-- 3
						when X"34" => onkey(4)(0) <= not ctrl_release;	-- 4
						when X"35" => onkey(5)(0) <= not ctrl_release;	-- 5
						when X"36" => onkey(6)(0) <= not ctrl_release;	-- 6
						when X"37" => onkey(7)(0) <= not ctrl_release;	-- 7
						when X"38" => onkey(1)(6) <= not ctrl_release;	-- 8
						when X"39" => onkey(2)(6) <= not ctrl_release;	-- 9
						when X"3a" => onkey(4)(4) <= not ctrl_release;	-- :
						when X"3b" => onkey(3)(4) <= not ctrl_release;	-- ;
						when X"3c" => onkey(1)(7) <= not ctrl_release;	-- ,
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"3d" => onkey(6)(4) <= not ctrl_release;	-- -
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"3e" => onkey(2)(7) <= not ctrl_release;	-- .
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"3f" => onkey(3)(7) <= not ctrl_release;	-- /
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"40" => onkey(4)(5) <= not ctrl_release;	-- @
						when X"41" => onkey(1)(2) <= not ctrl_release;	-- A
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"42" => onkey(5)(3) <= not ctrl_release;	-- B
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"43" => onkey(3)(3) <= not ctrl_release;	-- C
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"44" => onkey(3)(2) <= not ctrl_release;	-- D
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"45" => onkey(3)(1) <= not ctrl_release;	-- E
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"46" => onkey(4)(2) <= not ctrl_release;	-- F
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"47" => onkey(5)(2) <= not ctrl_release;	-- G
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"48" => onkey(6)(2) <= not ctrl_release;	-- H
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"49" => onkey(1)(5) <= not ctrl_release;	-- I
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"4a" => onkey(7)(2) <= not ctrl_release;	-- J
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"4b" => onkey(1)(4) <= not ctrl_release;	-- K
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"4c" => onkey(2)(4) <= not ctrl_release;	-- L
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"4d" => onkey(7)(3) <= not ctrl_release;	-- M
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"4e" => onkey(6)(3) <= not ctrl_release;	-- N
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"4f" => onkey(2)(5) <= not ctrl_release;	-- O
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"50" => onkey(3)(5) <= not ctrl_release;	-- P
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"51" => onkey(1)(1) <= not ctrl_release;	-- Q
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"52" => onkey(4)(1) <= not ctrl_release;	-- R
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"53" => onkey(2)(2) <= not ctrl_release;	-- S
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"54" => onkey(5)(1) <= not ctrl_release;	-- T
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"55" => onkey(7)(1) <= not ctrl_release;	-- U
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"56" => onkey(4)(3) <= not ctrl_release;	-- V
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"57" => onkey(2)(1) <= not ctrl_release;	-- W
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"58" => onkey(2)(3) <= not ctrl_release;	-- X
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"59" => onkey(6)(1) <= not ctrl_release;	-- Y
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"5a" => onkey(1)(3) <= not ctrl_release;	-- Z
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"5b" => onkey(5)(5) <= not ctrl_release;	-- [
						when X"5c" => onkey(7)(5) <= not ctrl_release;	-- \
						when X"5d" => onkey(5)(4) <= not ctrl_release;	-- ]
						when X"5e" => onkey(6)(5) <= not ctrl_release;	-- ^
						when X"5f" => onkey(4)(7) <= not ctrl_release;	-- _
						              onkey(0)(2) <= not ctrl_release;	-- SHIFT
						when X"61" => onkey(1)(2) <= not ctrl_release;	-- A
						when X"62" => onkey(5)(3) <= not ctrl_release;	-- B
						when X"63" => onkey(3)(3) <= not ctrl_release;	-- C
						when X"64" => onkey(3)(2) <= not ctrl_release;	-- D
						when X"65" => onkey(3)(1) <= not ctrl_release;	-- E
						when X"66" => onkey(4)(2) <= not ctrl_release;	-- F
						when X"67" => onkey(5)(2) <= not ctrl_release;	-- G
						when X"68" => onkey(6)(2) <= not ctrl_release;	-- H
						when X"69" => onkey(1)(5) <= not ctrl_release;	-- I
						when X"6a" => onkey(7)(2) <= not ctrl_release;	-- J
						when X"6b" => onkey(1)(4) <= not ctrl_release;	-- K
						when X"6c" => onkey(2)(4) <= not ctrl_release;	-- L
						when X"6d" => onkey(7)(3) <= not ctrl_release;	-- M
						when X"6e" => onkey(6)(3) <= not ctrl_release;	-- N
						when X"6f" => onkey(2)(5) <= not ctrl_release;	-- O
						when X"70" => onkey(3)(5) <= not ctrl_release;	-- P
						when X"71" => onkey(1)(1) <= not ctrl_release;	-- Q
						when X"72" => onkey(4)(1) <= not ctrl_release;	-- R
						when X"73" => onkey(2)(2) <= not ctrl_release;	-- S
						when X"74" => onkey(5)(1) <= not ctrl_release;	-- T
						when X"75" => onkey(7)(1) <= not ctrl_release;	-- U
						when X"76" => onkey(4)(3) <= not ctrl_release;	-- V
						when X"77" => onkey(2)(1) <= not ctrl_release;	-- W
						when X"78" => onkey(2)(3) <= not ctrl_release;	-- X
						when X"79" => onkey(6)(1) <= not ctrl_release;	-- Y
						when X"7a" => onkey(1)(3) <= not ctrl_release;	-- Z

						when others =>
							onkey(0)(0) <= '0';
							onkey(0)(4) <= '0';
							onkey(0)(5) <= '0';
							onkey(0)(6) <= '0';
							onkey(0)(7) <= '0';
							onkey(7)(4) <= '0';
							onkey(7)(7) <= '0';
							onkey(9)(7) <= '0';
					end case;

				end if;
			end if;
		end if;
	end process;

-- funtion key push scan
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			funckey_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (endflag = '1') then
				if (expflag = '0') then

					case keydt is
						when X"76" => funckey_i(0) <= not offflag;	-- ESC
						when X"05" => funckey_i(1) <= not offflag;	-- F1
						when X"06" => funckey_i(2) <= not offflag;	-- F2
						when X"04" => funckey_i(3) <= not offflag;	-- F3
						when X"0c" => funckey_i(4) <= not offflag;	-- F4
						when X"03" => funckey_i(5) <= not offflag;	-- F5
						when X"0b" => funckey_i(6) <= not offflag;	-- F6
						when X"83" => funckey_i(7) <= not offflag;	-- F7
						when X"0a" => funckey_i(8) <= not offflag;	-- F8
						when X"01" => funckey_i(9) <= not offflag;	-- F9
						when X"09" => funckey_i(10) <= not offflag;	-- F10
						when X"78" => funckey_i(11) <= not offflag;	-- F11
						when X"07" => funckey_i(12) <= not offflag;	-- F12
						when X"29" => funckey_i(13) <= not offflag;	-- SPACE
						when X"5a" => funckey_i(14) <= not offflag;	-- RETURN
						when X"0d" => funckey_i(15) <= not offflag;	-- TAB
						when X"14" => funckey_i(20) <= not offflag;	-- CTRL
						when X"12" => funckey_i(21) <= not offflag;	-- SHIFT
						when X"59" => funckey_i(21) <= not offflag;	-- SHIFT
						when X"11" => funckey_i(22) <= not offflag;	-- GRAPH
						when others => null;
					end case;

				else

					case keydt is
						when X"14" => funckey_i(20) <= not offflag;	-- CTRL
						when X"11" => funckey_i(22) <= not offflag;	-- GRAPH
						when X"69" => funckey_i(23) <= not offflag;	-- STOP
						when X"75" => funckey_i(16) <= not offflag;	-- ª
						when X"72" => funckey_i(17) <= not offflag;	-- «
						when X"74" => funckey_i(18) <= not offflag;	-- ¨
						when X"6b" => funckey_i(19) <= not offflag;	-- ©
						when others => null;
					end case;

				end if;
			end if;
		end if;
	end process;


-- output data
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			keymatx_i <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			case KEYMATY is
				when "1111111110"  => keymatx_i <= not onkey(0);
				when "1111111101"  => keymatx_i <= not onkey(1);
				when "1111111011"  => keymatx_i <= not onkey(2);
				when "1111110111"  => keymatx_i <= not onkey(3);
				when "1111101111"  => keymatx_i <= not onkey(4);
				when "1111011111"  => keymatx_i <= not onkey(5);
				when "1110111111"  => keymatx_i <= not onkey(6);
				when "1101111111"  => keymatx_i <= not onkey(7);
				when "1011111111"  => keymatx_i <= not onkey(8);
				when "0111111111"  => keymatx_i <= not onkey(9);
				when others => keymatx_i <= (others => '1');
			end case;
		end if;
	end process;

	KEYMATX <= keymatx_i;

	FUNCKEY <= funckey_i;

end RTL;
