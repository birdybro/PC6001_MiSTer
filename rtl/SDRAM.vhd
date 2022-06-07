--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SDRAM is
	port (
		DRAM_DI		: in  std_logic_vector(15 downto 0);	-- SDRAM data bus
		ADDRESS		: in  std_logic_vector(18 downto 0);
		DATA		: in  std_logic_vector(7 downto 0);
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		INIT		: in  std_logic;
		MEMNOINIT	: in  std_logic;
		MEMERRMODE	: in  std_logic;
		CLK			: in  std_logic;
		CLK_DI		: in  std_logic;
		RSTN		: in  std_logic;
		DRAM_DO		: out std_logic_vector(15 downto 0);	-- SDRAM data bus
		DRAM_DOENB	: out std_logic;						-- SDRAM data output enable
		DRAM_A		: out std_logic_vector(12 downto 0);	-- SDRAM address bus
		DRAM_CLK	: out std_logic;						-- SDRAM clock output
		DRAM_CKE	: out std_logic;						-- SDRAM clock enable
		DRAM_LDQM	: out std_logic;						-- SDRAM LowerByte Data Mask
		DRAM_UDQM	: out std_logic;						-- SDRAM UpperByte Data Mask
		DRAM_WE_N	: out std_logic;						-- SDRAM write Enable
		DRAM_CAS_N	: out std_logic;						-- SDRAM CAS
		DRAM_RAS_N	: out std_logic;						-- SDRAM RAS
		DRAM_CS_N	: out std_logic;						-- SDRAM chip select
		DRAM_BA_1	: out std_logic;						-- SDRAM Bank #1
		DRAM_BA_0	: out std_logic;						-- SDRAM Bank #0
		Q			: out std_logic_vector(15 downto 0);
		INITDONE	: out std_logic;
		MEMERR		: out std_logic
	);
end SDRAM;

architecture RTL of SDRAM is

	signal rdn_f1	: std_logic;
	signal rdn_f2	: std_logic;
	signal rdflag	: std_logic;
	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;

	signal accnt	: std_logic_vector(4 downto 0);

	signal a_i		: std_logic_vector(12 downto 0);
	signal we_n		: std_logic;
	signal cas_n	: std_logic;
	signal ras_n	: std_logic;
	signal cs_n		: std_logic;
	signal cke		: std_logic;
	signal ldqm		: std_logic;
	signal udqm		: std_logic;

	signal cscnt	: std_logic_vector(2 downto 0);

	signal add		: std_logic_vector(18 downto 0);
	signal q_i		: std_logic_vector(15 downto 0);
	signal do_i		: std_logic_vector(15 downto 0);
	signal doenb	: std_logic;

	signal addcnt	: std_logic_vector(23 downto 0);
	signal addcntlow	: std_logic_vector(4 downto 0);

	signal init_f1	: std_logic;
	signal init_f2	: std_logic;
	signal init_f3	: std_logic;

	signal initst		: std_logic_vector(2 downto 0);
	signal initcnt		: std_logic_vector(14 downto 0);
	signal initaccnt	: std_logic_vector(6 downto 0);

	signal add_lt		: std_logic_vector(18 downto 0);
	signal memerr_i		: std_logic;

	signal initdone_i	: std_logic;


begin

