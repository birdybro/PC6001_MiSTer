--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MC6847_DISP is
	port (
		D			: in  std_logic_vector(7 downto 0);
		AN_G		: in  std_logic;
		AN_S		: in  std_logic;
		INTN_EXT	: in  std_logic;
		GM			: in  std_logic_vector(2 downto 0);
		CSS			: in  std_logic;
		INV			: in  std_logic;
		HCNT		: in  std_logic_vector(9 downto 0);
		VCNT		: in  std_logic_vector(8 downto 0);
		SCANLINE	: in  std_logic_vector(3 downto 0);
		DISPVALID	: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;

-- DISPD  = 0000 Green
-- DISPD  = 0001 Yellow
-- DISPD  = 0010 Blue
-- DISPD  = 0011 Red
-- DISPD  = 0100 Buff
-- DISPD  = 0101 Cyan
-- DISPD  = 0110 Magenta
-- DISPD  = 0111 Orange
-- DISPD  = 1000 Black
-- DISPMD = 00X0 SCREEN 1 set1 (charactor)
-- DISPMD = 00X1 SCREEN 1 set2 (charactor)
-- DISPMD = 01XX SCREEN 2      (semi graphic)
-- DISPMD = 1X00 SCREEN 3 set1 (color graphic)
-- DISPMD = 1X01 SCREEN 3 set2 (color graphic)
-- DISPMD = 1X10 SCREEN 4 set1 (reso graphic)
-- DISPMD = 1X11 SCREEN 4 set2 (reso graphic)

		DISPD		: out std_logic_vector(3 downto 0);
		DISPMD		: out std_logic_vector(3 downto 0);
		Y			: out std_logic_vector(5 downto 0);
		C_A			: out std_logic_vector(3 downto 0);
		C_B			: out std_logic_vector(2 downto 0)
	);
end MC6847_DISP;

architecture RTL of MC6847_DISP is

	signal aclr			: std_logic;

	signal cromadd		: std_logic_vector(9 downto 0);

	signal cromdat		: std_logic_vector(7 downto 0);
	signal semi4dat		: std_logic_vector(7 downto 0);
	signal semi6dat		: std_logic_vector(7 downto 0);

	signal outdt_sel	: std_logic_vector(7 downto 0);
	signal outdt_parab	: std_logic_vector(7 downto 0);
	signal outdt_para	: std_logic_vector(7 downto 0);

	signal an_g_lt		: std_logic;
	signal an_s_ltb		: std_logic;
	signal an_s_lt		: std_logic;
	signal intn_ext_ltb	: std_logic;
	signal intn_ext_lt	: std_logic;
	signal gm_lt		: std_logic_vector(2 downto 0);
	signal css_ltb		: std_logic;
	signal css_lt		: std_logic;
	signal inv_ltb		: std_logic;
	signal inv_lt		: std_logic;

	signal dispvalid_fb	: std_logic;
	signal dispvalid_f1	: std_logic;

	signal outdt_semi	: std_logic_vector(3 downto 0);
	signal outdt_seris1	: std_logic;
	signal outdt_seril2	: std_logic_vector(1 downto 0);
	signal outdt_seris2	: std_logic;
	signal outdt_seril4	: std_logic_vector(1 downto 0);

	signal dispd_i		: std_logic_vector(3 downto 0);
	signal dispmd_i		: std_logic_vector(3 downto 0);

	signal y_i			: std_logic_vector(5 downto 0);
	signal c_a_i		: std_logic_vector(3 downto 0);
	signal c_b_i		: std_logic_vector(2 downto 0);

	component CGROM60S is
		port (
			aclr	: in  std_logic;
			address	: in  std_logic_vector(9 downto 0);
			clock	: in  std_logic;
			q		: out std_logic_vector(7 downto 0)
		);
	end component;

begin

	aclr <= not RSTN;

	cromadd <= D(5 downto 0) & SCANLINE;

	U_CGROM60 : CGROM60S
	port map (
		aclr	=> aclr,
		address	=> cromadd,
		clock	=> CLK,
		q		=> cromdat
	);

--	CHRMODE = '1'		short access
--	AN_S = '0' and INTN_EXT = '0'	internal cgrom
--	AN_S = '0' and INTN_EXT = '1'	external cgrom
--	AN_S = '1' and INTN_EXT = '0'	SEMI4
--	AN_S = '1' and INTN_EXT = '1'	SEMI6

