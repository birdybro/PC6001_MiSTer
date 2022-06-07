--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity PIO8255M1 is
	port (
		A1			: in  std_logic;
		A0			: in  std_logic;
		DI			: in  std_logic_vector(7 downto 0);
		CSN			: in  std_logic;
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		PAI			: in  std_logic_vector(7 downto 0);
		PCI			: in  std_logic_vector(3 downto 0);
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(7 downto 0);
		PBO			: out std_logic_vector(7 downto 0);
		PCO			: out std_logic_vector(3 downto 0)
	);
end PIO8255M1;

architecture RTL of PIO8255M1 is

	signal port_bo	: std_logic_vector(7 downto 0);
	signal port_co	: std_logic_vector(3 downto 0);

	signal do_i		: std_logic_vector(7 downto 0);

	signal rdn_f1	: std_logic;
	signal rdn_f2	: std_logic;
	signal rdn_r	: std_logic;
	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;
	signal wrn_r	: std_logic;
	signal di_f1	: std_logic_vector(7 downto 0);
	signal di_f2	: std_logic_vector(7 downto 0);
	signal a_f1		: std_logic_vector(1 downto 0);
	signal a_f2		: std_logic_vector(1 downto 0);
	signal csn_f1	: std_logic;
	signal csn_f2	: std_logic;

begin

-- RDN/WRN/DI/A/CS latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdn_f1 <= '1';
			rdn_f2 <= '1';
			wrn_f1 <= '1';
			wrn_f2 <= '1';
			di_f1  <= (others => '0');
			di_f2  <= (others => '0');
			a_f1   <= (others => '0');
			a_f2   <= (others => '0');
			csn_f1 <= '1';
			csn_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			rdn_f1 <= RDN;
			rdn_f2 <= rdn_f1;
			wrn_f1 <= WRN;
			wrn_f2 <= wrn_f1;
			di_f1  <= DI;
			di_f2  <= di_f1;
			a_f1   <= A1 & A0;
			a_f2   <= a_f1;
			csn_f1 <= CSN;
			csn_f2 <= csn_f1;
		end if;
	end process;

	rdn_r <= '1' when (rdn_f1 = '1' and rdn_f2 = '0') else '0';
	wrn_r <= '1' when (wrn_f1 = '1' and wrn_f2 = '0') else '0';

-- data output
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			do_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (csn_f2 = '0' and rdn_f1 = '0') then
				if    (a_f2 = "00") then
					do_i <= PAI;
				elsif (a_f2 = "01") then
					do_i <= port_bo;
				elsif (a_f2 = "10") then
					do_i <= port_co & PCI;
				elsif (a_f2 = "11") then
					do_i <= port_co & PCI;
				else
					do_i <= (others => '0');
				end if;
			end if;
		end if;
	end process;


-- data input
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			port_bo <= (others => '0');
			port_co <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (csn_f2 = '0' and wrn_r = '1') then
				if    (a_f2 = "00") then
					null;
				elsif (a_f2 = "01") then
					port_bo <= di_f2;
				elsif (a_f2 = "10") then
					port_co <= di_f2(7 downto 4);
				else
					case di_f2 is
						when X"08"  => port_co(0) <= '0';
						when X"09"  => port_co(0) <= '1';
						when X"0A"  => port_co(1) <= '0';
						when X"0B"  => port_co(1) <= '1';
						when X"0C"  => port_co(2) <= '0';
						when X"0D"  => port_co(2) <= '1';
						when X"0E"  => port_co(3) <= '0';
						when X"0F"  => port_co(3) <= '1';
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;


	PBO <= port_bo;
	PCO <= port_co;

	DO <= do_i;

end RTL;
