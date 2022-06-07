--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SEG7DISP is
	port (
		FPGA_VER	: in  std_logic_vector(15 downto 0);
		FIRM_VER	: in  std_logic_vector(15 downto 0);
		CMT_COUNTER	: in  std_logic_vector(15 downto 0);
		CPU_ADD		: in  std_logic_vector(15 downto 0);
		BUTTON		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		HEX3_D		: out std_logic_vector(6 downto 0);
		HEX3_DP		: out std_logic;
		HEX2_D		: out std_logic_vector(6 downto 0);
		HEX2_DP		: out std_logic;
		HEX1_D		: out std_logic_vector(6 downto 0);
		HEX1_DP		: out std_logic;
		HEX0_D		: out std_logic_vector(6 downto 0);
		HEX0_DP		: out std_logic
	);
end SEG7DISP;

architecture RTL of SEG7DISP is

	component SEG7SUB is
		port (
			DATA		: in  std_logic_vector(7 downto 0);
			HEX_D		: out std_logic_vector(6 downto 0);
			HEX_DP		: out std_logic
		);
	end component;

	signal button_f	: std_logic_vector(1 downto 0);
	signal selcnt	: std_logic_vector(1 downto 0);
	signal seldisp3	: std_logic_vector(7 downto 0);
	signal seldisp2	: std_logic_vector(7 downto 0);
	signal seldisp1	: std_logic_vector(7 downto 0);
	signal seldisp0	: std_logic_vector(7 downto 0);

	signal cmtcnt3_tmp	: std_logic_vector(7 downto 0);
	signal cmtcnt2_tmp	: std_logic_vector(7 downto 0);
	signal cmtcnt1_tmp	: std_logic_vector(7 downto 0);
	signal cmtcnt0_tmp	: std_logic_vector(7 downto 0);

	signal cpuadd3_tmp	: std_logic_vector(7 downto 0);
	signal cpuadd2_tmp	: std_logic_vector(7 downto 0);
	signal cpuadd1_tmp	: std_logic_vector(7 downto 0);
	signal cpuadd0_tmp	: std_logic_vector(7 downto 0);

	signal firmvr3_tmp	: std_logic_vector(7 downto 0);
	signal firmvr2_tmp	: std_logic_vector(7 downto 0);
	signal firmvr1_tmp	: std_logic_vector(7 downto 0);
	signal firmvr0_tmp	: std_logic_vector(7 downto 0);

