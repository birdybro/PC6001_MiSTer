--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity RSTGEN is
	port (
		LOCK_PLL		: in  std_logic;
		SDRAM_INITDONE	: in  std_logic;
		SDCAD_INITDONE	: in  std_logic;
		CLK4MCNT		: in  std_logic_vector(1 downto 0);
		CLK100M			: in  std_logic;
		CLK50M			: in  std_logic;
		CLK16M			: in  std_logic;
		WRN				: in  std_logic;
		RSTN			: in  std_logic;
		SDRAM_INIT		: out std_logic;
		SDCAD_INIT		: out std_logic;
		SDCAD_INIT2		: out std_logic;
		CPU_RSTN		: out std_logic;
		PIO_RSTN		: out std_logic
	);
end RSTGEN;

architecture RTL of RSTGEN is

	signal sdraminit_f1	: std_logic;
	signal sdraminit_f2	: std_logic;
	signal sdraminit_f3	: std_logic;

	signal sdcadinit_f1	: std_logic;
	signal sdcadinit_f2	: std_logic;
	signal sdcadinit_f3	: std_logic;
	signal sdcadinit_f4	: std_logic;
	signal sdcadinit_f5	: std_logic;
	signal sdcadinit_f6	: std_logic;

	signal initdone_f1	: std_logic;
	signal initdone_f2	: std_logic;
	signal initdone_f3	: std_logic;

	signal cpu_rstn_f1	: std_logic;
	signal cpu_rstn_f2	: std_logic;
	signal cpu_rstn_f3	: std_logic;
	signal pio_rstn_i	: std_logic;

begin

	process (CLK100M,RSTN)
	begin
		if (RSTN = '0') then
			sdraminit_f1 <= '0';
			sdraminit_f2 <= '0';
			sdraminit_f3 <= '0';
		elsif (CLK100M'event and CLK100M = '1') then
			sdraminit_f1 <= LOCK_PLL;
			sdraminit_f2 <= sdraminit_f1;
			sdraminit_f3 <= sdraminit_f2;
		end if;
	end process;

	SDRAM_INIT <= sdraminit_f3;


	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			sdcadinit_f1 <= '0';
			sdcadinit_f2 <= '0';
			sdcadinit_f3 <= '0';
			sdcadinit_f4 <= '0';
			sdcadinit_f5 <= '0';
			sdcadinit_f6 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			sdcadinit_f1 <= SDRAM_INITDONE;
			sdcadinit_f2 <= sdcadinit_f1;
			sdcadinit_f3 <= sdcadinit_f2;
			sdcadinit_f4 <= sdcadinit_f3;
			sdcadinit_f5 <= sdcadinit_f4;
			sdcadinit_f6 <= sdcadinit_f5;
		end if;
	end process;

	SDCAD_INIT  <= sdcadinit_f3;
	SDCAD_INIT2 <= sdcadinit_f6;


	process (CLK16M,RSTN)
	begin
		if (RSTN = '0') then
			initdone_f1 <= '0';
			initdone_f2 <= '0';
			initdone_f3 <= '0';
		elsif (CLK16M'event and CLK16M = '1') then
			initdone_f1 <= SDCAD_INITDONE;
			initdone_f2 <= initdone_f1;
			initdone_f3 <= initdone_f2;
		end if;
	end process;

	process (CLK16M,RSTN)
	begin
		if (RSTN = '0') then
			pio_rstn_i  <= '0';
			cpu_rstn_f1 <= '0';
			cpu_rstn_f2 <= '0';
			cpu_rstn_f3 <= '0';
		elsif (CLK16M'event and CLK16M = '1') then
			if (initdone_f3 = '0') then
				if (CLK4MCNT = "11" and WRN = '1') then
					pio_rstn_i  <= '0';
					cpu_rstn_f1 <= '0';
					cpu_rstn_f2 <= '0';
					cpu_rstn_f3 <= '0';
				end if;
			else
				if (CLK4MCNT = "11") then
					pio_rstn_i  <= '1';
					cpu_rstn_f1 <= pio_rstn_i;
					cpu_rstn_f2 <= cpu_rstn_f1;
					cpu_rstn_f3 <= cpu_rstn_f2;
				end if;
			end if;
		end if;
	end process;

	CPU_RSTN <= cpu_rstn_f3;
	PIO_RSTN <= pio_rstn_i;

end RTL;
