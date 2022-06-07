--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity INTWAITGEN is
	port (
		A			: in  std_logic_vector(15 downto 0);
		DI			: in  std_logic_vector(7 downto 0);
		RAMDI		: in  std_logic_vector(7 downto 0);
		M1N			: in  std_logic;
		MREQN		: in  std_logic;
		IORQN		: in  std_logic;
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		RFSHN		: in  std_logic;
		INT8049N	: in  std_logic;
		INTJOY7N	: in  std_logic;
		CGSWN		: in  std_logic;
		FDINT		: in  std_logic;
		MK2MODE		: in  std_logic;
		MEM128K		: in  std_logic;
		EXKANJIENB	: in  std_logic;
		CLK4MCNT	: in  std_logic_vector(1 downto 0);
		CLK16M		: in  std_logic;
		RSTN		: in  std_logic;
		BASICROMCSN	: out std_logic;
		VO_KNROMCSN	: out std_logic;
		SLOT2ROMCSN	: out std_logic;
		SLOT3ROMCSN	: out std_logic;
		INTRAMCSN	: out std_logic;
		EXTRAMCSN	: out std_logic;
		CGROMCSN	: out std_logic;
		SDRAMRDN	: out std_logic;
		SDRAMWRN	: out std_logic;
		PORT_B0H	: out std_logic_vector(3 downto 0);
		PORT_B1H	: out std_logic_vector(3 downto 0);
		PORT_B2H	: out std_logic_vector(3 downto 0);
		PORT_C0H	: out std_logic_vector(3 downto 0);
		PORT_C1H	: out std_logic_vector(3 downto 0);
		PORT_C2H	: out std_logic_vector(3 downto 0);
		PORT_F3H	: out std_logic_vector(7 downto 0);
		PORT_F4H	: out std_logic_vector(7 downto 0);
		PORT_F5H	: out std_logic_vector(7 downto 0);
		PORT_F7H	: out std_logic_vector(7 downto 0);
		DO_PORT_B0H	: out std_logic_vector(7 downto 0);
		DO_PORT_C0H	: out std_logic_vector(7 downto 0);
		DO_PORT_F0H	: out std_logic_vector(7 downto 0);
		EXKANJIADDENB	: out std_logic;
		EXKANJIADD	: out std_logic_vector(16 downto 0);
		INT8049SETN	: out std_logic;
		INTJOY7SETN	: out std_logic;
		INTTIM2SETN	: out std_logic;
		WAITN		: out std_logic;
		INTN		: out std_logic
	);
end INTWAITGEN;

architecture RTL of INTWAITGEN is

	signal waitn_i		: std_logic;
	signal waitn_f1		: std_logic;

	signal wait2n_i		: std_logic;
	signal wait2n_f1	: std_logic;

	signal port_b0_reg	: std_logic_vector(3 downto 0);
	signal port_b1_reg	: std_logic_vector(3 downto 0);
	signal port_b2_reg	: std_logic_vector(3 downto 0);
	signal port_b3_reg	: std_logic_vector(3 downto 0);
	signal port_b2_i	: std_logic_vector(3 downto 0);
	signal port_c0_reg	: std_logic_vector(3 downto 0);
	signal port_c1_reg	: std_logic_vector(3 downto 0);
	signal port_c2_reg	: std_logic_vector(3 downto 0);
	signal port_c3_reg	: std_logic_vector(3 downto 0);
	signal port_c2_i	: std_logic_vector(3 downto 0);

	signal a_low		: std_logic_vector(3 downto 0);

	signal port_f0_reg	: std_logic_vector(7 downto 0);
	signal port_f1_reg	: std_logic_vector(7 downto 0);
	signal port_f2_reg	: std_logic_vector(7 downto 0);
	signal port_f3_reg	: std_logic_vector(7 downto 0);
	signal port_f4_reg	: std_logic_vector(7 downto 0);
	signal port_f5_reg	: std_logic_vector(7 downto 0);
	signal port_f6_reg	: std_logic_vector(7 downto 0);
	signal port_f7_reg	: std_logic_vector(7 downto 0);
	signal port_f8_reg	: std_logic_vector(7 downto 0);

	signal wrn_f1		: std_logic;
	signal wrn_f2		: std_logic;

	signal basicromcsn_i	: std_logic;
	signal vo_knromcsn_i	: std_logic;
	signal slot2romcsn_i	: std_logic;
	signal slot3romcsn_i	: std_logic;
	signal intram_r_csn_i	: std_logic;
	signal extram_r_csn_i	: std_logic;
	signal intram_w_csn_i	: std_logic;
	signal extram_w_csn_i	: std_logic;
	signal cgromcsn_i		: std_logic;

	signal flag_ltn			: std_logic_vector(2 downto 0);
	signal flag_i_n			: std_logic_vector(2 downto 0);
	signal int8049setn_i	: std_logic;
	signal intjoy7setn_i	: std_logic;
	signal inttim2setn_i	: std_logic;

	signal inttim2n		: std_logic;
	signal inttimmk2n	: std_logic;
	signal timcnt		: std_logic_vector(14 downto 0);
	signal timcntlow	: std_logic_vector(12 downto 0);
	signal timcnthigh	: std_logic_vector(7 downto 0);
	signal tim2clr		: std_logic;
	signal tim2clr_f1	: std_logic;
	signal tim2clr_r	: std_logic;

	signal exkanjioe	: std_logic;
	signal exkanjiadlt	: std_logic_vector(15 downto 0);

