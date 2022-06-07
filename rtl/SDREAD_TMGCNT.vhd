--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SDREAD_TMGCNT is
	port (
		SD_DAT0		: in  std_logic;
		OUTDT		: in  std_logic_vector(7 downto 0);
		OUTENB		: in  std_logic;
		OUTCS		: in  std_logic;
		SDCNTENB	: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		INDT		: out std_logic_vector(7 downto 0);
		STATELT		: out std_logic;
		OUTDTLT		: out std_logic;
		INDTLT		: out std_logic;
		INDTLT2		: out std_logic;
		SD_CMD		: out std_logic;
		SD_DAT		: out std_logic_vector(3 downto 1);
		SD_CLK		: out std_logic
	);
end SDREAD_TMGCNT;

architecture RTL of SDREAD_TMGCNT is

	signal cntlow	: std_logic_vector(8 downto 0);
	signal cntbyte	: std_logic_vector(3 downto 0);

	signal sd_clk_i	: std_logic;
	signal sd_do_i	: std_logic;
	signal sd_di_i	: std_logic;
	signal sd_cs_i	: std_logic;

	signal sd_di_f1	: std_logic;
	signal indt_f1	: std_logic_vector(7 downto 0);
	signal indt_i	: std_logic_vector(7 downto 0);

	signal statelt_i: std_logic;
	signal outdtlt_i: std_logic;
	signal indtlt_i	: std_logic;
	signal indtlt2_i: std_logic;

begin

-- 1MHz counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			cntlow <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SDCNTENB = '0') then
				cntlow <= (others => '0');
			elsif (cntlow = 49) then
				cntlow <= (others => '0');
			else
				cntlow <= cntlow + 1;
			end if;
		end if;
	end process;

-- 1byte counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			cntbyte <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SDCNTENB = '0') then
				cntbyte <= (others => '0');
			elsif (cntlow = 49) then
				if (cntbyte = 9) then
					cntbyte <= (others => '0');
				else
					cntbyte <= cntbyte + 1;
				end if;
			end if;
		end if;
	end process;

-- SD clock generate
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sd_clk_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (SDCNTENB = '0') then
				sd_clk_i <= '0';
			elsif (OUTENB = '0') then
				sd_clk_i <= '0';
			elsif (cntlow = 0) then
				sd_clk_i <= '0';
			elsif (1 <= cntbyte and cntbyte <= 8) then
				if (cntlow = 25) then
					sd_clk_i <= '1';
				end if;
			end if;
		end if;
	end process;

-- SD output data generate
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sd_do_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (SDCNTENB = '0') then
				sd_do_i <= '1';
			elsif (OUTENB = '0') then
				sd_do_i <= '1';
			elsif (cntlow = 0) then
				if    (cntbyte = 1) then
					sd_do_i <= OUTDT(7);
				elsif (cntbyte = 2) then
					sd_do_i <= OUTDT(6);
				elsif (cntbyte = 3) then
					sd_do_i <= OUTDT(5);
				elsif (cntbyte = 4) then
					sd_do_i <= OUTDT(4);
				elsif (cntbyte = 5) then
					sd_do_i <= OUTDT(3);
				elsif (cntbyte = 6) then
					sd_do_i <= OUTDT(2);
				elsif (cntbyte = 7) then
					sd_do_i <= OUTDT(1);
				elsif (cntbyte = 8) then
					sd_do_i <= OUTDT(0);
				else
					sd_do_i <= '1';
				end if;
			end if;
		end if;
	end process;

-- SD input data generate
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sd_di_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			sd_di_f1 <= sd_di_i;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			indt_f1 <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			if (SDCNTENB = '0') then
				indt_f1 <= (others => '1');
			elsif (cntlow = 25) then
				if    (cntbyte = 1) then
					indt_f1(7) <= sd_di_f1;
				elsif (cntbyte = 2) then
					indt_f1(6) <= sd_di_f1;
				elsif (cntbyte = 3) then
					indt_f1(5) <= sd_di_f1;
				elsif (cntbyte = 4) then
					indt_f1(4) <= sd_di_f1;
				elsif (cntbyte = 5) then
					indt_f1(3) <= sd_di_f1;
				elsif (cntbyte = 6) then
					indt_f1(2) <= sd_di_f1;
				elsif (cntbyte = 7) then
					indt_f1(1) <= sd_di_f1;
				elsif (cntbyte = 8) then
					indt_f1(0) <= sd_di_f1;
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			indt_i <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			if (indtlt_i = '1') then
				indt_i <= indt_f1;
			end if;
		end if;
	end process;

	INDT      <= indt_i;

-- SD chip select output generate
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sd_cs_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (SDCNTENB = '0') then
				sd_cs_i <= '1';
			elsif (cntlow = 0) then
				sd_cs_i <= not OUTCS;
			end if;
		end if;
	end process;


-- latch pulse generate
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			statelt_i <= '0';
			outdtlt_i <= '0';
			indtlt_i  <= '0';
			indtlt2_i <= '0';
		elsif (CLK'event and CLK = '1') then

			if (SDCNTENB = '0') then
				statelt_i <= '0';
			elsif (cntbyte = 9 and cntlow = 25) then
				statelt_i <= '1';
			else
				statelt_i <= '0';
			end if;

			if (SDCNTENB = '0') then
				outdtlt_i <= '0';
			elsif (cntbyte = 9 and cntlow = 35) then
				outdtlt_i <= '1';
			else
				outdtlt_i <= '0';
			end if;

			if (SDCNTENB = '0') then
				indtlt_i  <= '0';
			elsif (cntbyte = 0 and cntlow = 25) then
				indtlt_i  <= '1';
			else
				indtlt_i  <= '0';
			end if;

			if (SDCNTENB = '0') then
				indtlt2_i <= '0';
			elsif (cntbyte = 0 and cntlow = 35) then
				indtlt2_i <= '1';
			else
				indtlt2_i <= '0';
			end if;

		end if;
	end process;

	STATELT <= statelt_i;
	OUTDTLT <= outdtlt_i;
	INDTLT  <= indtlt_i;
	INDTLT2 <= indtlt2_i;


	SD_CMD    <= sd_do_i;	-- data output
	SD_DAT(1) <= '1';		-- don't use
	SD_DAT(2) <= '1';		-- don't use
	SD_DAT(3) <= sd_cs_i;	-- chip select
	SD_CLK    <= sd_clk_i;	-- clock output

	sd_di_i   <= SD_DAT0;	-- data input

end RTL;