--	CHRMODE = '0'
--	GM(2:0) = "000"	CG1	long access
--	GM(2:0) = "001"	RG1	long access
--	GM(2:0) = "010"	CG2	short access
--	GM(2:0) = "011"	RG2	long access
--	GM(2:0) = "100"	CG3	short access
--	GM(2:0) = "101"	RG3	long access
--	GM(2:0) = "110"	CG6	short access
--	GM(2:0) = "111"	RG6	short access

-- semigraphic data
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			semi4dat <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (HCNT(0) = '1') then
				if (SCANLINE < 6) then
					if (D(3) = '1') then
						semi4dat(7 downto 4) <= '0' & D(6 downto 4);
					else
						semi4dat(7 downto 4) <= "1000";
					end if;
					if (D(2) = '1') then
						semi4dat(3 downto 0) <= '0' & D(6 downto 4);
					else
						semi4dat(3 downto 0) <= "1000";
					end if;
				else
					if (D(1) = '1') then
						semi4dat(7 downto 4) <= '0' & D(6 downto 4);
					else
						semi4dat(7 downto 4) <= "1000";
					end if;
					if (D(0) = '1') then
						semi4dat(3 downto 0) <= '0' & D(6 downto 4);
					else
						semi4dat(3 downto 0) <= "1000";
					end if;
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			semi6dat <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (HCNT(0) = '1') then
				if (SCANLINE < 4) then
					if (D(5) = '1') then
						semi6dat(7 downto 4) <= '0' & CSS & D(7 downto 6);
					else
						semi6dat(7 downto 4) <= "1000";
					end if;
					if (D(4) = '1') then
						semi6dat(3 downto 0) <= '0' & CSS & D(7 downto 6);
					else
						semi6dat(3 downto 0) <= "1000";
					end if;
				elsif (SCANLINE < 8) then
					if (D(3) = '1') then
						semi6dat(7 downto 4) <= '0' & CSS & D(7 downto 6);
					else
						semi6dat(7 downto 4) <= "1000";
					end if;
					if (D(2) = '1') then
						semi6dat(3 downto 0) <= '0' & CSS & D(7 downto 6);
					else
						semi6dat(3 downto 0) <= "1000";
					end if;
				else
					if (D(1) = '1') then
						semi6dat(7 downto 4) <= '0' & CSS & D(7 downto 6);
					else
						semi6dat(7 downto 4) <= "1000";
					end if;
					if (D(0) = '1') then
						semi6dat(3 downto 0) <= '0' & CSS & D(7 downto 6);
					else
						semi6dat(3 downto 0) <= "1000";
					end if;
				end if;
			end if;
		end if;
	end process;

	outdt_sel <=	cromdat  when (AN_G = '0' and AN_S = '0' and INTN_EXT = '0') else
					semi4dat when (AN_G = '0' and AN_S = '1' and INTN_EXT = '0') else
					semi6dat when (AN_G = '0' and AN_S = '1' and INTN_EXT = '1') else
					D;