begin

-- wait generate
	process (CLK16M,RSTN)
	begin
		if (RSTN = '0') then
			waitn_i  <= '1';
			waitn_f1 <= '1';
		elsif (CLK16M'event and CLK16M = '1') then
			if (CLK4MCNT = "11") then
				if    (waitn_i = '0') then
					waitn_i  <= '1';
					waitn_f1 <= '1';
				elsif (waitn_f1 = '0') then
					waitn_i  <= '0';
					waitn_f1 <= '1';
				elsif (M1N = '0' and MREQN = '0') then								-- M1 memory access
					waitn_i  <= '0';
					waitn_f1 <= '1';
				elsif (MREQN = '0' and RDN = '0' and A(15) = '0') then				-- memory read
					waitn_i  <= '0';
					waitn_f1 <= '1';
				elsif (IORQN = '0' and RDN = '0' and A(7 downto 4) = "1010") then	-- I/O read
					waitn_i  <= '1';
					waitn_f1 <= '0';
				else
					waitn_i  <= '1';
					waitn_f1 <= '1';
				end if;
			end if;
		end if;
	end process;


-- wait generate for mk2
	process (CLK16M,RSTN)
	begin
		if (RSTN = '0') then
			wait2n_i  <= '1';
			wait2n_f1 <= '1';
		elsif (CLK16M'event and CLK16M = '1') then
			if (CLK4MCNT = "11") then
				if    (wait2n_i = '0') then
					wait2n_i  <= '1';
					wait2n_f1 <= '1';
				elsif (wait2n_f1 = '0') then
					wait2n_i  <= '0';
					wait2n_f1 <= '1';
				elsif (M1N = '0' and MREQN = '0') then							-- M1 memory access
					if (port_f3_reg(7) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (MREQN = '0' and RDN = '0' and cgromcsn_i = '0') then		-- cgrom read
					if (port_f8_reg(7) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (MREQN = '0' and RDN = '0' and basicromcsn_i = '0') then	-- basicrom read
					if (port_f3_reg(6) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (MREQN = '0' and RDN = '0' and vo_knromcsn_i = '0') then	-- voice/kanjirom read
					if (port_f3_reg(6) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (MREQN = '0' and RDN = '0' and slot2romcsn_i = '0') then	-- slot2rom read
					if (port_f3_reg(6) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (MREQN = '0' and RDN = '0' and slot3romcsn_i = '0') then	-- slot3rom read
					if (port_f3_reg(6) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (MREQN = '0' and RDN = '0' and intram_r_csn_i = '0') then	-- intram read
					if (port_f3_reg(5) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (MREQN = '0' and RDN = '0' and extram_r_csn_i = '0') then	-- extram read
					if (port_f3_reg(5) = '1') then
						wait2n_i  <= '0';
						wait2n_f1 <= '1';
					else
						wait2n_i  <= '1';
						wait2n_f1 <= '1';
					end if;
				elsif (IORQN = '0' and RDN = '0' and A(7 downto 4) = "1010") then	-- I/O read
					wait2n_i  <= '1';
					wait2n_f1 <= '0';
				else
					wait2n_i  <= '1';
					wait2n_f1 <= '1';
				end if;
			end if;
		end if;
	end process;

	WAITN <= wait2n_i when (MK2MODE = '1') else waitn_i;


-- I/O port B0H
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_b0_reg <= (others => '1');
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '0') then
				if (A(7 downto 4) = "1011") then
					if (IORQN = '0' and (RDN = '0' or WRN = '0')) then
						port_b0_reg <= DI(3 downto 0);
					end if;
				end if;
			else
				if (A(7 downto 3) = "10110" and A(1 downto 0) = "00") then
					if (IORQN = '0' and WRN = '0') then
						port_b0_reg <= DI(3 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	PORT_B0H <= port_b0_reg;

-- I/O port B1H (write)
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_b1_reg <= "1111";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 3) = "10110" and A(1 downto 0) = "01") then
				if (IORQN = '0' and WRN = '0') then
					port_b1_reg <= DI(3 downto 0);
				end if;
			end if;
		end if;
	end process;

	PORT_B1H <=	port_b1_reg;

-- I/O port B2H (write)
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_b2_reg <= "1111";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 3) = "10110" and A(1 downto 0) = "10") then
				if (IORQN = '0' and WRN = '0') then
					port_b2_reg <= DI(3 downto 0);
				end if;
			end if;
		end if;
	end process;


-- I/O port B3H (write)
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_b3_reg <= "1111";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 3) = "10110" and A(1 downto 0) = "11") then
				if (IORQN = '0' and WRN = '0') then
					port_b3_reg <= DI(3 downto 0);
				end if;
			end if;
		end if;
	end process;

	port_b2_i(3) <= '1'   when (port_b3_reg(3) = '0') else port_b2_reg(3);
	port_b2_i(2) <= '1'   when (port_b3_reg(2) = '0') else port_b2_reg(2);
	port_b2_i(1) <= '1'   when (port_b3_reg(1) = '0') else port_b2_reg(1);
	port_b2_i(0) <= FDINT when (port_b3_reg(0) = '0') else '0';

	PORT_B2H <= port_b2_i;


	DO_PORT_B0H <=	("1111" & port_b2_i) when (MK2MODE = '1' and A(3) = '0' and A(1 downto 0) = "10") else
					"11111111";


-- I/O port C0H (write)
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_c0_reg <= "1111";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 3) = "11000" and A(1 downto 0) = "00") then
				if (IORQN = '0' and WRN = '0') then
					port_c0_reg <= DI(3 downto 0);
				end if;
			end if;
		end if;
	end process;

	PORT_C0H <=	port_c0_reg;

-- I/O port C1H (write)
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_c1_reg <= "1101";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 3) = "11000" and A(1 downto 0) = "01") then
				if (IORQN = '0' and WRN = '0') then
					port_c1_reg <= DI(3 downto 0);
				end if;
			end if;
		end if;
	end process;

	PORT_C1H <=	port_c1_reg;

