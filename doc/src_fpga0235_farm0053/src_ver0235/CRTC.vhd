--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity CRTC is
	port (
		D			: in  std_logic_vector(7 downto 0);
		VRAMAD		: in  std_logic_vector(1 downto 0);
		BUSACKN		: in  std_logic;
		CRTKILLN	: in  std_logic;
		CHARMODE	: in  std_logic;	-- 0:40x20(60m) / 1:32x16
		GRAPHCHAR	: in  std_logic;	-- 0:graphic(screen3,4) / 1:character(screen1,2)
		GRAPHRESO	: in  std_logic;	-- 0:320x160 / 1:160x200
		CSS1		: in  std_logic;
		CSS2		: in  std_logic;
		CSS3		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		AOUT		: out std_logic_vector(15 downto 0);
		RDN			: out std_logic;
		CGRD		: out std_logic;
		BUSRQN		: out std_logic;
		DISPAREAN	: out std_logic;
		HSYNCN		: out std_logic;
		VSYNCN		: out std_logic;
		CHARROWENB	: out std_logic;
		DISPD		: out std_logic_vector(3 downto 0);
		DISPMD		: out std_logic_vector(3 downto 0);
		DISPTMG_LT	: out std_logic;
		DISPTMG_DT	: out std_logic;
		DISPTMG_HS	: out std_logic;
		DISPTMG_VS	: out std_logic;
		HCNT		: out std_logic_vector(9 downto 0);
		VCNT		: out std_logic_vector(8 downto 0)
	);
end CRTC;

architecture RTL of CRTC is

	signal hcnt_i		: std_logic_vector(9 downto 0);
	signal vcnt_i		: std_logic_vector(8 downto 0);

	signal hsn_i		: std_logic;
	signal vsn_i		: std_logic;

	signal vramad_lt	: std_logic_vector(1 downto 0);
	signal charmode_lt	: std_logic;
	signal graphchar_lt	: std_logic;
	signal graphreso_lt	: std_logic;
	signal css1_lt		: std_logic;
	signal css2_lt		: std_logic;
	signal css3_lt		: std_logic;
	signal crtkilln_lt	: std_logic;

	signal validline	: std_logic;

	signal busrqn_i		: std_logic;
	signal charrowenb_i	: std_logic;
	signal disparean_i	: std_logic;

	signal rdn_i		: std_logic;
	signal rdn_f1		: std_logic;

	signal charrowcnt	: std_logic_vector(3 downto 0);
	signal charrowadd	: std_logic_vector(3 downto 0);

	signal add_g		: std_logic_vector(12 downto 0);
	signal add_c		: std_logic_vector(9 downto 0);
	signal att			: std_logic;
	signal add_g_f1		: std_logic_vector(12 downto 0);
	signal add_g_f2		: std_logic_vector(12 downto 0);
	signal add_g_f3		: std_logic_vector(12 downto 0);
	signal add_c_f1		: std_logic_vector(9 downto 0);
	signal add_c_f2		: std_logic_vector(9 downto 0);
	signal add_c_f3		: std_logic_vector(9 downto 0);
	signal att_f1		: std_logic;
	signal att_f2		: std_logic;
	signal att_f3		: std_logic;
	signal att4b_f3		: std_logic_vector(3 downto 0);
	signal cadsel		: std_logic;
	signal cadsel_f1	: std_logic;
	signal cadsel_f2	: std_logic;
	signal cadsel_f3	: std_logic;

	signal dt_lt		: std_logic_vector(7 downto 0);
	signal at_lt		: std_logic_vector(7 downto 0);
	signal cg_lt		: std_logic_vector(7 downto 0);
	signal dt_lt2		: std_logic_vector(7 downto 0);
	signal at_lt2		: std_logic_vector(7 downto 0);
	signal cg_lt2		: std_logic_vector(7 downto 0);
	signal dt_lt3		: std_logic_vector(7 downto 0);
	signal at_lt3		: std_logic_vector(7 downto 0);
	signal cg_lt3		: std_logic_vector(7 downto 0);

	signal dt_sft1		: std_logic_vector(7 downto 0);
	signal at_sft1		: std_logic_vector(7 downto 0);
	signal cg_sft1		: std_logic_vector(7 downto 0);
	signal dt_sft2		: std_logic_vector(7 downto 0);
	signal at_sft2		: std_logic_vector(7 downto 0);

	signal aout_i		: std_logic_vector(15 downto 0);

	signal disptmg_hs_i	: std_logic;
	signal disptmg_vs_i	: std_logic;

	signal disptmg_lt_i	: std_logic;
	signal disptmg_dt_i	: std_logic;

	signal border		: std_logic;

	signal dispd_i		: std_logic_vector(3 downto 0);
	signal dispmd_i		: std_logic_vector(3 downto 0);

	function conv_color (
		A : std_logic_vector(3 downto 0)
	) return std_logic_vector is
		variable Y	: std_logic_vector(3 downto 0);
	begin
		case A is
			when "0000" => Y := "1100";
			when "0001" => Y := "1110";
			when "0010" => Y := "1001";
			when "0011" => Y := "1010";
			when "0100" => Y := "1111";
			when "0101" => Y := "1101";
			when "0110" => Y := "1011";
			when "0111" => Y := "0010";
			when "1000" => Y := "1100";
			when "1001" => Y := "1110";
			when "1010" => Y := "1001";
			when "1011" => Y := "1010";
			when "1100" => Y := "1111";
			when "1101" => Y := "1101";
			when "1110" => Y := "1011";
			when "1111" => Y := "0010";
			when others => Y := "1100";
		end case;
		return Y;
	end conv_color;

