--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity CTRLROM_WRAP is
	port (
		ADDRESS	: in  std_logic_vector(13 downto 0);
		DATA	: in  std_logic_vector(7 downto 0);
		RDN		: in  std_logic;
		WRN		: in  std_logic;
		CLK		: in  std_logic;
		RSTN	: in  std_logic;
		Q		: out std_logic_vector(7 downto 0)
	);
end CTRLROM_WRAP;

architecture RTL of CTRLROM_WRAP is

	component CTRLROM is
		port (
			aclr	: in  std_logic;
			address	: in  std_logic_vector(13 downto 0);
			clock	: in  std_logic;
			data	: in  std_logic_vector(7 downto 0);
			wren	: in  std_logic;
			q		: out std_logic_vector(7 downto 0)
		);
	end component;

	signal add		: std_logic_vector(13 downto 0);
	signal q_i		: std_logic_vector(7 downto 0);

	signal rdn_i	: std_logic;
	signal rdn_f1	: std_logic;
	signal rdn_f2	: std_logic;

	signal wrn_i	: std_logic;
	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;
	signal wrn_f3	: std_logic;

	signal wren		: std_logic;
	signal aclr		: std_logic;

begin

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
			wrn_f3 <= '1';
		elsif (CLK'event and CLK = '1') then
			wrn_f1 <= WRN;
			wrn_f2 <= wrn_f1;
			wrn_f3 <= wrn_f2;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			add <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if    (wrn_f1 = '0' and wrn_f2 = '1') then
				add <= ADDRESS;
			elsif (rdn_f1 = '0' and rdn_f2 = '1') then
				add <= ADDRESS;
			end if;
		end if;
	end process;

	aclr <= not RSTN;

	wren <= '1' when (wrn_f2 = '0' and wrn_f3 = '1') else '0';

	U_CTRLROM : CTRLROM
	port map (
		aclr	=> aclr,
		address	=> add,
		clock	=> CLK,
		data    => DATA,
		wren    => wren,
		q		=> q_i
	);

	Q <= q_i;

end RTL;