-- I/O port C2H
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_c2_reg <= "1111";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 3) = "11000" and A(1 downto 0) = "10") then
				if (IORQN = '0' and WRN = '0') then
					port_c2_reg <= DI(3 downto 0);
				end if;
			end if;
		end if;
	end process;

-- I/O port C3H
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_c3_reg <= "1111";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 3) = "11000" and A(1 downto 0) = "11") then
				if (IORQN = '0' and WRN = '0') then
					port_c3_reg <= DI(3 downto 0);
				end if;
			end if;
		end if;
	end process;

	port_c2_i(3) <= '1' when (port_c3_reg(3) = '0') else port_c2_reg(3);
	port_c2_i(2) <= '1' when (port_c3_reg(2) = '0') else port_c2_reg(2);
	port_c2_i(1) <= port_c2_reg(1);
	port_c2_i(0) <= '1' when (port_c3_reg(0) = '0') else port_c2_reg(0);

	PORT_C2H <= port_c2_i;


	DO_PORT_C0H <=	("1111" & port_c2_i) when (MK2MODE = '1' and A(3) = '0' and A(1 downto 0) = "10") else
					"11111111";


	a_low <= A(3 downto 0);

-- I/O port F0H-F8H
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			port_f0_reg <= "01110001";
			port_f1_reg <= "11011101";
			port_f2_reg <= "01010000";
			port_f3_reg <= "11000010";
			port_f4_reg <= "00000000";
			port_f5_reg <= "00000000";
			port_f6_reg <= "00000011";
			port_f7_reg <= "00000110";
			port_f8_reg <= "11000011";
		elsif (CLK16M'event and CLK16M = '1') then
			if (MK2MODE = '1' and A(7 downto 4) = "1111") then
				if (IORQN = '0' and WRN = '0') then
					case a_low is
						when "0000" => port_f0_reg <= DI;
						when "0001" => port_f1_reg <= DI;
						when "0010" => port_f2_reg <= DI;
						when "0011" => port_f3_reg <= DI;
						when "0100" => port_f4_reg <= DI;
						when "0101" => port_f5_reg <= DI;
						when "0110" => port_f6_reg <= DI;
						when "0111" => port_f7_reg <= DI;
						when "1000" => port_f8_reg <= DI;
						when others => null;
					end case;
				end if;
			end if;
		end if;
	end process;

	PORT_F3H <= port_f3_reg;
	PORT_F4H <= port_f4_reg;
	PORT_F5H <= port_f5_reg;
	PORT_F7H <= port_f7_reg;


-- Expand KANJI-ROM port FCH-FFH
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			exkanjioe   <= '0';
			exkanjiadlt <= (others => '0');
		elsif (CLK16M'event and CLK16M = '1') then
			if (EXKANJIENB = '0') then
				exkanjioe   <= '0';
				exkanjiadlt <= (others => '0');
			elsif (IORQN = '0' and WRN = '0' and wrn_f1 = '1') then
				if (A(7 downto 0) = X"FC") then
					exkanjioe   <= '0';
					exkanjiadlt <= DI & A(15 downto 8);
				elsif (A(7 downto 0) = X"FF") then
					exkanjioe   <= not exkanjioe;
				end if;
			end if;
		end if;
	end process;

	EXKANJIADDENB <=
		'1' when (A(7 downto 0) = X"FD" and IORQN = '0' and RDN = '0' and EXKANJIENB = '1') else
		'1' when (A(7 downto 0) = X"FE" and IORQN = '0' and RDN = '0' and EXKANJIENB = '1') else
		'0';

	EXKANJIADD <=	(exkanjiadlt & "0") when (A(7 downto 0) = X"FD") else
					(exkanjiadlt & "1");

	DO_PORT_F0H <=	RAMDI       when (a_low = "1101" and EXKANJIENB = '1') else
					RAMDI       when (a_low = "1110" and EXKANJIENB = '1') else
					"11111111"  when (MK2MODE = '0') else
					port_f0_reg when (a_low = "0000") else
					port_f1_reg when (a_low = "0001") else
					port_f2_reg when (a_low = "0010") else
					port_f3_reg when (a_low = "0011") else
					port_f4_reg when (a_low = "0100") else
					port_f5_reg when (a_low = "0101") else
					port_f6_reg when (a_low = "0110") else
					port_f7_reg when (a_low = "0111") else
					port_f8_reg when (a_low = "1000") else
					"11111111";

-- write pulse delay
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			wrn_f1 <= '1';
			wrn_f2 <= '1';
		elsif (CLK16M'event and CLK16M = '1') then
			wrn_f1 <= WRN;
			wrn_f2 <= wrn_f1;
		end if;
	end process;

	basicromcsn_i <=
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"A") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"9") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"A") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"9") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"A") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"9") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"A") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"1") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"9") else
		'1';

	vo_knromcsn_i <=
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"C") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"B") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"C") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"B") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"C") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"B") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"5") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"C") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"2") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"6") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"B") else
		'1';

	slot3romcsn_i <=
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"9") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"A") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"9") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"A") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"9") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"A") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"9") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"3") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"A") else
		'1';

	slot2romcsn_i <=
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "000" and port_f0_reg(3 downto 0) = X"B") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "001" and port_f0_reg(3 downto 0) = X"C") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "010" and port_f0_reg(7 downto 4) = X"B") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "011" and port_f0_reg(7 downto 4) = X"C") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "100" and port_f1_reg(3 downto 0) = X"B") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "101" and port_f1_reg(3 downto 0) = X"C") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"7") else
		'0' when (WRN = '1' and A(15 downto 13) = "110" and port_f1_reg(7 downto 4) = X"B") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"4") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"8") else
		'0' when (WRN = '1' and A(15 downto 13) = "111" and port_f1_reg(7 downto 4) = X"C") else
		'1';

	intram_r_csn_i <=
		'0' when (WRN = '1' and A(15 downto 14) = "00" and port_f0_reg(3 downto 0) = X"D") else
		'0' when (WRN = '1' and A(15 downto 14) = "01" and port_f0_reg(7 downto 4) = X"D") else
		'0' when (WRN = '1' and A(15 downto 14) = "10" and port_f1_reg(3 downto 0) = X"D") else
		'0' when (WRN = '1' and A(15 downto 14) = "11" and port_f1_reg(7 downto 4) = X"D") else
		'1';

	extram_r_csn_i <=
		'1' when (MEM128K = '0') else
		'0' when (WRN = '1' and A(15 downto 14) = "00" and port_f0_reg(3 downto 0) = X"E") else
		'0' when (WRN = '1' and A(15 downto 14) = "01" and port_f0_reg(7 downto 4) = X"E") else
		'0' when (WRN = '1' and A(15 downto 14) = "10" and port_f1_reg(3 downto 0) = X"E") else
		'0' when (WRN = '1' and A(15 downto 14) = "11" and port_f1_reg(7 downto 4) = X"E") else
		'1';

	intram_w_csn_i <=
		'0' when (WRN = '0' and A(15 downto 14) = "00" and port_f2_reg(0) = '1') else
		'0' when (WRN = '0' and A(15 downto 14) = "01" and port_f2_reg(2) = '1') else
		'0' when (WRN = '0' and A(15 downto 14) = "10" and port_f2_reg(4) = '1') else
		'0' when (WRN = '0' and A(15 downto 14) = "11" and port_f2_reg(6) = '1') else
		'1';

	extram_w_csn_i <=
		'1' when (MEM128K = '0') else
		'0' when (WRN = '0' and A(15 downto 14) = "00" and port_f2_reg(1) = '1') else
		'0' when (WRN = '0' and A(15 downto 14) = "01" and port_f2_reg(3) = '1') else
		'0' when (WRN = '0' and A(15 downto 14) = "10" and port_f2_reg(5) = '1') else
		'0' when (WRN = '0' and A(15 downto 14) = "11" and port_f2_reg(7) = '1') else
		'1';

	cgromcsn_i <=
		'1' when (WRN   = '0') else
		'1' when (CGSWN = '1') else
		'1' when (port_f8_reg(6) = '0') else
		'1' when (port_f8_reg(5) = '0' and port_f8_reg(2) /= A(15) ) else
		'1' when (port_f8_reg(4) = '0' and port_f8_reg(1) /= A(14) ) else
		'1' when (port_f8_reg(3) = '0' and port_f8_reg(0) /= A(13) ) else
		'0';

	BASICROMCSN <= basicromcsn_i;
	VO_KNROMCSN <= vo_knromcsn_i;
	SLOT2ROMCSN <= slot2romcsn_i;
	SLOT3ROMCSN <= slot3romcsn_i;
	INTRAMCSN   <= intram_r_csn_i and intram_w_csn_i;
	EXTRAMCSN   <= extram_r_csn_i and extram_w_csn_i;
	CGROMCSN    <= cgromcsn_i;

	SDRAMRDN <=
		'0' when (basicromcsn_i  = '0' and MREQN = '0' and RDN = '0') else
		'0' when (vo_knromcsn_i  = '0' and MREQN = '0' and RDN = '0') else
		'0' when (slot2romcsn_i  = '0' and MREQN = '0' and RDN = '0') else
		'0' when (slot3romcsn_i  = '0' and MREQN = '0' and RDN = '0') else
		'0' when (intram_r_csn_i = '0' and MREQN = '0' and RDN = '0') else
		'0' when (extram_r_csn_i = '0' and MREQN = '0' and RDN = '0') else
		'0' when (cgromcsn_i     = '0' and MREQN = '0' and RDN = '0') else
		'1';

	SDRAMWRN <=
		'0' when (intram_w_csn_i = '0' and MREQN = '0' and WRN = '0' and wrn_f2 = '0') else
		'0' when (extram_w_csn_i = '0' and MREQN = '0' and WRN = '0' and wrn_f2 = '0') else
		'1';


