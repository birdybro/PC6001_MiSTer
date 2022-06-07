--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity PIO8255 is
	port (
		A1			: in  std_logic;
		A0			: in  std_logic;
		DI			: in  std_logic_vector(7 downto 0);
		CSN			: in  std_logic;
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		PAI			: in  std_logic_vector(7 downto 0);
		PC4_STBN	: in  std_logic;
		PC6_ACKN	: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(7 downto 0);
		PAO			: out std_logic_vector(7 downto 0);
		PBO			: out std_logic_vector(7 downto 0);
		PCO			: out std_logic_vector(2 downto 0);
		PC3_INTR	: out std_logic;
		PC5_IBF		: out std_logic;
		PC7_OBFN	: out std_logic;
		MONOUT		: out std_logic_vector(8 downto 0)
	);
end PIO8255;

architecture RTL of PIO8255 is

	signal port_a	: std_logic_vector(7 downto 0);
	signal port_b	: std_logic_vector(7 downto 0);
	signal port_c	: std_logic_vector(7 downto 0);
	signal port_ao	: std_logic_vector(7 downto 0);

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

	signal obfn		: std_logic;
	signal ackn		: std_logic;
	signal ibf		: std_logic;
	signal stbn		: std_logic;
	signal intr		: std_logic;

	signal inte1	: std_logic;
	signal inte2	: std_logic;

begin

-- RDN/WRN/DI/A/CS latch
	process (CLK,RSTN)
	begin
		if (rstn = '0') then
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
		if (rstn = '0') then
			do_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (csn_f2 = '0' and rdn_f1 = '0') then
				if    (a_f2 = "00") then
					do_i <= port_ao;
				elsif (a_f2 = "01") then
					do_i <= port_b;
				elsif (a_f2 = "10") then
					do_i <= port_c;
				elsif (a_f2 = "11") then
					do_i <= port_c;
				else
					do_i <= (others => '0');
				end if;
			end if;
		end if;
	end process;


-- data input
	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			port_a <= (others => '0');
			port_b <= (others => '0');
			port_c <= "10000000";
		elsif (CLK'event and CLK = '1') then
			if (csn_f2 = '0' and wrn_r = '1') then
				if    (a_f2 = "00") then
					port_a <= di_f2;
				elsif (a_f2 = "01") then
					port_b <= di_f2;
				elsif (a_f2 = "10") then
					port_c(2 downto 0) <= di_f2(2 downto 0);
				else
					case di_f2 is
						when X"00"  => port_c(0) <= '0';
						when X"01"  => port_c(0) <= '1';
						when X"02"  => port_c(1) <= '0';
						when X"03"  => port_c(1) <= '1';
						when X"04"  => port_c(2) <= '0';
						when X"05"  => port_c(2) <= '1';
						when X"08"  => port_c(4) <= '0';	-- INTE2
						when X"09"  => port_c(4) <= '1';	-- INTE2
						when X"0C"  => port_c(6) <= '0';	-- INTE1
						when X"0D"  => port_c(6) <= '1';	-- INTE1
						when others => null;
					end case;
				end if;
			end if;

		-- OBF (PC7)
			if (csn_f2 = '0' and wrn_r = '1' and a_f2 = "00") then
				port_c(7) <= '0';
			elsif (ackn = '0') then
				port_c(7) <= '1';
			end if;

		-- IBF (PC5)
			if (stbn = '0') then
				port_c(5) <= '1';
			elsif (csn_f2 = '0' and rdn_r = '1' and a_f2 = "00") then
				port_c(5) <= '0';
			end if;

		-- INTR (PC3)
			if    (
				ibf  = '1' and inte2 = '1' and stbn = '1' and
				not (csn_f2 = '0' and rdn_f1 = '0' and a_f2 = "00")
			) then

				port_c(3) <= '1';

			elsif (
				obfn = '1' and inte1 = '1' and ackn = '1' and
				not (csn_f2 = '0' and wrn_f1 = '0' and a_f2 = "00")
			) then

				port_c(3) <= '1';

			else
				port_c(3) <= '0';
			end if;

		end if;
	end process;

-- data output
	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			port_ao <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (stbn = '0') then
				port_ao <= PAI;
			end if;
		end if;
	end process;


	ackn  <= PC6_ACKN;
	stbn  <= PC4_STBN;

	obfn  <= port_c(7);
	inte1 <= port_c(6);
	ibf   <= port_c(5);
	inte2 <= port_c(4);
	intr  <= port_c(3);

	PC7_OBFN <= obfn;
	PC5_IBF  <= ibf;
	PC3_INTR <= intr;

	PAO <= port_a;
	PBO <= port_b;
	PCO <= port_c(2 downto 0);

	DO <= do_i;

	MONOUT <= intr & inte1 & inte2 & ackn & obfn & csn_f2 & wrn_f1 & a_f2;

end RTL;
