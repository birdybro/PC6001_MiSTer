--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MC6847_TMGCNT is
	port (
		GM			: in  std_logic_vector(2 downto 0);
		CHRMODE		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		HCNT		: out std_logic_vector(9 downto 0);
		VCNT		: out std_logic_vector(8 downto 0);
		DLATTMG		: out std_logic;
		GMLATTMG	: out std_logic;
		DISPVALID	: out std_logic;
		DISPTMG_LT	: out std_logic;					-- display data latch pulse
		DISPTMG_DT	: out std_logic;					-- display data            (256 x 192)
		DISPTMG_BD	: out std_logic;					-- display data and border (320 x 240)
		DISPTMG_HS	: out std_logic;					-- horizontal sync pulse
		DISPTMG_VS	: out std_logic;					-- vertical sync pulse
		SCANLINE	: out std_logic_vector(3 downto 0);
		A			: out std_logic_vector(12 downto 0);
		FSN			: out std_logic;
		HSN			: out std_logic;
		RPN			: out std_logic;
		ENB			: out std_logic
	);
end MC6847_TMGCNT;

architecture RTL of MC6847_TMGCNT is

	signal hcnt_i		: std_logic_vector(9 downto 0);
	signal vcnt_i		: std_logic_vector(8 downto 0);

	signal acnt_low		: std_logic_vector(4 downto 0);
	signal acnt_high	: std_logic_vector(7 downto 0);
	signal acnt_h3low	: std_logic_vector(1 downto 0);
	signal acnt_h3high	: std_logic_vector(5 downto 0);
	signal acnt_h3chr	: std_logic_vector(3 downto 0);

	signal disptmg_dt_f1: std_logic;
	signal disptmg_dt_f2: std_logic;
	signal disptmg_dt_f3: std_logic;
	signal disptmg_lt_f1: std_logic;
	signal disptmg_lt_f2: std_logic;
	signal disptmg_lt_f3: std_logic;
	signal disptmg_bd_f1: std_logic;
	signal disptmg_bd_f2: std_logic;
	signal disptmg_bd_f3: std_logic;
	signal disptmg_hs_f1: std_logic;
	signal disptmg_hs_f2: std_logic;
	signal disptmg_hs_f3: std_logic;
	signal disptmg_vs_f1: std_logic;
	signal disptmg_vs_f2: std_logic;
	signal disptmg_vs_f3: std_logic;

	signal dispvalid_f1	: std_logic;

	signal scanline_i	: std_logic_vector(3 downto 0);

	signal acnt_lowsh	: std_logic_vector(4 downto 0);
	signal a_i			: std_logic_vector(12 downto 0);

	signal dlattmg_lg	: std_logic;
	signal dlattmg_sh	: std_logic;
	signal dlattmg_i	: std_logic;

	signal fsn_i		: std_logic;
	signal hsn_i		: std_logic;
	signal rpn_i		: std_logic;

begin

-- horizontal counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			hcnt_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 909) then
				hcnt_i <= (others => '0');
			else
				hcnt_i <= hcnt_i + 1;
			end if;
		end if;
	end process;

-- vertical counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			vcnt_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 909) then
				if (vcnt_i = 261) then
					vcnt_i <= (others => '0');
				else
					vcnt_i <= vcnt_i + 1;
				end if;
			end if;
		end if;
	end process;

-- horizontal sync pulse
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			hsn_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 1) then
				hsn_i <= '0';
			elsif (hcnt_i = 66+1) then
				hsn_i <= '1';
			end if;
		end if;
	end process;

-- field sync pulse
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			fsn_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 5 and vcnt_i = 236) then
				fsn_i <= '0';
			elsif (hcnt_i = 5 and vcnt_i = 6) then
				fsn_i <= '1';
			end if;
		end if;
	end process;

-- address counter low
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			acnt_low <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(3 downto 0) = 3) then
				if (hcnt_i(9 downto 4) = 13) then
					acnt_low <= "00000";
				elsif (hcnt_i(9 downto 4) = 14) then
					acnt_low <= "00001";
				elsif (acnt_low /= "00000") then
					acnt_low <= acnt_low + 1;
				end if;
			end if;
		end if;
	end process;

