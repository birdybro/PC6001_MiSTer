--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FDC765 is
	port (
		A0			: in  std_logic;
		DI			: in  std_logic_vector(7 downto 0);
		CSN			: in  std_logic;
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		FDD0		: in  std_logic_vector(2 downto 0);
		FDD1		: in  std_logic_vector(2 downto 0);
		FLOPPY0		: in  std_logic_vector(3 downto 0);
		FLOPPY1		: in  std_logic_vector(3 downto 0);
		ST0			: in  std_logic_vector(7 downto 0);
		ST1			: in  std_logic_vector(7 downto 0);
		ST2			: in  std_logic_vector(7 downto 0);
		RST_C		: in  std_logic_vector(7 downto 0);
		RST_H		: in  std_logic_vector(7 downto 0);
		RST_R		: in  std_logic_vector(7 downto 0);
		RST_N		: in  std_logic_vector(7 downto 0);
		ENDTRG		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(7 downto 0);
		FDINT		: out std_logic;
		COMMAND		: out std_logic_vector(4 downto 0);
		COMEND		: out std_logic;
		MT			: out std_logic;
		MF			: out std_logic;
		SK			: out std_logic;
		DNUM		: out std_logic_vector(1 downto 0);
		HNUM		: out std_logic;
		IDRC		: out std_logic_vector(7 downto 0);
		IDRH		: out std_logic_vector(7 downto 0);
		IDRR		: out std_logic_vector(7 downto 0);
		IDRN		: out std_logic_vector(7 downto 0);
		EOT			: out std_logic_vector(7 downto 0);
		GPL			: out std_logic_vector(7 downto 0);
		DTL			: out std_logic_vector(7 downto 0);
		CNUM0		: out std_logic_vector(7 downto 0);
		CNUM1		: out std_logic_vector(7 downto 0);
		FDCACT		: out std_logic;
		FDCCNUM		: out std_logic_vector(7 downto 0);
		FDCSNUM		: out std_logic_vector(7 downto 0);
		MONOUT		: out std_logic_vector(7 downto 0)
	);
end FDC765;

architecture RTL of FDC765 is

	signal rdn_f1	: std_logic;
	signal rdn_f2	: std_logic;
	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;

	signal rdn_f	: std_logic;
	signal rdn_f_f1	: std_logic;
	signal wrn_f	: std_logic;

	signal do_i		: std_logic_vector(7 downto 0);

	signal reg_datain	: std_logic_vector(7 downto 0);	-- Data Register for input
	signal reg_dataout	: std_logic_vector(7 downto 0);	-- Data Register for output

	signal data_r		: std_logic;
	signal data_r_f1	: std_logic;
	signal data_r_f2	: std_logic;
	signal data_w		: std_logic;
	signal data_w_f1	: std_logic;
	signal data_w_f2	: std_logic;

	signal reg_db		: std_logic_vector(3 downto 0);	-- FD#n busy
	signal reg_cb		: std_logic;					-- FDC busy
	signal reg_ndm		: std_logic;					-- Non-DMA MODE
	signal reg_dio		: std_logic;					-- Data Input/Output
	signal reg_rqm		: std_logic;					-- Request for Master

	signal fdint_i		: std_logic;

	signal endtrg_f1	: std_logic;
	signal endtrg_f2	: std_logic;

	signal phase		: std_logic_vector(1 downto 0);
		-- 00:command ready
		-- 01:command phase
		-- 10:execute phase
		-- 11:result phase

	signal comend_i	: std_logic;
	signal compat	: std_logic_vector(4 downto 0);
	signal comnum	: std_logic_vector(3 downto 0);
	signal rstnum	: std_logic_vector(3 downto 0);
	signal comcnt	: std_logic_vector(3 downto 0);
	signal rstcnt	: std_logic_vector(3 downto 0);

	type com_type is array (8 downto 0) of std_logic_vector(7 downto 0);
	signal reg_com	: com_type;

	type rst_type is array (6 downto 0) of std_logic_vector(7 downto 0);
	signal reg_rst	: rst_type;

	type cnum_type is array (3 downto 0) of std_logic_vector(7 downto 0);
	signal c_num	: cnum_type;

	signal com_hd		: std_logic;
	signal com_us		: std_logic_vector(1 downto 0);

	signal rst_st0		: std_logic_vector(7 downto 0);
	signal rst_st3		: std_logic_vector(7 downto 0);
	signal rst_pcn		: std_logic_vector(7 downto 0);

	signal nouse		: std_logic;

	signal maxtrack		: std_logic_vector(7 downto 0);

	signal w_pro		: std_logic;