begin

-- horizontal counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			hcnt_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 911) then
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
			if (hcnt_i = 911) then
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
			if (hcnt_i = 0) then
				hsn_i <= '0';
			elsif (hcnt_i = 64) then
				hsn_i <= '1';
			end if;
		end if;
	end process;

-- vartical sync pulse
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			vsn_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 0) then
				if (vcnt_i = 0) then
					vsn_i <= '0';
				elsif (vcnt_i = 3) then
					vsn_i <= '1';
				end if;
			end if;
		end if;
	end process;

	HCNT   <= hcnt_i;
	VCNT   <= vcnt_i;
	HSYNCN <= hsn_i;
	VSYNCN <= vsn_i;


-- register latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			charmode_lt  <= '0';
			graphchar_lt <= '1';
			graphreso_lt <= '1';
			css1_lt      <= '1';
			css2_lt      <= '1';
			css3_lt      <= '1';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 0 and vcnt_i = 3) then
				charmode_lt  <= CHARMODE;
				graphchar_lt <= GRAPHCHAR;
				graphreso_lt <= GRAPHRESO;
				css1_lt      <= CSS1;
				css2_lt      <= CSS2;
				css3_lt      <= CSS3;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			crtkilln_lt <= '1';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 64) then
				crtkilln_lt <= CRTKILLN;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			vramad_lt <= "11";
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 0 and vcnt_i = 3) then
				vramad_lt <= VRAMAD;
			end if;
		end if;
	end process;


-- valid line
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			validline <= '0';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 0) then
				if (charmode_lt = '0') then
					if (vcnt_i = 33) then
						validline <= '1';
					elsif (vcnt_i = 233) then
						validline <= '0';
					end if;
				else
					if (vcnt_i = 37) then
						validline <= '1';
					elsif (vcnt_i = 229) then
						validline <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;


-- BUS request
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			busrqn_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (validline = '0' or crtkilln_lt = '0') then
				busrqn_i <= '1';
			else
				if (charmode_lt = '0') then
					if (hcnt_i = 80) then
						busrqn_i <= '0';
					elsif (hcnt_i = 816) then
						busrqn_i <= '1';
					end if;
				else
					if (hcnt_i = 144) then
						busrqn_i <= '0';
					elsif (hcnt_i = 752) then
						busrqn_i <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

-- character row counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			charrowcnt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				charrowcnt <= (others => '0');
			elsif (hcnt_i = 8) then
				if (charmode_lt = '0') then
					if (charrowcnt = 0) then
						charrowcnt <= "1001";
					else
						charrowcnt <= charrowcnt - 1;
					end if;
				else
					if (charrowcnt = 0) then
						charrowcnt <= "1011";
					else
						charrowcnt <= charrowcnt - 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	charrowadd <=	("1001" - charrowcnt) when (charmode_lt = '0') else
					("1011" - charrowcnt);


