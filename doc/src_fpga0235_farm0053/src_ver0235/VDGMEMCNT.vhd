--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity VDGMEMCNT is
	port (
		D			: in  std_logic_vector(7 downto 0);
		CGROMD		: in  std_logic_vector(7 downto 0);
		BUSACKN		: in  std_logic;
		VRAMSW1		: in  std_logic;
		CRTKILLN	: in  std_logic;
		CLK14M		: in  std_logic;
		RSTN		: in  std_logic;
		AOUT		: out std_logic_vector(13 downto 0);
		CGAOUT		: out std_logic_vector(11 downto 0);
		BUSRQN		: out std_logic;
		VCASN		: out std_logic;
		VRASN		: out std_logic;
		RAM_RDN		: out std_logic;
		CGROM_RDN	: out std_logic;
		CGROM_ENBN	: out std_logic;
		DISPD		: out std_logic_vector(3 downto 0);
		DISPMD		: out std_logic_vector(3 downto 0);
		DISPTMG_LT	: out std_logic;					-- display data latch pulse
		DISPTMG_DT	: out std_logic;					-- display data            (256 x 192)
		DISPTMG_BD	: out std_logic;					-- display data and border (320 x 240)
		DISPTMG_HS	: out std_logic;					-- horizontal sync pulse
		DISPTMG_VS	: out std_logic						-- vertical sync pulse
	);
end VDGMEMCNT;

architecture RTL of VDGMEMCNT is

	signal mca			: std_logic_vector(12 downto 0);
	signal mcd			: std_logic_vector(7 downto 0);
	signal hsn			: std_logic;
	signal hsn_f1		: std_logic;
	signal fsn			: std_logic;
	signal rpn			: std_logic;

	signal maintmgcnt	: std_logic_vector(3 downto 0);
	signal vcasmskn		: std_logic;

	signal mca_sel		: std_logic;
	signal mca_mux		: std_logic_vector(3 downto 0);

	signal lah			: std_logic_vector(7 downto 0);
	signal lah_tmp		: std_logic_vector(7 downto 0);
	signal att			: std_logic_vector(7 downto 0);
	signal att_tmp		: std_logic_vector(7 downto 0);

	signal mskvcnt		: std_logic_vector(11 downto 0);
	signal mskhcnt		: std_logic_vector(11 downto 0);
	signal mskv			: std_logic;
	signal mskh			: std_logic;
	signal busrqwdn		: std_logic;

	signal cgadcnt		: std_logic_vector(3 downto 0);

	signal aout_i		: std_logic_vector(13 downto 0);
	signal aout_enb		: std_logic;
	signal aout_enbn_i	: std_logic;
	signal busrqn_i		: std_logic;
	signal vcasn_i		: std_logic;
	signal vrasn_i		: std_logic;
	signal vrasn_f1		: std_logic;
	signal vcasn_m1		: std_logic;

	signal ram_rdn_f1	: std_logic;
	signal cgrom_rdn_f1	: std_logic;
	signal cgrom_enbn_f1	: std_logic;


	component MC6847 is
		port (
			D			: in  std_logic_vector(7 downto 0);
			MSN			: in  std_logic;
			AN_G		: in  std_logic;
			AN_S		: in  std_logic;
			INTN_EXT	: in  std_logic;
			GM0			: in  std_logic;
			GM1			: in  std_logic;
			GM2			: in  std_logic;
			CSS			: in  std_logic;
			INV			: in  std_logic;
			CLK14M		: in  std_logic;
			RSTN		: in  std_logic;
			A			: out std_logic_vector(12 downto 0);
			FSN			: out std_logic;
			HSN			: out std_logic;
			RPN			: out std_logic;
			Y			: out std_logic_vector(5 downto 0);
			C_A			: out std_logic_vector(3 downto 0);
			C_B			: out std_logic_vector(2 downto 0);
			DISPD		: out std_logic_vector(3 downto 0);
			DISPMD		: out std_logic_vector(3 downto 0);
			DISPTMG_LT	: out std_logic;					-- display data latch pulse
			DISPTMG_DT	: out std_logic;					-- display data            (256 x 192)
			DISPTMG_BD	: out std_logic;					-- display data and border (320 x 240)
			DISPTMG_HS	: out std_logic;					-- horizontal sync pulse
			DISPTMG_VS	: out std_logic;					-- vertical sync pulse
			HCNT		: out std_logic_vector(9 downto 0)
		);
	end component;

