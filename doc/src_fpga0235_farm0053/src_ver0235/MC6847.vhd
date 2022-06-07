--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MC6847 is
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
end MC6847;

architecture RTL of MC6847 is

	component MC6847_TMGCNT is
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
	end component;

	component MC6847_DISP is
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
			DISPD		: out std_logic_vector(3 downto 0);
			DISPMD		: out std_logic_vector(3 downto 0);
			Y			: out std_logic_vector(5 downto 0);
			C_A			: out std_logic_vector(3 downto 0);
			C_B			: out std_logic_vector(2 downto 0)
		);
	end component;

	signal a_i			: std_logic_vector(12 downto 0);
	signal hcnt_i		: std_logic_vector(9 downto 0);
	signal vcnt_i		: std_logic_vector(8 downto 0);
	signal dlattmg_i	: std_logic;
	signal gmlattmg_i	: std_logic;
	signal dispvalid_i	: std_logic;
	signal scanline_i	: std_logic_vector(3 downto 0);

	signal gm_i			: std_logic_vector(2 downto 0);
	signal chrmode_i	: std_logic;
	signal enb_i		: std_logic;

	signal d_i			: std_logic_vector(7 downto 0);
	signal an_g_i		: std_logic;
	signal an_s_i		: std_logic;
	signal intn_ext_i	: std_logic;
	signal gm0_i		: std_logic;
	signal gm1_i		: std_logic;
	signal gm2_i		: std_logic;
	signal css_i		: std_logic;
	signal inv_i		: std_logic;

begin

	U_MC6847_TMGCNT : MC6847_TMGCNT
	port map (
		GM			=> gm_i,
		CHRMODE		=> chrmode_i,
		CLK			=> CLK14M,
		RSTN		=> RSTN,
		HCNT		=> hcnt_i,
		VCNT		=> vcnt_i,
		DLATTMG		=> dlattmg_i,
		GMLATTMG	=> gmlattmg_i,
		DISPVALID	=> dispvalid_i,
		DISPTMG_LT	=> DISPTMG_LT,
		DISPTMG_DT	=> DISPTMG_DT,
		DISPTMG_BD	=> DISPTMG_BD,
		DISPTMG_HS	=> DISPTMG_HS,
		DISPTMG_VS	=> DISPTMG_VS,
		SCANLINE	=> scanline_i,
		A			=> a_i,
		FSN			=> FSN,
		HSN			=> HSN,
		RPN			=> RPN,
		ENB			=> enb_i
	);

	U_MC6847_DISP : MC6847_DISP
	port map (
		D			=> d_i,
		AN_G		=> an_g_i,
		AN_S		=> an_s_i,
		INTN_EXT	=> intn_ext_i,
		GM			=> gm_i,
		CSS			=> css_i,
		INV			=> inv_i,
		HCNT		=> hcnt_i,
		VCNT		=> vcnt_i,
		SCANLINE	=> scanline_i,
		DISPVALID	=> dispvalid_i,
		CLK			=> CLK14M,
		RSTN		=> RSTN,
		DISPD		=> DISPD,
		DISPMD		=> DISPMD,
		Y			=> Y,
		C_A			=> C_A,
		C_B			=> C_B
	);

	A <= a_i;

-- data latch timing
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			d_i			<= (others => '0');
			an_g_i		<= '0';
			an_s_i		<= '0';
			intn_ext_i	<= '0';
			gm0_i		<= '0';
			gm1_i		<= '0';
			gm2_i		<= '0';
			css_i		<= '0';
			inv_i		<= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (enb_i = '1' and dlattmg_i = '1') then
				d_i			<= D;
				an_g_i		<= AN_G;
				an_s_i		<= AN_S;
				intn_ext_i	<= INTN_EXT;
				gm0_i		<= GM0;
				gm1_i		<= GM1;
				gm2_i		<= GM2;
				css_i		<= CSS;
				inv_i		<= INV;
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			chrmode_i	<= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (enb_i = '1' and dlattmg_i = '1') then
				chrmode_i	<= not AN_G;
			end if;
		end if;
	end process;

	gm_i      <= (gm2_i & gm1_i & gm0_i);

	HCNT <= hcnt_i;

end RTL;