-- Interrupt flag
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			flag_ltn <= "111";
		elsif (CLK16M'event and CLK16M = '1') then
			case flag_ltn is
				when "111" =>
					case flag_i_n is
						when "000"  => flag_ltn <= "011";
						when "001"  => flag_ltn <= "011";
						when "010"  => flag_ltn <= "011";
						when "011"  => flag_ltn <= "011";
						when "100"  => flag_ltn <= "101";
						when "101"  => flag_ltn <= "101";
						when "110"  => flag_ltn <= "110";
						when others => flag_ltn <= "111";
					end case;
				when "011" =>
					case flag_i_n is
						when "000"  => flag_ltn <= "011";
						when "001"  => flag_ltn <= "011";
						when "010"  => flag_ltn <= "011";
						when "011"  => flag_ltn <= "011";
						when "100"  => flag_ltn <= "101";
						when "101"  => flag_ltn <= "101";
						when "110"  => flag_ltn <= "110";
						when others => flag_ltn <= "111";
					end case;
				when "101" =>
					case flag_i_n is
						when "000"  => flag_ltn <= "101";
						when "001"  => flag_ltn <= "101";
						when "010"  => flag_ltn <= "011";
						when "011"  => flag_ltn <= "011";
						when "100"  => flag_ltn <= "101";
						when "101"  => flag_ltn <= "101";
						when "110"  => flag_ltn <= "110";
						when others => flag_ltn <= "111";
					end case;
				when "110" =>
					case flag_i_n is
						when "000"  => flag_ltn <= "110";
						when "001"  => flag_ltn <= "011";
						when "010"  => flag_ltn <= "110";
						when "011"  => flag_ltn <= "011";
						when "100"  => flag_ltn <= "110";
						when "101"  => flag_ltn <= "101";
						when "110"  => flag_ltn <= "110";
						when others => flag_ltn <= "111";
					end case;
				when others => flag_ltn <= "111";
			end case;
		end if;
	end process;

	flag_i_n(2) <=	INT8049N   when (MK2MODE = '1' and port_f3_reg(0) = '0') else
					INT8049N   when (MK2MODE = '0') else
					'1';
	flag_i_n(1) <=	INTJOY7N   when (MK2MODE = '1' and port_f3_reg(1) = '0') else
					'1';
	flag_i_n(0) <=	inttimmk2n when (MK2MODE = '1' and port_f3_reg(2) = '0') else
					inttim2n   when (MK2MODE = '0') else
					'1';

	int8049setn_i <=flag_ltn(2);
	intjoy7setn_i <=flag_ltn(1);
	inttim2setn_i <=flag_ltn(0);

	INT8049SETN  <= int8049setn_i;
	INTJOY7SETN  <= intjoy7setn_i;
	INTTIM2SETN  <= inttim2setn_i;

	INTN         <= int8049setn_i and intjoy7setn_i and inttim2setn_i;


-- 2ms timer
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			timcnt <= (others => '0');
		elsif (CLK16M'event and CLK16M = '1') then
			if (port_b0_reg(0) = '1') then
				timcnt <= (others => '0');
			else
				timcnt <= timcnt + 1;
			end if;
		end if;
	end process;

	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			inttim2n <= '1';
		elsif (CLK16M'event and CLK16M = '1') then
			if (port_b0_reg(0) = '1' or tim2clr_r = '1') then
				inttim2n <= '1';
			elsif (timcnt = "011111111111111") then
				inttim2n <= '0';
			end if;
		end if;
	end process;


	tim2clr <='0' when (inttim2setn_i = '0' and IORQN = '0' and M1N = '0') else '1';

	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			tim2clr_f1 <= '1';
		elsif (CLK16M'event and CLK16M = '1') then
			tim2clr_f1 <= tim2clr;
		end if;
	end process;

	tim2clr_r <= '1' when (tim2clr = '1' and tim2clr_f1 = '0') else '0';


-- timer for mk2
	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			timcntlow <= (others => '0');
		elsif (CLK16M'event and CLK16M = '1') then
			if (port_b0_reg(0) = '1') then
				timcntlow <= (others => '0');
			else
				timcntlow <= timcntlow + 1;
			end if;
		end if;
	end process;

	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			timcnthigh <= (others => '0');
		elsif (CLK16M'event and CLK16M = '1') then
			if (port_b0_reg(0) = '1') then
				timcnthigh <= (others => '0');
			elsif (timcntlow = "1" & X"FFF") then
				if (timcnthigh = port_f6_reg) then
					timcnthigh <= (others => '0');
				else
					timcnthigh <= timcnthigh + 1;
				end if;
			end if;
		end if;
	end process;

	process (CLK16M,RSTN)
	begin
		if (rstn = '0') then
			inttimmk2n <= '1';
		elsif (CLK16M'event and CLK16M = '1') then
			if (port_b0_reg(0) = '1' or tim2clr_r = '1') then
				inttimmk2n <= '1';
			elsif (timcntlow = "1" & X"FFF" and timcnthigh = port_f6_reg) then
				inttimmk2n <= '0';
			end if;
		end if;
	end process;


end RTL;