begin

	U_MC6847 : MC6847
	port map (
		D			=> mcd,
		MSN			=> aout_enb,
		AN_G		=> att(7),
		AN_S		=> att(6),
		INTN_EXT	=> att(5),
		GM0			=> att(4),
		GM1			=> att(3),
		GM2			=> att(2),
		CSS			=> att(1),
		INV			=> att(0),
		CLK14M		=> CLK14M,
		RSTN		=> RSTN,
		A			=> mca,
		FSN			=> fsn,
		HSN			=> hsn,
		RPN			=> rpn,
		Y			=> open,
		C_A			=> open,
		C_B			=> open,
		DISPD		=> DISPD,
		DISPMD		=> DISPMD,
		DISPTMG_LT	=> DISPTMG_LT,
		DISPTMG_DT	=> DISPTMG_DT,
		DISPTMG_BD	=> DISPTMG_BD,
		DISPTMG_HS	=> DISPTMG_HS,
		DISPTMG_VS	=> DISPTMG_VS,
		HCNT		=> open
	);

-- hsn delay
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			hsn_f1 <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
			hsn_f1 <= hsn;
		end if;
	end process;

-- main timing counter
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			maintmgcnt <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (hsn = '0') then
				maintmgcnt <= "0001";
			else
				maintmgcnt <= maintmgcnt + 1;
			end if;
		end if;
	end process;


	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			aout_enb <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (maintmgcnt = "1111") then
				if (busrqwdn = '0' and BUSACKN = '0') then
					aout_enb <= '1';
				else
					aout_enb <= '0';
				end if;
			end if;
		end if;
	end process;

	aout_enbn_i <= not aout_enb;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			vcasmskn <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
--			if (maintmgcnt = "0111") then
			if (maintmgcnt = "0011") then
				vcasmskn <= aout_enbn_i;
			end if;
		end if;
	end process;

--	vcasn_i <=	'0' when (vcasmskn = '0' and maintmgcnt(3) = '1' and maintmgcnt(1) = '1') else
--				'1';
--
--	vcasn_m1 <=	'0' when (vcasmskn = '0' and maintmgcnt = "1001") else
--				'0' when (vcasmskn = '0' and maintmgcnt = "1010") else
--				'0' when (vcasmskn = '0' and maintmgcnt = "1101") else
--				'0' when (vcasmskn = '0' and maintmgcnt = "1110") else
--				'1';
--
--	vrasn_i <=	'0' when (vcasn_i = '0' or (aout_enb = '1' and maintmgcnt(3) = '1')) else
--				'1';

	vcasn_i <=	'0' when (vcasmskn = '0' and maintmgcnt = "0111") else
				'0' when (vcasmskn = '0' and maintmgcnt = "1000") else
				'0' when (vcasmskn = '0' and maintmgcnt = "1011") else
				'0' when (vcasmskn = '0' and maintmgcnt = "1100") else
				'1';

	vcasn_m1 <=	'0' when (vcasmskn = '0' and maintmgcnt = "0110") else
				'0' when (vcasmskn = '0' and maintmgcnt = "0111") else
				'0' when (vcasmskn = '0' and maintmgcnt = "1010") else
				'0' when (vcasmskn = '0' and maintmgcnt = "1011") else
				'1';

	vrasn_i <=	'0' when (vcasn_i = '0' or (aout_enb = '1' and maintmgcnt(3) = '1')) else
				'0' when (vcasn_i = '0' or (aout_enb = '1' and maintmgcnt(2) = '1')) else
				'1';