-- read / write pulse latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdn_f1 <= '1';
			rdn_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			rdn_f1 <= RDN;
			rdn_f2 <= rdn_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			wrn_f1 <= '1';
			wrn_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			wrn_f1 <= WRN;
			wrn_f2 <= wrn_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdflag <= '0';
		elsif (CLK'event and CLK = '1') then
			if    (wrn_f1 = '0' and wrn_f2 = '1') then
				rdflag <= '0';
			elsif (rdn_f1 = '0' and rdn_f2 = '1') then
				rdflag <= '1';
			end if;
		end if;
	end process;

-- accress counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			accnt <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			if    (wrn_f1 = '0' and wrn_f2 = '1') then
				accnt <= (others => '0');
			elsif (rdn_f1 = '0' and rdn_f2 = '1') then
				accnt <= (others => '0');
			elsif (accnt /= 31) then
				accnt <= accnt + 1;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			add  <= (others => '0');
			do_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (initst = "001") then
				add  <= (others => '0');
				do_i <= (others => '0');
			elsif (initst = "011") then
				add               <= addcnt(23 downto 5);
				do_i( 7 downto 0) <= X"AA";
				do_i(15 downto 8) <= X"AA" xor ("00000" & addcnt(23 downto 21)) xor addcnt(20 downto 13) xor addcnt(12 downto 5);
			elsif (accnt = 6) then
				add               <= ADDRESS;
				do_i( 7 downto 0) <= DATA;
				do_i(15 downto 8) <= DATA xor ("00000" & ADDRESS(18 downto 16)) xor ADDRESS(15 downto 8) xor ADDRESS(7 downto 0);
			end if;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			a_i   <= (others => '0');
			cs_n  <= '1';
			ras_n <= '1';
			cas_n <= '1';
			we_n  <= '1';
			cscnt <= "000";
		elsif (CLK'event and CLK = '1') then

			if (initst = "000") then
				a_i   <= (others => '0');
				cs_n  <= '1';
				ras_n <= '1';
				cas_n <= '1';
				we_n  <= '1';
				cscnt <= "000";

			elsif (initst = "001") then
				a_i   <= (others => '0');
				cs_n  <= '0';
				ras_n <= '1';
				cas_n <= '1';
				we_n  <= '1';
				cscnt <= "000";

			elsif (initst = "010") then
				if (initaccnt = 1 or initaccnt = 92) then		-- PREA
					a_i   <= "00100" & "00000000";
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '1';
					we_n  <= '0';
					cscnt <= "000";
				elsif (initaccnt = 4 or initaccnt = 95) then	-- CBR
					a_i   <= (others => '0');
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '0';
					we_n  <= '1';
					cscnt <= "000";
				elsif (initaccnt = 88) then						-- MRS
					a_i   <= "00000" & "00100000";
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '0';
					we_n  <= '0';
					cscnt <= "000";
				elsif (initaccnt =  2 or initaccnt = 80 or initaccnt = 89 or initaccnt = 93) then	-- NOP
					a_i   <= (others => '0');
					cs_n  <= '1';
					ras_n <= '1';
					cas_n <= '1';
					we_n  <= '1';
					cscnt <= "000";
				else
					if (cscnt = "111") then
						cs_n  <= '0';
					else
						cs_n  <= '1';
					end if;
					cscnt <= cscnt + 1;
				end if;

			elsif (initst = "011") then
				if    (addcntlow = 7) then						-- ACT
					a_i   <= "00" & add(18 downto 8);
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '1';
					we_n  <= '1';
					cscnt <= "000";
				elsif (addcntlow = 10) then						-- WR
					a_i   <= "00100" & add(7 downto 0);
					cs_n  <= '0';
					ras_n <= '1';
					cas_n <= '0';
					we_n  <= '0';
					cscnt <= "000";
				elsif (addcntlow = 14) then						-- PREA
					a_i   <= "00100" & "00000000";
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '1';
					we_n  <= '0';
					cscnt <= "000";
				elsif (addcntlow = 17) then						-- CBR
					a_i   <= (others => '0');
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '0';
					we_n  <= '1';
					cscnt <= "000";
				elsif (addcntlow = 0 or addcntlow = 8 or addcntlow = 11 or addcntlow = 15) then		-- NOP
					a_i   <= (others => '0');
					cs_n  <= '1';
					ras_n <= '1';
					cas_n <= '1';
					we_n  <= '1';
					cscnt <= "000";
				else
					if (cscnt = "111") then
						cs_n  <= '0';
					else
						cs_n  <= '1';
					end if;
					cscnt <= cscnt + 1;
				end if;

			else
				if    (accnt = 7) then						-- ACT
					a_i   <= "00" & add(18 downto 8);
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '1';
					we_n  <= '1';
					cscnt <= "000";
				elsif (accnt = 10) then						-- RD / WR
					a_i   <= "00100" & add(7 downto 0);
					cs_n  <= '0';
					ras_n <= '1';
					cas_n <= '0';
					we_n  <= rdflag;
					cscnt <= "000";
				elsif (accnt = 14) then						-- PREA
					a_i   <= "00100" & "00000000";
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '1';
					we_n  <= '0';
					cscnt <= "000";
				elsif (accnt = 17) then						-- CBR
					a_i   <= (others => '0');
					cs_n  <= '0';
					ras_n <= '0';
					cas_n <= '0';
					we_n  <= '1';
					cscnt <= "000";
				elsif (accnt = 0 or accnt = 8 or accnt = 11 or accnt = 15) then		-- NOP
					a_i   <= (others => '0');
					cs_n  <= '1';
					ras_n <= '1';
					cas_n <= '1';
					we_n  <= '1';
					cscnt <= "000";
				else
					if (cscnt = "111") then
						cs_n  <= '0';
					else
						cs_n  <= '1';
					end if;
					cscnt <= cscnt + 1;
				end if;

			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			doenb <= '0';
		elsif (CLK'event and CLK = '1') then
			if (initst = "011") then
				if (addcntlow = 9) then
					doenb <= '1';
				elsif (addcntlow = 12) then
					doenb <= '0';
				end if;
			elsif (initst = "100") then
				if (accnt = 9) then
					doenb <= (not rdflag);
				elsif (accnt = 12) then
					doenb <= '0';
				end if;
			end if;
		end if;
	end process;

-- Initialize
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			init_f1 <= '0';
			init_f2 <= '0';
			init_f3 <= '0';
		elsif (CLK'event and CLK = '1') then
			init_f1 <= INIT;
			init_f2 <= init_f1;
			init_f3 <= init_f2;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			initst    <= "000";
			initcnt   <= (others => '0');
			initaccnt <= (others => '0');
			addcnt    <= X"000000";
		elsif (CLK'event and CLK = '1') then
			if (init_f2 = '1' and init_f3 = '0') then
				initst    <= "001";
				initcnt   <= (others => '0');
				initaccnt <= (others => '0');
			else
				case initst is
					when "001" =>
						if (initcnt = 20000) then
							initst    <= "010";
							initaccnt <= (others => '0');
							initcnt   <= (others => '0');
						else
							initcnt   <= initcnt + 1;
						end if;

					when "010" =>
						if (initaccnt = 100) then
							if (MEMNOINIT = '1') then
								initst    <= "100";
							else
								initst    <= "011";
								addcnt    <= X"000000";
							end if;
							initaccnt <= (others => '0');
						else
							initaccnt <= initaccnt + 1;
						end if;

					when "011" =>
						if (addcnt = X"FFFFFF") then
							initst    <= "100";
							addcnt    <= X"000000";
						else
							addcnt    <= addcnt + 1;
						end if;

					when "100" =>
						initcnt   <= (others => '0');
						initaccnt <= (others => '0');

					when others =>
						initst    <= "000";
						initcnt   <= (others => '0');
						initaccnt <= (others => '0');
				end case;
			end if;
		end if;
	end process;

	addcntlow <= addcnt(4 downto 0);


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			initdone_i  <= '0';
		elsif (CLK'event and CLK = '1') then
			if (initst = "100") then
				initdone_i  <= '1';
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			cke  <= '0';
			ldqm <= '1';
			udqm <= '1';
		elsif (CLK'event and CLK = '1') then
			if (initst = "001") then
				cke  <= '1';
				ldqm <= '0';
				udqm <= '0';
			end if;
		end if;
	end process;


-- output data
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			DRAM_DO		<= (others => '0');
			DRAM_DOENB	<= '0';
			DRAM_A		<= (others => '0');
			DRAM_CS_N	<= '1';
			DRAM_RAS_N	<= '1';
			DRAM_CAS_N	<= '1';
			DRAM_WE_N	<= '1';
			DRAM_CKE	<= '0';
			DRAM_LDQM	<= '1';
			DRAM_UDQM	<= '1';
		elsif (CLK'event and CLK = '0') then
			DRAM_DO		<= do_i;
			DRAM_DOENB	<= doenb;
			DRAM_A		<= a_i;
			DRAM_CS_N	<= cs_n;
			DRAM_RAS_N	<= ras_n;
			DRAM_CAS_N	<= cas_n;
			DRAM_WE_N	<= we_n;
			DRAM_CKE	<= cke;
			DRAM_LDQM	<= ldqm;
			DRAM_UDQM	<= udqm;
		end if;
	end process;

-- input data latch
	process (CLK_DI,RSTN)
	begin
		if (RSTN = '0') then
			q_i    <= (others => '0');
			add_lt <= (others => '0');
		elsif (CLK_DI'event and CLK_DI = '1') then
			if (accnt = 13 and rdflag = '1') then
				q_i <= DRAM_DI;
				add_lt <= add;
			end if;
		end if;
	end process;

	process (CLK_DI,RSTN)
	begin
		if (RSTN = '0') then
			memerr_i <= '0';
		elsif (CLK_DI'event and CLK_DI = '1') then
			if (q_i(15 downto 8) /= (q_i(7 downto 0) xor ("00000" & add_lt(18 downto 16)) xor add_lt(15 downto 8) xor add_lt(7 downto 0))) then
				memerr_i <= '1';
			elsif (MEMERRMODE = '1') then
				memerr_i <= '0';
			end if;
		end if;
	end process;


	DRAM_CLK	<= CLK;

	DRAM_BA_1	<= '0';
	DRAM_BA_0	<= '0';


	Q <= q_i;

	INITDONE	<= initdone_i;

	MEMERR		<= memerr_i;

end RTL;