begin

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			button_f <= "11";
		elsif (CLK'event and CLK = '1') then
			button_f <= button_f(0) & BUTTON;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			selcnt <= "00";
		elsif (CLK'event and CLK = '1') then
			if (button_f = "10") then
				if (selcnt = "11") then
					selcnt <= "00";
				else
					selcnt <= selcnt + 1;
				end if;
			end if;
		end if;
	end process;

	cmtcnt3_tmp  <=	("0000" & CMT_COUNTER(15 downto 12)) + X"30" when ( CMT_COUNTER(15 downto 12) < "1010" ) else
					("0000" & CMT_COUNTER(15 downto 12)) + X"41" - X"0A";

	cmtcnt2_tmp  <=	("0000" & CMT_COUNTER(11 downto  8)) + X"30" when ( CMT_COUNTER(11 downto  8) < "1010" ) else
					("0000" & CMT_COUNTER(11 downto  8)) + X"41" - X"0A";

	cmtcnt1_tmp  <=	("0000" & CMT_COUNTER( 7 downto  4)) + X"30" when ( CMT_COUNTER( 7 downto  4) < "1010" ) else
					("0000" & CMT_COUNTER( 7 downto  4)) + X"41" - X"0A";

	cmtcnt0_tmp  <=	("0000" & CMT_COUNTER( 3 downto  0)) + X"30" when ( CMT_COUNTER( 3 downto  0) < "1010" ) else
					("0000" & CMT_COUNTER( 3 downto  0)) + X"41" - X"0A";


	cpuadd3_tmp  <=	("0000" & CPU_ADD(15 downto 12)) + X"30" when ( CPU_ADD(15 downto 12) < "1010" ) else
					("0000" & CPU_ADD(15 downto 12)) + X"41" - X"0A";

	cpuadd2_tmp  <=	("0000" & CPU_ADD(11 downto  8)) + X"30" when ( CPU_ADD(11 downto  8) < "1010" ) else
					("0000" & CPU_ADD(11 downto  8)) + X"41" - X"0A";

	cpuadd1_tmp  <=	("0000" & CPU_ADD( 7 downto  4)) + X"30" when ( CPU_ADD( 7 downto  4) < "1010" ) else
					("0000" & CPU_ADD( 7 downto  4)) + X"41" - X"0A";

	cpuadd0_tmp  <=	("0000" & CPU_ADD( 3 downto  0)) + X"30" when ( CPU_ADD( 3 downto  0) < "1010" ) else
					("0000" & CPU_ADD( 3 downto  0)) + X"41" - X"0A";


	firmvr3_tmp  <=	("0000" & FIRM_VER(15 downto 12)) + X"30" when ( FIRM_VER(15 downto 12) < "1010" ) else
					("0000" & FIRM_VER(15 downto 12)) + X"41" - X"0A";

	firmvr2_tmp  <=	("0000" & FIRM_VER(11 downto  8)) + X"30" when ( FIRM_VER(11 downto  8) < "1010" ) else
					("0000" & FIRM_VER(11 downto  8)) + X"41" - X"0A";

	firmvr1_tmp  <=	("0000" & FIRM_VER( 7 downto  4)) + X"30" when ( FIRM_VER( 7 downto  4) < "1010" ) else
					("0000" & FIRM_VER( 7 downto  4)) + X"41" - X"0A";

	firmvr0_tmp  <=	("0000" & FIRM_VER( 3 downto  0)) + X"30" when ( FIRM_VER( 3 downto  0) < "1010" ) else
					("0000" & FIRM_VER( 3 downto  0)) + X"41" - X"0A";


	seldisp3 <=	(cmtcnt3_tmp                      ) when (selcnt = "00") else
				X"48"                               when (selcnt = "01") else
				(firmvr3_tmp                      ) when (selcnt = "10") else
				cpuadd3_tmp;

	seldisp2 <=	(cmtcnt2_tmp                      ) when (selcnt = "00") else
				(   FPGA_VER(11 downto  8) + X"30") when (selcnt = "01") else
				(firmvr2_tmp                      ) when (selcnt = "10") else
				cpuadd2_tmp;

	seldisp1 <=	(cmtcnt1_tmp                      ) when (selcnt = "00") else
				(   FPGA_VER( 7 downto  4) + X"30") when (selcnt = "01") else
				(firmvr1_tmp                      ) when (selcnt = "10") else
				cpuadd1_tmp;

	seldisp0 <=	(cmtcnt0_tmp                      ) when (selcnt = "00") else
				(   FPGA_VER( 3 downto  0) + X"30") when (selcnt = "01") else
				(firmvr0_tmp                      ) when (selcnt = "10") else
				cpuadd0_tmp;


	U_SEG7SUB_3 : SEG7SUB
	port map (
		DATA		=> seldisp3,
		HEX_D		=> HEX3_D,
		HEX_DP		=> HEX3_DP
	);

	U_SEG7SUB_2 : SEG7SUB
	port map (
		DATA		=> seldisp2,
		HEX_D		=> HEX2_D,
		HEX_DP		=> HEX2_DP
	);

	U_SEG7SUB_1 : SEG7SUB
	port map (
		DATA		=> seldisp1,
		HEX_D		=> HEX1_D,
		HEX_DP		=> HEX1_DP
	);

	U_SEG7SUB_0 : SEG7SUB
	port map (
		DATA		=> seldisp0,
		HEX_D		=> HEX0_D,
		HEX_DP		=> HEX0_DP
	);


end RTL;
