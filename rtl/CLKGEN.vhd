--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity CLKGEN is
	port (
		CLK50M1		: in  std_logic;	-- clock 50MHz input #1
		CLK50M0		: in  std_logic;	-- clock 50MHz input #0
		MK2MODE		: in  std_logic;
		RSTN		: in  std_logic;
		CLK14MOUT	: out std_logic;
		CLK16MOUT	: out std_logic;
		CLK100MOUT	: out std_logic;
		CLK100M_DI	: out std_logic;
		CLK50MOUT	: out std_logic;
		CLK25MOUT	: out std_logic;
		CLK4MOUT	: out std_logic;
		CLK4MCNTOUT	: out std_logic_vector(1 downto 0);
		CLK1SOUT	: out std_logic;
		LOCK_PLL	: out std_logic
	);
end CLKGEN;

architecture RTL of CLKGEN is

	component PLL114M is
		port (
			ARESET	: in  std_logic;
			INCLK0	: in  std_logic;
			C0		: out std_logic;
			C1		: out std_logic;
			LOCKED	: out std_logic
		);
	end component;

	component PLL25M_P6 is
		port (
			ARESET	: in  std_logic;
			INCLK0	: in  std_logic;
			C0		: out std_logic;
			LOCKED	: out std_logic
		);
	end component;

	component PLL25M_MK2 is
		port (
			ARESET	: in  std_logic;
			INCLK0	: in  std_logic;
			C0		: out std_logic;
			LOCKED	: out std_logic
		);
	end component;

	component PLL16M100M is
		port (
			ARESET	: in  std_logic;
			INCLK0	: in  std_logic;
			C0		: out std_logic;
			C1		: out std_logic;
			C2		: out std_logic;
			C3		: out std_logic;
			LOCKED	: out std_logic
		);
	end component;

	signal aclr			: std_logic;
	signal aclr25m		: std_logic;

	signal clk14m		: std_logic;
	signal clk114m		: std_logic;
	signal clk16m		: std_logic;
	signal clk25m_p6	: std_logic;
	signal clk25m_mk2	: std_logic;
	signal clk50m		: std_logic;
	signal clk100m		: std_logic;
	signal clk100m_dly	: std_logic;

	signal lock_14m		: std_logic;
	signal lock_25m_mk2	: std_logic;
	signal lock_25m_p6	: std_logic;
	signal lock_16m		: std_logic;

	signal clk4mcnt	: std_logic_vector(1 downto 0);

	signal clk1scntlow	: std_logic_vector(15 downto 0);
	signal clk1scnthigh	: std_logic_vector(8 downto 0);
	signal clk1sout_i	: std_logic;

begin

	U_PLL114M : PLL114M
	port map (
		ARESET	=> aclr,
		INCLK0	=> CLK50M0,
		C0		=> clk114m,
		C1		=> clk14m,
		LOCKED	=> lock_14m
	);

	aclr25m <= not lock_14m;

	U_PLL25M_MK2 : PLL25M_MK2
	port map (
		ARESET	=> aclr25m,
		INCLK0	=> clk114m,
		C0		=> clk25m_mk2,
		LOCKED	=> lock_25m_mk2
	);

	U_PLL25M_P6 : PLL25M_P6
	port map (
		ARESET	=> aclr25m,
		INCLK0	=> clk114m,
		C0		=> clk25m_p6,
		LOCKED	=> lock_25m_p6
	);

	U_PLL16M100M : PLL16M100M
	port map (
		ARESET	=> aclr,
		INCLK0	=> CLK50M1,
		C0		=> clk16m,
		C1		=> clk50m,
		C2		=> clk100m,
		C3		=> clk100m_dly,
		LOCKED	=> lock_16m
	);

	aclr <= not RSTN;

	process (clk16m,RSTN)
	begin
		if (RSTN = '0') then
			clk4mcnt <= (others => '0');
		elsif (clk16m'event and clk16m = '1') then
			clk4mcnt <= clk4mcnt + 1;
		end if;
	end process;

	process (clk50m,RSTN)
	begin
		if (RSTN = '0') then
			clk1scntlow <= (others => '0');
		elsif (clk50m'event and clk50m = '1') then
			if (clk1scntlow = 49999) then
				clk1scntlow <= (others => '0');
			else
				clk1scntlow <= clk1scntlow + 1;
			end if;
		end if;
	end process;

	process (clk50m,RSTN)
	begin
		if (RSTN = '0') then
			clk1scnthigh <= (others => '0');
			clk1sout_i <= '0';
		elsif (clk50m'event and clk50m = '1') then
			if (clk1scntlow = 49999) then
				if (clk1scnthigh = 499) then
					clk1scnthigh <= (others => '0');
					clk1sout_i <= not clk1sout_i;
				else
					clk1scnthigh <= clk1scnthigh + 1;
				end if;
			end if;
		end if;
	end process;


	CLK100MOUT  <= clk100m;
	CLK100M_DI  <= clk100m_dly;
	CLK50MOUT   <= clk50m;
	CLK25MOUT   <= clk25m_mk2 when (MK2MODE = '1') else clk25m_p6;
	CLK16MOUT   <= clk16m;
	CLK14MOUT   <= clk14m;
	CLK4MOUT    <= clk4mcnt(1);
	CLK4MCNTOUT <= clk4mcnt;
	CLK1SOUT    <= clk1sout_i;

	LOCK_PLL    <= lock_14m and lock_25m_mk2 and lock_25m_p6 and lock_16m;

end RTL;