-- address counter high
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			acnt_high <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 79) then
				if (vcnt_i = 44) then
					acnt_high <= (others => '0');
				else
					acnt_high <= acnt_high + 1;
				end if;
			end if;
		end if;
	end process;

-- address counter highx3mode
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			acnt_h3low <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 79) then
				if (vcnt_i = 44) then
					acnt_h3low <= (others => '0');
				elsif (acnt_h3low = 2) then
					acnt_h3low <= (others => '0');
				else
					acnt_h3low <= acnt_h3low + 1;
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			acnt_h3high <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 79) then
				if (vcnt_i = 44) then
					acnt_h3high <= (others => '0');
				elsif (acnt_h3low = 2) then
					acnt_h3high <= acnt_h3high + 1;
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			acnt_h3chr <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 79) then
				if (vcnt_i = 44) then
					acnt_h3chr <= (others => '0');
				elsif (acnt_h3chr = 11) then
					acnt_h3chr <= (others => '0');
				else
					acnt_h3chr <= acnt_h3chr + 1;
				end if;
			end if;
		end if;
	end process;


--	CHRMODE = '1'	CHR short access
--	GM(2:0) = "000"	CG1	long access
--	GM(2:0) = "001"	RG1	long access
--	GM(2:0) = "010"	CG2	short access
--	GM(2:0) = "011"	RG2	long access
--	GM(2:0) = "100"	CG3	short access
--	GM(2:0) = "101"	RG3	long access
--	GM(2:0) = "110"	CG6	short access
--	GM(2:0) = "111"	RG6	short access

-- address counter low
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			acnt_lowsh <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(0) = '1') then
				acnt_lowsh <= acnt_low + 31;
			end if;
		end if;
	end process;

-- address output
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			a_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(0) = '1') then
				if (vcnt_i >= 44 and vcnt_i <=235) then

					if (CHRMODE = '1') then
						a_i( 4 downto  0) <= acnt_lowsh;
						a_i( 8 downto  5) <= acnt_h3high(5 downto 2);
						a_i(12 downto  9) <= "0000";
					elsif (GM = "000" or GM = "001") then
						a_i( 3 downto  0) <= acnt_low(4 downto 1);
						a_i( 9 downto  4) <= acnt_h3high;
						a_i(12 downto 10) <= "000";
					elsif (GM = "010") then
						a_i( 4 downto  0) <= acnt_lowsh;
						a_i(10 downto  5) <= acnt_h3high;
						a_i(12 downto 11) <= "00";
					elsif (GM = "011") then
						a_i( 3 downto  0) <= acnt_low(4 downto 1);
						a_i(10 downto  4) <= acnt_high(7 downto 1);
						a_i(12 downto 11) <= "00";
					elsif (GM = "100") then
						a_i( 4 downto  0) <= acnt_lowsh;
						a_i(11 downto  5) <= acnt_high(7 downto 1);
						a_i(12)           <= '0';
					elsif (GM = "101") then
						a_i( 3 downto  0) <= acnt_low(4 downto 1);
						a_i(11 downto  4) <= acnt_high;
						a_i(12)           <= '0';
					else	-- 110 111
						a_i( 4 downto 0) <= acnt_lowsh;
						a_i(12 downto 5) <= acnt_high;
					end if;

				end if;
			end if;
		end if;
	end process;


-- data latch timing
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dlattmg_lg <= '0';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(4) = '1') then
				if (hcnt_i(3 downto 0) = 1) then
					dlattmg_lg <= '1';
				elsif (hcnt_i(3 downto 0) = 3) then
					dlattmg_lg <= '0';
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dlattmg_sh <= '0';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(3 downto 0) = 3) then
				dlattmg_sh <= '1';
			elsif (hcnt_i(3 downto 0) = 5) then
				dlattmg_sh <= '0';
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dlattmg_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(0) = '1') then
				if (CHRMODE = '1' or GM = "010" or GM = "100" or GM = "110" or GM = "111") then
					dlattmg_i <= dlattmg_sh;
				else
					dlattmg_i <= dlattmg_lg;
				end if;
			end if;
		end if;
	end process;


-- scan line output
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			scanline_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(0) = '1') then
				scanline_i <= acnt_h3chr;
			end if;
		end if;
	end process;