-- character row enable
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			charrowenb_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (charmode_lt = '0') then
				if (hcnt_i = 64) then
					if (charrowcnt = 9) then
						charrowenb_i <= '1';
					end if;
				elsif (hcnt_i = 0) then
					if (charrowcnt = 0) then
						charrowenb_i <= '0';
					end if;
				end if;
			else
				if (hcnt_i = 64) then
					if (charrowcnt = 11) then
						charrowenb_i <= '1';
					end if;
				elsif (hcnt_i = 0) then
					if (charrowcnt = 0) then
						charrowenb_i <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;


-- display area
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disparean_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				disparean_i <= '1';
			else
				if (charmode_lt = '0') then
					if (hcnt_i = 160) then
						disparean_i <= '0';
					elsif (hcnt_i = 800) then
						disparean_i <= '1';
					end if;
				else
					if (hcnt_i = 224) then
						disparean_i <= '0';
					elsif (hcnt_i = 736) then
						disparean_i <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;


	BUSRQN     <= busrqn_i;
	CHARROWENB <= charrowenb_i;
	DISPAREAN  <= disparean_i;


-- rdn for FPGA
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdn_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (validline = '0' or crtkilln_lt = '0') then
				rdn_i <= '1';
			else
				if (charmode_lt = '0') then

					if (10 = hcnt_i(9 downto 4)) then
						if    (hcnt_i(3 downto 0) = 10) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 12) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 14) then
							rdn_i <= '0';
						end if;
					elsif (11 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 50) then
						if    (hcnt_i(3 downto 0) = 0) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 4) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 6) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 10) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 12) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 14) then
							rdn_i <= '0';
						end if;
					elsif (hcnt_i(9 downto 4) = 50) then
						if    (hcnt_i(3 downto 0) = 0) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 4) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 6) then
							rdn_i <= '1';
						end if;
					else
						rdn_i <= '1';
					end if;

				else

					if (14 = hcnt_i(9 downto 4)) then
						if    (hcnt_i(3 downto 0) = 10) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 12) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 15) then
							rdn_i <= '0';
						end if;
					elsif (14 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 46) then
						if    (hcnt_i(3 downto 0) = 1) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 4) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 6) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 10) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 12) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 15) then
							rdn_i <= '0';
						end if;
					elsif (hcnt_i(9 downto 4) = 46) then
						if    (hcnt_i(3 downto 0) = 1) then
							rdn_i <= '1';
						elsif (hcnt_i(3 downto 0) = 4) then
							rdn_i <= '0';
						elsif (hcnt_i(3 downto 0) = 6) then
							rdn_i <= '1';
						end if;
					else
						rdn_i <= '1';
					end if;

				end if;

			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdn_f1 <= '1';
		elsif (CLK'event and CLK = '1') then
			rdn_f1 <= rdn_i;
		end if;
	end process;

	RDN   <= rdn_f1;


-- address for graphic mode
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			add_g <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				if (charmode_lt = '0') then
					add_g <= (others => '0');
				else
					add_g <= "0" & X"200";
				end if;
			else
				if (charmode_lt = '0') then
					if (10 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 50) then
						if (hcnt_i(3 downto 0) = 15) then
							add_g <= add_g + 1;
						end if;
					end if;
				else
					if (14 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 46) then
						if (hcnt_i(3 downto 0) = 15) then
							add_g <= add_g + 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

-- address for character mode
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			add_c <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				add_c <= (others => '0');
			else
				if (charmode_lt = '0') then

					if (10 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 50) then
						if (hcnt_i(3 downto 0) = 15) then
							add_c <= add_c + 1;
						end if;
					elsif (hcnt_i(9 downto 4) = 51) then
						if (hcnt_i(3 downto 0) = 15) then
							if (charrowcnt /= 0) then
								add_c <= add_c - 40;
							end if;
						end if;
					end if;

				else

					if (14 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 46) then
						if (hcnt_i(3 downto 0) = 15) then
							add_c <= add_c + 1;
						end if;
					elsif (hcnt_i(9 downto 4) = 47) then
						if (hcnt_i(3 downto 0) = 15) then
							if (charrowcnt /= 0) then
								add_c <= add_c - 32;
							end if;
						end if;
					end if;

				end if;
			end if;
		end if;
	end process;

-- attribute
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			att <= '0';
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				att <= '0';
			else
				if (charmode_lt = '0') then

					if (10 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 50) then
						if (hcnt_i(3 downto 0) = 11) then
							att <= '1';
						elsif (hcnt_i(3 downto 0) = 15) then
							att <= '0';
						end if;
					else
						att <= '0';
					end if;

				else

					if (14 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 46) then
						if (hcnt_i(3 downto 0) = 11) then
							att <= '1';
						elsif (hcnt_i(3 downto 0) = 15) then
							att <= '0';
						end if;
					else
						att <= '0';
					end if;

				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			add_g_f1 <= (others => '0');
			add_g_f2 <= (others => '0');
			add_g_f3 <= (others => '0');
			add_c_f1 <= (others => '0');
			add_c_f2 <= (others => '0');
			add_c_f3 <= (others => '0');
			att_f1   <= '0';
			att_f2   <= '0';
			att_f3   <= '0';
		elsif (CLK'event and CLK = '1') then
			add_g_f1 <= add_g;
			add_g_f2 <= add_g_f1;
			add_g_f3 <= add_g_f2;
			add_c_f1 <= add_c;
			add_c_f2 <= add_c_f1;
			add_c_f3 <= add_c_f2;
			att_f1   <= att;
			att_f2   <= att_f1;
			att_f3   <= att_f2;
		end if;
	end process;

	att4b_f3 <= att_f3 & att_f3 & att_f3 & att_f3;


-- cgrom address select
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			cadsel <= '0';
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				cadsel <= '0';
			else
				if (charmode_lt = '0') then

					if (11 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 51) then
						if (hcnt_i(3 downto 0) = 1) then
							cadsel <= '1';
						elsif (hcnt_i(3 downto 0) = 5) then
							cadsel <= '0';
						end if;
					else
						cadsel <= '0';
					end if;

				else

					if (15 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 47) then
						if (hcnt_i(3 downto 0) = 1) then
							cadsel <= '1';
						elsif (hcnt_i(3 downto 0) = 5) then
							cadsel <= '0';
						end if;
					else
						cadsel <= '0';
					end if;

				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			cadsel_f1 <= '0';
			cadsel_f2 <= '0';
			cadsel_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			cadsel_f1 <= cadsel;
			cadsel_f2 <= cadsel_f1;
			cadsel_f3 <= cadsel_f2;
		end if;
	end process;

	CGRD <= cadsel_f3;


-- address output
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			aout_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (validline = '0' or crtkilln_lt = '0') then
				aout_i <= (others => '0');
			else
				if (charmode_lt = '0') then
					if (cadsel_f2 = '1') then
						aout_i <= "000" & at_lt(7) & dt_lt & charrowadd;
					elsif (graphchar_lt = '0') then	-- 60m screen3/4
						aout_i <= vramad_lt & att_f3 & add_g_f3;
					else							-- 60m screen1/2
						aout_i <= vramad_lt & "000" & att_f3 & add_c_f3;
					end if;
				else
					if (cadsel_f2 = '1') then
						if (at_lt(6) = '1') then
							aout_i <= "0011" & "00" &  dt_lt(5 downto 0) & charrowadd;
						else
							aout_i <= "0010" & dt_lt & charrowadd;
						end if;
					elsif (at_lt(7) = '1') then	-- 60 screen3/4
						aout_i <= "1" & vramad_lt & (add_g_f3(12 downto 9) and att4b_f3) & add_g_f3(8 downto 0);
					else							-- 60 screen1/2
						aout_i <= "1" & vramad_lt & "000" & att_f3 & add_c_f3(8 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	AOUT <= aout_i;


-- ram data latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			at_lt <= (others => '0');
			dt_lt <= (others => '0');
			cg_lt <= (others => '0');
		elsif (CLK'event and CLK = '1') then

			if (charmode_lt = '0') then

				if (BUSACKN = '0' or graphchar_lt = '1') then	-- mk2 screen 1/2

					if (10 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 50) then
						if (hcnt_i(3 downto 0) = 14) then
							at_lt <= D;
						end if;
					end if;
					if (11 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 51) then
						if (hcnt_i(3 downto 0) = 3) then
							dt_lt <= D;
						end if;
						if (hcnt_i(3 downto 0) = 8) then
							cg_lt <= D;
						end if;
					end if;

				end if;

			else

				if (14 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 46) then
					if (hcnt_i(3 downto 0) = 14) then
						at_lt <= D;
					end if;
				end if;
				if (15 <= hcnt_i(9 downto 4) and hcnt_i(9 downto 4) < 47) then
					if (hcnt_i(3 downto 0) = 3) then
						dt_lt <= D;
					end if;
					if (hcnt_i(3 downto 0) = 8) then
						cg_lt <= D;
					end if;
				end if;

			end if;

		end if;
	end process;


-- border area
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			border <= '1';
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				border <= '1';
			elsif (charmode_lt = '0') then
				if (hcnt_i = 185) then
					border <= '0';
				elsif (hcnt_i = 825) then
					border <= '1';
				end if;
			else
				if (hcnt_i = 249) then
					border <= '0';
				elsif (hcnt_i = 761) then
					border <= '1';
				end if;
			end if;
		end if;
	end process;


-- display data
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dt_lt2 <= (others => '0');
			at_lt2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(3 downto 0) = 8) then
				dt_lt2 <= dt_lt;
				at_lt2 <= at_lt;
			end if;
		end if;
	end process;

	cg_lt2 <= cg_lt;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dt_sft1 <= (others => '0');
			at_sft1 <= (others => '0');
			cg_sft1 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(3 downto 0) = 9) then
				dt_sft1 <= dt_lt2;
				at_sft1 <= at_lt2;
				cg_sft1 <= cg_lt2;
			elsif (hcnt_i(0) = '1') then
				dt_sft1 <= dt_sft1(6 downto 0) & "0";
				at_sft1 <= at_sft1(6 downto 0) & "0";
				cg_sft1 <= cg_sft1(6 downto 0) & "0";
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dt_sft2 <= (others => '0');
			at_sft2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(3 downto 0) = 9) then
				dt_sft2 <= dt_lt2;
				at_sft2 <= at_lt2;
			elsif (hcnt_i(1 downto 0) = "01") then
				dt_sft2 <= dt_sft2(5 downto 0) & "00";
				at_sft2 <= at_sft2(5 downto 0) & "00";
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dt_lt3 <= (others => '0');
			at_lt3 <= (others => '0');
			cg_lt3 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i(3 downto 0) = 9) then
				dt_lt3 <= dt_lt2;
				at_lt3 <= at_lt2;
				cg_lt3 <= cg_lt2;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dispd_i  <= "0000";
			dispmd_i <= "0000";
		elsif (CLK'event and CLK = '1') then
			if (border = '1') then
				dispd_i  <= "0000";
				dispmd_i <= "0000";
			elsif (charmode_lt = '0') then

				if (graphchar_lt = '1') then	-- mk2 screen 1/2
					if (cg_sft1(7) = '1') then
						dispd_i  <= at_lt3(3) & at_lt3(1) & at_lt3(0) & at_lt3(2);
						dispmd_i <= "1000";
					else
						dispd_i  <= css2_lt & at_lt3(5) & at_lt3(4) & at_lt3(6);
						dispmd_i <= "1000";
					end if;
				elsif (graphreso_lt = '1') then	-- mk2 screen 3
					if (css3_lt = '0') then
						if (crtkilln_lt = '0') then
							dispd_i  <= "0000";
							dispmd_i <= "1010";
						else
							dispd_i  <= dt_sft2(7 downto 6) & at_sft2(7 downto 6);
							dispmd_i <= "1010";
						end if;
					else
						if (crtkilln_lt = '0') then
							dispd_i  <= "0000";
							dispmd_i <= "1110";
						else
							dispd_i  <= conv_color( dt_sft2(7 downto 6) & at_sft2(7 downto 6) );
							dispmd_i <= "1110";
						end if;
					end if;
				else							-- mk2 screen 4
					if (css3_lt = '0') then
						if (crtkilln_lt = '0') then
							dispd_i  <= "0000";
							dispmd_i <= "1011";
						else
							dispd_i  <= css2_lt & css1_lt & dt_sft1(7) & at_sft1(7);
							dispmd_i <= "1011";
						end if;
					else
						if (crtkilln_lt = '0') then
							dispd_i  <= "0000";
							dispmd_i <= "1111";
						else
							dispd_i  <= conv_color( css2_lt & css1_lt & dt_sft1(7) & at_sft1(7) );
							dispmd_i <= "1111";
						end if;
					end if;
				end if;

			else

				if (at_lt3(7 downto 6) = "00") then					-- 60 screen 1
					if (at_lt3(1) = '1' and (at_lt3(0) xor cg_sft1(7)) = '1' ) then
						dispd_i  <= "1100";
						dispmd_i <= "0000";
					elsif (at_lt3(1) = '0' and (at_lt3(0) xor cg_sft1(7)) = '1' ) then
						dispd_i  <= "1111";
						dispmd_i <= "0000";
					else
						dispd_i  <= "0000";
						dispmd_i <= "0000";
					end if;
				elsif (at_lt3(7 downto 6) = "01") then				-- 60 screen 2
					if (cg_sft1(7) = '1') then
						dispd_i  <= conv_color( "0" & at_lt3(1) & dt_lt3(7 downto 6) );
						dispmd_i <= "0001";
					else
						dispd_i  <= "0000";
						dispmd_i <= "0001";
					end if;
				elsif (at_lt3(7) = '1' and at_lt3(4) = '0') then	-- 60 screen 3
					dispd_i  <= conv_color( "0" & at_lt3(1) & dt_sft2(7 downto 6) );
					dispmd_i <= "0010";
				else												-- 60 screen 4
					if    (at_lt3(1) = '0' and dt_sft1(7) = '0') then
						dispd_i  <= "0000";
						dispmd_i <= "0011";
					elsif (at_lt3(1) = '0' and dt_sft1(7) = '1') then
						dispd_i  <= "1100";
						dispmd_i <= "0011";
					elsif (at_lt3(1) = '1' and dt_sft1(7) = '0') then
						dispd_i  <= "0000";
						dispmd_i <= "0111";
					else
						dispd_i  <= "1111";
						dispmd_i <= "0111";
					end if;
				end if;

			end if;
		end if;
	end process;

	DISPD  <= dispd_i;
	DISPMD <= dispmd_i;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_hs_i <= '0';
			disptmg_vs_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (hcnt_i = 9) then
				disptmg_hs_i <= '1';
				if (vcnt_i = 255) then
					disptmg_vs_i <= '1';
				else
					disptmg_vs_i <= '0';
				end if;
			else
				disptmg_hs_i <= '0';
				disptmg_vs_i <= '0';
			end if;
		end if;
	end process;

	DISPTMG_HS <= disptmg_hs_i;
	DISPTMG_VS <= disptmg_vs_i;


-- for simulation
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			disptmg_dt_i <= '0';
			disptmg_lt_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (validline = '0') then
				disptmg_dt_i <= '0';
				disptmg_lt_i <= '0';
			elsif (charmode_lt = '0') then
				if (186 <= hcnt_i and hcnt_i < 698) then
					disptmg_dt_i <= '1';
					disptmg_lt_i <= not hcnt_i(0);
				else
					disptmg_dt_i <= '0';
					disptmg_lt_i <= '0';
				end if;
			else
				if (250 <= hcnt_i and hcnt_i < 762) then
					disptmg_dt_i <= '1';
					disptmg_lt_i <= not hcnt_i(0);
				else
					disptmg_dt_i <= '0';
					disptmg_lt_i <= '0';
				end if;
			end if;
		end if;
	end process;

	DISPTMG_LT <= disptmg_lt_i;
	DISPTMG_DT <= disptmg_dt_i;

end RTL;