-- Data latch

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			lah_tmp <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (maintmgcnt = "1001") then
				lah_tmp <= D;
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			att_tmp <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (maintmgcnt = "1101") then
				att_tmp <= D;
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			lah <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (maintmgcnt = "1100") then
				lah <= lah_tmp;
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			vrasn_f1 <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
			vrasn_f1 <= vrasn_i;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			att <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (vrasn_i = '1' and vrasn_f1 = '0') then
				att <= att_tmp;
			end if;
		end if;
	end process;


-- address output
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			mca_sel <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
--			mca_sel <= maintmgcnt(2);
			mca_sel <= not maintmgcnt(2);
		end if;
	end process;

	mca_mux <=	(mca(12 downto 9) + 1) when (mca_sel = '0') else
				"0000";

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			aout_i <= (others => '1');
		elsif (CLK14M'event and CLK14M = '1') then
			if (aout_enbn_i = '0') then
				aout_i <= VRAMSW1 & mca_mux & mca(8 downto 0);
			else
				aout_i <= (others => '1');
			end if;
		end if;
	end process;


-- bus request
-- vertical counter
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			mskvcnt <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (fsn = '0') then
				mskvcnt <= (others => '0');
			elsif (hsn = '0' and hsn_f1 = '1') then
				mskvcnt <= mskvcnt + 1;
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			mskv <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (fsn = '0') then
				mskv <= '0';
			elsif (mskvcnt(5 downto 0) = "100110") then
				mskv <= '1';
			end if;
		end if;
	end process;


-- horizontal counter
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			mskhcnt <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (hsn = '0') then
				mskhcnt <= (others => '0');
			elsif (maintmgcnt = "0111") then
				mskhcnt <= mskhcnt + 1;
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			mskh <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (hsn = '0') then
				mskh <= '0';
			elsif (mskhcnt(5 downto 0) = "000111") then
				mskh <= '1';
			elsif (mskhcnt(5 downto 0) = "101100") then
				mskh <= '0';
			end if;
		end if;
	end process;

	busrqwdn <= '0' when (CRTKILLN = '1' and mskv = '1' and mskh = '1') else
				'1';

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			busrqn_i <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
			if (maintmgcnt = "1111") then
				busrqn_i <= busrqwdn;
			end if;
		end if;
	end process;


-- cgrom address

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			cgadcnt <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (rpn = '0') then
				cgadcnt <= (others => '0');
			elsif (hsn = '1' and hsn_f1 = '0') then
				if (fsn = '0') then
					cgadcnt <= "1001";
				else
					cgadcnt <= cgadcnt + 1;
				end if;
			end if;
		end if;
	end process;


	CGAOUT <= lah & cgadcnt;

	mcd <=	CGROMD when (att(6) = '0' and att(5) = '1') else
			lah;

	AOUT      <= aout_i;
	BUSRQN    <= busrqn_i;
	VCASN     <= vcasn_i;
	VRASN     <= vrasn_i;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			ram_rdn_f1 <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
			if (vcasn_m1 = '0' and vrasn_i = '0') then
				ram_rdn_f1 <= '0';
			else
				ram_rdn_f1 <= '1';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			cgrom_rdn_f1 <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
--			if (vcasn_i = '0' and maintmgcnt(2) = '1') then
			if (vrasn_i = '0' and maintmgcnt(3 downto 1) = "111") then
				cgrom_rdn_f1 <= '0';
			else
				cgrom_rdn_f1 <= '1';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			cgrom_enbn_f1 <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
			if (maintmgcnt = "1101") then
				cgrom_enbn_f1 <= '0';
			elsif (maintmgcnt = "0001") then
				cgrom_enbn_f1 <= '1';
			end if;
		end if;
	end process;

	RAM_RDN   <= ram_rdn_f1;

	CGROM_RDN <= cgrom_rdn_f1;

	CGROM_ENBN <= cgrom_enbn_f1;

end RTL;