-- row preset
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rpn_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (
				vcnt_i =  56 or vcnt_i =  68 or vcnt_i =  80 or vcnt_i =  92 or vcnt_i = 104 or
				vcnt_i = 116 or vcnt_i = 128 or vcnt_i = 140 or vcnt_i = 152 or vcnt_i = 164 or
				vcnt_i = 176 or vcnt_i = 188 or vcnt_i = 200 or vcnt_i = 212 or vcnt_i = 224
			) then
				if (hcnt_i = 80+1) then
					rpn_i <= '0';
				elsif (hcnt_i = 14+80+1) then
					rpn_i <= '1';
				end if;
			end if;
		end if;
	end process;

	HCNT <= hcnt_i;
	VCNT <= vcnt_i;

	DLATTMG  <= dlattmg_i;
	GMLATTMG <= '1' when (dlattmg_sh = '1' and acnt_lowsh = "00010") else '0';
	SCANLINE <= scanline_i;

	A       <= a_i;

	FSN <= fsn_i;
	HSN <= hsn_i;
	RPN <= rpn_i;

	ENB <= hcnt_i(0);


-- display timing output
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_dt_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			if (vcnt_i >= 44 and vcnt_i <= 235) then
				if (hcnt_i(9 downto 4) = 16 and hcnt_i(3 downto 0) = 15) then
					disptmg_dt_f1 <= '1';
				elsif (hcnt_i(9 downto 4) = 48 and hcnt_i(3 downto 0) = 15) then
					disptmg_dt_f1 <= '0';
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_dt_f2 <= '0';
			disptmg_dt_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			disptmg_dt_f2 <= disptmg_dt_f1;
			disptmg_dt_f3 <= disptmg_dt_f2;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_lt_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			if (disptmg_dt_f1 = '1') then
				disptmg_lt_f1 <= not hcnt_i(0);
			else
				disptmg_lt_f1 <= '0';
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_lt_f2 <= '0';
			disptmg_lt_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			disptmg_lt_f2 <= disptmg_lt_f1;
			disptmg_lt_f3 <= disptmg_lt_f2;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_bd_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			if (vcnt_i >= 20 and vcnt_i <= 259) then
				if (hcnt_i(9 downto 4) = 11 and hcnt_i(3 downto 0) = 15) then
					disptmg_bd_f1 <= '1';
				elsif (hcnt_i(9 downto 4) = 51 and hcnt_i(3 downto 0) = 15) then
					disptmg_bd_f1 <= '0';
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_bd_f2 <= '0';
			disptmg_bd_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			disptmg_bd_f2 <= disptmg_bd_f1;
			disptmg_bd_f3 <= disptmg_bd_f2;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_hs_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(9 downto 4) = 1 and hcnt_i(3 downto 0) = 15) then
				disptmg_hs_f1 <= '1';
			else
				disptmg_hs_f1 <= '0';
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_hs_f2 <= '0';
			disptmg_hs_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			disptmg_hs_f2 <= disptmg_hs_f1;
			disptmg_hs_f3 <= disptmg_hs_f2;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_vs_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			if (vcnt_i = 0 and hcnt_i(9 downto 4) = 1 and hcnt_i(3 downto 0) = 15) then
				disptmg_vs_f1 <= '1';
			else
				disptmg_vs_f1 <= '0';
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_vs_f2 <= '0';
			disptmg_vs_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			disptmg_vs_f2 <= disptmg_vs_f1;
			disptmg_vs_f3 <= disptmg_vs_f2;
		end if;
	end process;


	DISPTMG_LT <= disptmg_lt_f3;
	DISPTMG_DT <= disptmg_dt_f3;
	DISPTMG_BD <= disptmg_bd_f3;
	DISPTMG_HS <= disptmg_hs_f3;
	DISPTMG_VS <= disptmg_vs_f3;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dispvalid_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			if (vcnt_i >= 44 and vcnt_i <= 235) then
				if (hcnt_i(9 downto 4) = 14 and hcnt_i(3 downto 0) = 15) then
					dispvalid_f1 <= '1';
				elsif (hcnt_i(9 downto 4) = 46 and hcnt_i(3 downto 0) = 15) then
					dispvalid_f1 <= '0';
				end if;
			end if;
		end if;
	end process;

	DISPVALID  <= dispvalid_f1;


end RTL;
