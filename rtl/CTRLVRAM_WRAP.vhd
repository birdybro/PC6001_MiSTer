--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity CTRLVRAM_WRAP is
	port (
		ADDA		: in  std_logic_vector(9 downto 0);
		DATA		: in  std_logic_vector(7 downto 0);
		RDAN		: in  std_logic;
		WRAN		: in  std_logic;
		ADDB		: in  std_logic_vector(9 downto 0);
		RDBN		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		QA			: out std_logic_vector(7 downto 0);
		QB			: out std_logic_vector(7 downto 0)
	);
end CTRLVRAM_WRAP;

architecture RTL of CTRLVRAM_WRAP is

	component DDPRAM_1024W8B is
		port (
			address_a	: in  std_logic_vector(9 downto 0);
			address_b	: in  std_logic_vector(9 downto 0);
			data_a		: in  std_logic_vector(7 downto 0);
			data_b		: in  std_logic_vector(7 downto 0);
			wren_a		: in  std_logic;
			wren_b		: in  std_logic;
			aclr		: in  std_logic;
			clock		: in  std_logic;
			q_a			: out std_logic_vector(7 downto 0);
			q_b			: out std_logic_vector(7 downto 0)
		);
	end component;

	signal add_a	: std_logic_vector(9 downto 0);
	signal add_b	: std_logic_vector(9 downto 0);
	signal qa_i		: std_logic_vector(7 downto 0);
	signal qb_i		: std_logic_vector(7 downto 0);

	signal rdan_f1	: std_logic;
	signal rdan_f2	: std_logic;
	signal rdbn_f1	: std_logic;
	signal rdbn_f2	: std_logic;

	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;
	signal wrn_f3	: std_logic;

	signal wren		: std_logic;
	signal aclr		: std_logic;

begin

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdan_f1 <= '1';
			rdan_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			rdan_f1 <= RDAN;
			rdan_f2 <= rdan_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdbn_f1 <= '1';
			rdbn_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			rdbn_f1 <= RDBN;
			rdbn_f2 <= rdbn_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			wrn_f1 <= '1';
			wrn_f2 <= '1';
			wrn_f3 <= '1';
		elsif (CLK'event and CLK = '1') then
			wrn_f1 <= WRAN;
			wrn_f2 <= wrn_f1;
			wrn_f3 <= wrn_f2;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			add_a <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (wrn_f1 = '0' and wrn_f2 = '1') then
				add_a <= ADDA;
			elsif (rdan_f1 = '0' and rdan_f2 = '1') then
				add_a <= ADDA;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			add_b <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (rdbn_f1 = '0' and rdbn_f2 = '1') then
				add_b <= ADDB;
			end if;
		end if;
	end process;

	aclr <= not RSTN;

	wren <= '1' when (wrn_f2 = '0' and wrn_f3 = '1') else '0';


	U_DDPRAM_1024W8B : DDPRAM_1024W8B
	port map (
		address_a	=> add_a,
		address_b	=> add_b,
		data_a		=> DATA,
		data_b		=> (others => '0'),
		wren_a		=> wren,
		wren_b		=> '0',
		aclr		=> aclr,
		clock		=> CLK,
		q_a			=> qa_i,
		q_b			=> qb_i
	);

	QA <= qa_i;
	QB <= qb_i;

end RTL;