begin

-- RDN/WRN latch
	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			rdn_f1 <= '1';
			rdn_f2 <= '1';
			wrn_f1 <= '1';
			wrn_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			rdn_f1 <= RDN or CSN;
			rdn_f2 <= rdn_f1;
			wrn_f1 <= WRN or CSN;
			wrn_f2 <= wrn_f1;
		end if;
	end process;

	rdn_f <= '1' when (rdn_f1 = '0' and rdn_f2 = '1') else '0';
	wrn_f <= '1' when (wrn_f1 = '0' and wrn_f2 = '1') else '0';

-- data output

	data_r <= '1' when (rdn_f = '1' and A0 = '1' and reg_rqm = '1' and reg_dio = '1') else '0';

	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			rdn_f_f1  <= '0';
			data_r_f1 <= '0';
			data_r_f2 <= '0';
		elsif (CLK'event and CLK = '1') then
			rdn_f_f1  <= rdn_f;
			data_r_f1 <= data_r;
			data_r_f2 <= data_r_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			do_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (rdn_f_f1 = '1') then
				if (A0 = '1') then
					do_i <= reg_dataout;
				else
					do_i <= reg_rqm & reg_dio & reg_ndm & reg_cb & reg_db;
				end if;
			end if;
		end if;
	end process;

	DO <= do_i;


	reg_ndm <= '0';	-- Non-DMA mode is no support


-- data input

	data_w <= '1' when (wrn_f = '1' and A0 = '1' and reg_rqm = '1' and reg_dio = '0') else '0';

	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			data_w_f1 <= '0';
			data_w_f2 <= '0';
		elsif (CLK'event and CLK = '1') then
			data_w_f1 <= data_w;
			data_w_f2 <= data_w_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			reg_datain <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (data_w_f1 = '1') then
				reg_datain <= DI;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			endtrg_f1 <= '0';
			endtrg_f2 <= '0';
		elsif (CLK'event and CLK = '1') then
			endtrg_f1 <= ENDTRG;
			endtrg_f2 <= endtrg_f1;
		end if;
	end process;

-- phase control
	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			phase   <= "00";
			reg_db  <= "0000";
			reg_cb  <= '0';
			reg_dio <= '0';
			reg_rqm <= '0';
			fdint_i <= '0';
			comend_i<= '0';
			compat  <= "00000";
			comnum  <= X"0";
			rstnum  <= X"0";
			comcnt	<= X"0";
			rstcnt	<= X"0";
			reg_com <= (others => (others => '0'));
			reg_dataout <= (others => '0');
			c_num   <= (others => (others => '0'));
			rst_st0 <= (others => '0');
			rst_st3 <= (others => '0');
			rst_pcn <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if    (phase = "01") then	-- command phase

				rstcnt  <= X"0";
				if (compat = "00000") then
					comcnt <= X"1";
					reg_com(0) <= reg_datain;

					case reg_datain(4 downto 0) is
						when "00110" =>			-- Read Data
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when "01100" =>			-- Read Deleted Data
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when "00010" =>			-- Read Diagnostic
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when "01010" =>			-- Read ID
							compat <= reg_datain(4 downto 0);
							comnum <= X"2";
							rstnum <= X"7";
						when "00101" =>			-- Write Data
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when "01001" =>			-- Write Deleted Data
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when "01101" =>			-- Write ID
							compat <= reg_datain(4 downto 0);
							comnum <= X"6";
							rstnum <= X"7";
						when "00011" =>			-- Specify
							compat <= reg_datain(4 downto 0);
							comnum <= X"3";
							rstnum <= X"0";
						when "01000" =>			-- Sense Interrupt Status
							compat <= reg_datain(4 downto 0);
							comnum <= X"1";
							rstnum <= X"2";
						when "00100" =>			-- Sense Device Status
							compat <= reg_datain(4 downto 0);
							comnum <= X"2";
							rstnum <= X"1";
						when "00111" =>			-- Recalibrate
							compat <= reg_datain(4 downto 0);
							comnum <= X"2";
							rstnum <= X"0";
						when "01111" =>			-- Seek
							compat <= reg_datain(4 downto 0);
							comnum <= X"3";
							rstnum <= X"0";
						when "10001" =>			-- Scan Equal
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when "11001" =>			-- Scan Low or Equal
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when "11101" =>			-- Scan High or Equal
							compat <= reg_datain(4 downto 0);
							comnum <= X"9";
							rstnum <= X"7";
						when others  => 		-- Invalid
							compat <= "11111";
							comnum <= X"1";
							rstnum <= X"1";
					end case;

				elsif (comnum = comcnt) then
					phase   <= "10";
					reg_rqm <= '0';
					reg_dio <= '0';
				elsif (data_w_f2 = '1') then
					reg_com(conv_integer(comcnt)) <= reg_datain;
					comcnt  <= comcnt + 1;
					reg_rqm <= '0';
					reg_dio <= '0';
				else
					reg_rqm <= '1';
					reg_dio <= '0';
				end if;

			elsif (phase = "10") then	-- execute phase

				rstcnt  <= X"0";
				case compat is
					when "00011" =>			-- Specify
						phase   <= "11";
						reg_rqm <= '0';
						reg_dio <= '0';
					when "01000" =>			-- Sense Interrupt Status
						phase   <= "11";
						reg_rqm <= '0';
						reg_dio <= '1';
					when "00100" =>			-- Sense Device Status
						phase   <= "11";
						reg_rqm <= '0';
						reg_dio <= '1';

				--		if (nouse = '1') then
				--		else
							rst_st3(7) <= '1';
							rst_st3(6) <= w_pro;
							rst_st3(5) <= '1';
							if (c_num(conv_integer(com_us)) = 0) then
								rst_st3(4) <= '1';
							else
								rst_st3(4) <= '0';
							end if;
							rst_st3(3) <= '1';
							rst_st3(2) <= com_hd;
							rst_st3(1 downto 0) <= com_us;
				--		end if;

					when "00111" =>			-- Recalibrate
						phase   <= "11";
						reg_rqm <= '0';
						reg_dio <= '1';
						fdint_i <= '1';

						if (nouse = '1') then
							rst_pcn <= (others => '0');
							rst_st0(7 downto 2) <= "011100";
							rst_st0(1 downto 0) <= com_us;
							reg_db  <= "0000";
						elsif (conv_integer(com_us) > 77) then
							rst_st0(7 downto 2) <= "011100";
							rst_st0(1 downto 0) <= com_us;
							c_num(conv_integer(com_us)) <= c_num(conv_integer(com_us)) - X"4D";
							rst_pcn                     <= c_num(conv_integer(com_us)) - X"4D";
						else
							rst_st0(7 downto 2) <= "001000";
							rst_st0(1 downto 0) <= com_us;
							c_num(conv_integer(com_us)) <= (others => '0');
							rst_pcn <= (others => '0');

							if    (com_us = "00") then
								reg_db  <= "0001";
							elsif (com_us = "01") then
								reg_db  <= "0010";
							else
								reg_db  <= "0000";
							end if;
						end if;

					when "01111" =>			-- Seek
						phase   <= "11";
						reg_rqm <= '0';
						reg_dio <= '1';
						fdint_i <= '1';

				--		if (nouse = '1') then
				--		else
							if (reg_com(2) >= maxtrack) then
								rst_st0(7 downto 3) <= "01110";
								rst_st0(2)          <= com_hd;
								rst_st0(1 downto 0) <= com_us;
								c_num(conv_integer(com_us)) <= maxtrack - X"01";
								rst_pcn <= maxtrack - X"01";
							else
								rst_st0(7 downto 3) <= "00100";
								rst_st0(2)          <= com_hd;
								rst_st0(1 downto 0) <= com_us;
								c_num(conv_integer(com_us)) <= reg_com(2);
								rst_pcn <= reg_com(2);
							end if;
							if    (com_us = "00") then
								reg_db  <= "0001";
							elsif (com_us = "01") then
								reg_db  <= "0010";
							else
								reg_db  <= "0000";
							end if;
				--		end if;

					when "11111"  => 		-- Invalid
						phase   <= "11";
						reg_rqm <= '0';
						reg_dio <= '1';
						rst_st0 <= X"80";
					when others =>
						comend_i <= '1';
						if (endtrg_f2 = '1') then
							phase   <= "11";
							reg_rqm <= '0';
							reg_dio <= '1';
							fdint_i <= '1';
						end if;
				end case;

			elsif (phase = "11") then	-- result phase

				comend_i <= '0';
				if (rstnum = rstcnt) then
					phase   <= "00";
					reg_rqm <= '0';
					reg_dio <= '0';
					reg_cb  <= '0';
					reg_db  <= "0000";
				elsif (data_r_f2 = '1') then
					fdint_i <= '0';
					rstcnt  <= rstcnt + 1;
					reg_rqm <= '0';
					reg_dio <= '1';
				else
					reg_dataout <= reg_rst(conv_integer(rstcnt));
					reg_rqm <= '1';
					reg_dio <= '1';
				end if;

			else						-- command ready

				rstcnt  <= X"0";
				comend_i <= '0';
				if (data_w_f1 = '1') then
					reg_rqm <= '0';
					reg_dio <= '0';
					reg_cb  <= '1';
					phase   <= "01";
					compat  <= "00000";
					comnum  <= X"0";
					rstnum  <= X"0";
				else
					reg_rqm <= '1';
					reg_dio <= '0';
				end if;
			end if;
		end if;
	end process;

	com_hd  <= reg_com(1)(2);
	com_us  <= reg_com(1)(1 downto 0);

	COMEND <= comend_i;

	COMMAND <= compat;
	MT     <= reg_com(0)(7);
	MF     <= reg_com(0)(6);
	SK     <= reg_com(0)(5);
	DNUM   <= com_us;
	HNUM   <= com_hd;
	IDRC   <= reg_com(2);
	IDRH   <= reg_com(3);
	IDRR   <= reg_com(4);
	IDRN   <= reg_com(5);
	EOT    <= reg_com(6);
	GPL    <= reg_com(7);
	DTL    <= reg_com(8);

	nouse <=	'1' when (com_us = "00" and FDD0(0) = '0') else
				'1' when (com_us = "01" and FDD1(0) = '0') else
				'1' when (com_us = "10") else
				'1' when (com_us = "11") else
				'0';

	maxtrack <=	X"50" when (com_us = "00" and FDD0(1) = '1') else
				X"50" when (com_us = "01" and FDD1(1) = '1') else
				X"28";



	process (compat,rst_st0,rst_st3,rst_pcn,ST0,ST1,ST2,RST_C,RST_H,RST_R,RST_N)
	begin
		if (compat = "01000") then		-- Sence Interrupt Status
			reg_rst(0) <= rst_st0;
			reg_rst(1) <= rst_pcn;
			reg_rst(2) <= (others => '0');
			reg_rst(3) <= (others => '0');
			reg_rst(4) <= (others => '0');
			reg_rst(5) <= (others => '0');
			reg_rst(6) <= (others => '0');
		elsif (compat = "00100") then	-- Sence Device Status
			reg_rst(0) <= rst_st3;
			reg_rst(1) <= (others => '0');
			reg_rst(2) <= (others => '0');
			reg_rst(3) <= (others => '0');
			reg_rst(4) <= (others => '0');
			reg_rst(5) <= (others => '0');
			reg_rst(6) <= (others => '0');
		elsif (compat = "11111") then	-- Invalid
			reg_rst(0) <= rst_st0;
			reg_rst(1) <= (others => '0');
			reg_rst(2) <= (others => '0');
			reg_rst(3) <= (others => '0');
			reg_rst(4) <= (others => '0');
			reg_rst(5) <= (others => '0');
			reg_rst(6) <= (others => '0');
		else
			reg_rst(0) <= ST0;
			reg_rst(1) <= ST1;
			reg_rst(2) <= ST2;
			reg_rst(3) <= RST_C;
			reg_rst(4) <= RST_H;
			reg_rst(5) <= RST_R;
			reg_rst(6) <= RST_N;
		end if;
	end process;

	FDINT  <= fdint_i;
	CNUM0  <= c_num(0);
	CNUM1  <= c_num(1);

	w_pro  <=	FLOPPY0(3) when (com_us = "00") else
				FLOPPY1(3) when (com_us = "01") else
				'0';

	FDCACT  <= '0' when (phase = "00") else '1';
	FDCCNUM <= c_num(conv_integer(com_us));
	FDCSNUM <= RST_R;

	MONOUT(1 downto 0) <= phase;
	MONOUT(5 downto 2) <= rstcnt;
	MONOUT(6)          <= reg_dio;
	MONOUT(7)          <= reg_rqm;

end RTL;