-- output data latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			outdt_parab <= (others => '0');
			an_g_lt     <= '0';
			an_s_ltb    <= '0';
			intn_ext_ltb<= '0';
			gm_lt       <= (others => '0');
			css_ltb     <= '0';
			inv_ltb     <= '0';
		elsif (CLK'event and CLK = '1') then
			if (DISPVALID = '1') then
				if (HCNT(3 downto 0) = 15) then
					outdt_parab <= outdt_sel;
					an_g_lt     <= AN_G;
					an_s_ltb    <= AN_S;
					intn_ext_ltb<= INTN_EXT;
					gm_lt       <= GM;
					css_ltb     <= CSS;
					inv_ltb     <= INV;
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			outdt_para  <= (others => '0');
			an_s_lt     <= '0';
			intn_ext_lt <= '0';
			css_lt      <= '0';
			inv_lt      <= '0';
		elsif (CLK'event and CLK = '1') then
			if (dispvalid_fb = '1') then
				if (HCNT(3 downto 0) = 15) then
					outdt_para  <= outdt_parab;
					an_s_lt     <= an_s_ltb;
					intn_ext_lt <= intn_ext_ltb;
					css_lt      <= css_ltb;
					inv_lt      <= inv_ltb;
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dispvalid_fb <= '0';
			dispvalid_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			if (HCNT(3 downto 0) = 15) then
				dispvalid_fb <= DISPVALID;
				dispvalid_f1 <= dispvalid_fb;
			end if;
		end if;
	end process;

-- output data P/S

	outdt_semi   <=	outdt_para(7 downto 4) when HCNT(3) = '0' else
					outdt_para(3 downto 0);

	outdt_seris1 <=	outdt_para(7) when HCNT(3 downto 1) = "000" else
					outdt_para(6) when HCNT(3 downto 1) = "001" else
					outdt_para(5) when HCNT(3 downto 1) = "010" else
					outdt_para(4) when HCNT(3 downto 1) = "011" else
					outdt_para(3) when HCNT(3 downto 1) = "100" else
					outdt_para(2) when HCNT(3 downto 1) = "101" else
					outdt_para(1) when HCNT(3 downto 1) = "110" else
					outdt_para(0);

	outdt_seril2 <=	outdt_para(7 downto 6) when HCNT(3 downto 2) = "00" else
					outdt_para(5 downto 4) when HCNT(3 downto 2) = "01" else
					outdt_para(3 downto 2) when HCNT(3 downto 2) = "10" else
					outdt_para(1 downto 0);

	outdt_seris2 <=	outdt_para(7) when HCNT(4 downto 2) = "100" else
					outdt_para(6) when HCNT(4 downto 2) = "101" else
					outdt_para(5) when HCNT(4 downto 2) = "110" else
					outdt_para(4) when HCNT(4 downto 2) = "111" else
					outdt_para(3) when HCNT(4 downto 2) = "000" else
					outdt_para(2) when HCNT(4 downto 2) = "001" else
					outdt_para(1) when HCNT(4 downto 2) = "010" else
					outdt_para(0);

	outdt_seril4 <=	outdt_para(7 downto 6) when HCNT(4 downto 3) = "10" else
					outdt_para(5 downto 4) when HCNT(4 downto 3) = "11" else
					outdt_para(3 downto 2) when HCNT(4 downto 3) = "00" else
					outdt_para(1 downto 0);

-- dispd_i = 0000	Green
-- dispd_i = 0001	Yellow
-- dispd_i = 0010	Blue
-- dispd_i = 0011	Red
-- dispd_i = 0100	Buff
-- dispd_i = 0101	Cyan
-- dispd_i = 0110	Magenta
-- dispd_i = 0111	Orange
-- dispd_i = 1000	black

-- output data color assign
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dispd_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (HCNT(0) = '1') then
				if (dispvalid_f1 = '1') then

					if (an_g_lt = '0' and an_s_lt = '0') then		-- charactor print
						if (css_lt = '0') then
							if (outdt_seris1 = inv_lt) then
								dispd_i <= "0000";
							else
								dispd_i <= "0100";
							end if;
						else
							if (outdt_seris1 = inv_lt) then
								dispd_i <= "0111";
							else
								dispd_i <= "0100";
							end if;
						end if;

					elsif (an_g_lt = '0') then					-- semi
						dispd_i <= outdt_semi;

					elsif (gm_lt = "000") then
						dispd_i <= "0" & css_lt & outdt_seril4;

					elsif (gm_lt = "010" or gm_lt = "100" or gm_lt = "110") then
						dispd_i <= "0" & css_lt & outdt_seril2;

					elsif (gm_lt = "001" or gm_lt = "011" or gm_lt = "101") then
						if (css_lt = '0') then
							if (outdt_seris2 = '0') then
								dispd_i <= "1000";
							else
								dispd_i <= "0000";
							end if;
						else
							if (outdt_seris2 = '0') then
								dispd_i <= "1000";
							else
								dispd_i <= "0100";
							end if;
						end if;

					elsif (gm_lt = "111") then
						if (css_lt = '0') then
							if (outdt_seris1 = '0') then
								dispd_i <= "1000";
							else
								dispd_i <= "0000";
							end if;
						else
							if (outdt_seris1 = '0') then
								dispd_i <= "1000";
							else
								dispd_i <= "0100";
							end if;
						end if;

					else
						dispd_i <= "1111";
					end if;

				else	-- border

					if (an_g_lt = '0') then		-- charactor / semi
						dispd_i <= "1000";
					elsif (css_lt = '0') then	-- set1
						dispd_i <= "0000";
					else						-- set2
						dispd_i <= "0100";
					end if;

				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dispmd_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (HCNT(0) = '1') then
				dispmd_i <= an_g_lt & an_s_lt & gm_lt(0) & css_lt;
			end if;
		end if;
	end process;

	DISPD      <= dispd_i;
	DISPMD     <= dispmd_i;

	y_i   <= (others => '0');
	c_a_i <= (others => '0');
	c_b_i <= (others => '0');

	Y   <= y_i;
	C_A <= c_a_i;
	C_B <= c_b_i;

end RTL;
