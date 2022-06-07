--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UART8251 is
	port (
		A0			: in  std_logic;
		DI			: in  std_logic_vector(7 downto 0);
		CSN			: in  std_logic;
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		RXD			: in  std_logic;
		CTSN		: in  std_logic;
		DSRN		: in  std_logic;
		DTLEN		: in  std_logic_vector(19 downto 0);
		RESET		: in  std_logic;
		CLK			: in  std_logic;
		DO			: out std_logic_vector(7 downto 0);
		TXD			: out std_logic;
		RTSN		: out std_logic;
		DTRN		: out std_logic;
		TXRDY		: out std_logic;
		TXEMPTY		: out std_logic;
		RXRDY		: out std_logic;
		BD			: out std_logic
	);
end UART8251;

architecture RTL of UART8251 is

	signal rstn		: std_logic;

	signal rdn_f1	: std_logic;
	signal rdn_f2	: std_logic;
	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;
	signal wrn_r	: std_logic;
	signal di_f1	: std_logic_vector(7 downto 0);
	signal di_f2	: std_logic_vector(7 downto 0);
	signal a0_f1	: std_logic;
	signal a0_f2	: std_logic;
	signal csn_f1	: std_logic;
	signal csn_f2	: std_logic;

	signal rxd_f	: std_logic_vector(10 downto 0);
	signal ctsn_f1	: std_logic;
	signal ctsn_f2	: std_logic;
	signal dsrn_f1	: std_logic;
	signal dsrn_f2	: std_logic;

	signal do_i			: std_logic_vector(7 downto 0);

	signal rtsn_i		: std_logic;
	signal dtrn_i		: std_logic;
	signal txd_i		: std_logic;
	signal txrdy_i		: std_logic;
	signal txempty_i	: std_logic;
	signal rxrdy_i		: std_logic;
	signal bd_i			: std_logic;

	signal modeflag		: std_logic;

	signal modereg		: std_logic_vector(7 downto 0);
	signal commandreg	: std_logic_vector(7 downto 0);
	signal statusreg	: std_logic_vector(7 downto 0);

	signal txd_reg		: std_logic_vector(7 downto 0);
	signal rxd_reg		: std_logic_vector(7 downto 0);

	signal txd_para		: std_logic_vector(7 downto 0);
	signal txd_pty		: std_logic;
	signal rxd_para		: std_logic_vector(7 downto 0);
	signal rxd_pty		: std_logic;

	signal txd_rflag	: std_logic;
	signal txd_sflag	: std_logic;
	signal txd_sflag_f1	: std_logic;
	signal txd_s_e		: std_logic;
	signal rxd_sflag	: std_logic;
	signal rxd_sflag_f1	: std_logic;
	signal detst		: std_logic;
	signal rxd_fedge	: std_logic;
	signal stopbit		: std_logic;

	signal chiprst		: std_logic;
	signal flagrst		: std_logic;
	signal sendbreak	: std_logic;
	signal rxenb		: std_logic;
	signal txenb		: std_logic;

	signal parityerr	: std_logic;
	signal overrunerr	: std_logic;
	signal framingerr	: std_logic;

	signal txdivcnt		: std_logic_vector(19 downto 0);
	signal rxdivcnt		: std_logic_vector(19 downto 0);

	signal dtlendiv		: std_logic_vector(19 downto 0);

	signal txsftcnt		: std_logic_vector(4 downto 0);
	signal rxsftcnt		: std_logic_vector(4 downto 0);

	signal bdcnt		: std_logic_vector(4 downto 0);


begin

	rstn <= not RESET;

-- RDN/WRN/DI/A0/CSN latch
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			rdn_f1 <= '1';
			rdn_f2 <= '1';
			wrn_f1 <= '1';
			wrn_f2 <= '1';
			di_f1  <= (others => '0');
			di_f2  <= (others => '0');
			a0_f1  <= '0';
			a0_f2  <= '0';
			csn_f1 <= '1';
			csn_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			rdn_f1 <= RDN;
			rdn_f2 <= rdn_f1;
			wrn_f1 <= WRN;
			wrn_f2 <= wrn_f1;
			di_f1  <= DI;
			di_f2  <= di_f1;
			a0_f1  <= A0;
			a0_f2  <= a0_f1;
			csn_f1 <= CSN;
			csn_f2 <= csn_f1;
		end if;
	end process;

	wrn_r <= '1' when (wrn_f1 = '1' and wrn_f2 = '0') else '0';


-- write register
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			txd_reg    <= (others => '1');
			modereg    <= (others => '0');
			commandreg <= (others => '0');
			modeflag   <= '1';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				modereg    <= (others => '0');
				commandreg <= (others => '0');
				modeflag   <= '1';
			elsif (csn_f2 = '0' and wrn_r = '1') then
				if (a0_f2 = '0') then
					txd_reg <=	di_f2;
				else
					if (modeflag = '1') then
						modereg    <= di_f2;
						modeflag   <= '0';
					else
						commandreg <= di_f2;
					end if;
				end if;
			end if;
		end if;
	end process;

	process (CLK,rstn)
	begin
		if (rstn = '0') then
			flagrst <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				flagrst <= '0';
			elsif (csn_f2 = '0' and wrn_r = '1' and a0_f2 = '1' and modeflag = '0') then
				flagrst <= commandreg(4);
			else
				flagrst <= '0';
			end if;
		end if;
	end process;

	chiprst   <= commandreg(6);
	rtsn_i    <= not commandreg(5);

	sendbreak <= commandreg(3);
	rxenb     <= commandreg(2);
	dtrn_i    <= not commandreg(1);
	txenb     <= commandreg(0);


-- read register
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			do_i <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			if (csn_f2 = '0' and rdn_f2 = '0') then
				if (a0_f2 = '0') then
					do_i <= rxd_reg;
				else
					do_i <= statusreg;
				end if;
			end if;
		end if;
	end process;

	statusreg <= (not dsrn_f2) & bd_i & framingerr & overrunerr &
				parityerr & txempty_i & rxrdy_i & (not txd_rflag);


-- CTSN/DSRN latch
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			ctsn_f1 <= '1';
			ctsn_f2 <= '1';
			dsrn_f1 <= '1';
			dsrn_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			ctsn_f1 <= CTSN;
			ctsn_f2 <= ctsn_f1;
			dsrn_f1 <= DSRN;
			dsrn_f2 <= dsrn_f1;
		end if;
	end process;

	dtlendiv <=            DTLEN(19 downto 0) when (modereg(1 downto 0) = "11") else	-- 1/64
				"00" &     DTLEN(19 downto 2) when (modereg(1 downto 0) = "10") else	-- 1/16
				"000000" & DTLEN(19 downto 6);											-- 1/1


-- TX divide counter
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			txdivcnt <= X"00001";
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				txdivcnt <= X"00001";
			else
				if (txdivcnt = dtlendiv) then
					txdivcnt <= X"00001";
				else
					txdivcnt <= txdivcnt + 1;
				end if;
			end if;
		end if;
	end process;

-- TX register flag
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			txd_sflag_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			txd_sflag_f1 <= txd_sflag;
		end if;
	end process;

	process (CLK,rstn)
	begin
		if (rstn = '0') then
			txd_rflag <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				txd_rflag <= '0';
			elsif (sendbreak = '1') then
				txd_rflag <= '0';
			elsif (csn_f2 = '0' and wrn_r = '1' and a0_f2 = '0') then
				txd_rflag <= '1';
			elsif (txd_sflag = '1' and txd_sflag_f1 = '0') then
				txd_rflag <= '0';
			end if;
		end if;
	end process;

-- TxD generate
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			txd_sflag <= '0';
			txd_s_e   <= '0';
			txd_para  <= (others => '1');
			txsftcnt  <= (others => '0');
			txd_i     <= '1';
			txd_pty   <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				txd_sflag <= '0';
				txd_s_e   <= '0';
				txd_para  <= (others => '1');
				txsftcnt  <= (others => '0');
				txd_i     <= '1';
				txd_pty   <= '0';
			elsif (sendbreak = '1') then
				txd_sflag <= '0';
				txd_s_e   <= '0';
				txd_para  <= (others => '1');
				txsftcnt  <= (others => '0');
				txd_i     <= '0';
				txd_pty   <= '0';
			elsif (txdivcnt = dtlendiv) then
				if (txd_sflag = '0') then
					if (txd_rflag = '1' and ctsn_f2 = '0' and txenb = '1') then
						txd_para  <= txd_reg;
						txd_i     <= '0';
						txd_sflag <= '1';
						txd_s_e   <= '1';
						txsftcnt  <= (others => '0');
						if (modereg(5) = '0') then
							txd_pty   <= '1';
						else
							txd_pty   <= '0';
						end if;
					else
						txd_s_e   <= '0';
						txd_para  <= (others => '0');
						txd_i     <= '1';
						txd_pty   <= '0';
					end if;
				else

--                                1  1  1  1  1  1  1  1  1  1  2  2  2  2
--  0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0  1  2  3
-- ST ST D0 D0 D1 D1 D2 D2 D3 D3 D4 D4 D5 D5 D6 D6 D7 D7  P  P ST ST ST ST

					case txsftcnt is
						when "00001" =>
								txd_i    <= txd_para(0);
								txd_pty  <= txd_para(0) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
						when "00011" =>
								txd_i    <= txd_para(1);
								txd_pty  <= txd_para(1) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
						when "00101" =>
								txd_i    <= txd_para(2);
								txd_pty  <= txd_para(2) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
						when "00111" =>
								txd_i    <= txd_para(3);
								txd_pty  <= txd_para(3) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
						when "01001" =>
								txd_i    <= txd_para(4);
								txd_pty  <= txd_para(4) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
						when "01011" =>
							if    (modereg(4 downto 2) = "000") then	-- no parity / 5bit
								txd_i    <= '1';
								txsftcnt <= "10100";
							elsif (modereg(4 downto 2) = "100") then	-- parity / 5bit
								txd_i    <= txd_pty;
								txsftcnt <= "10010";
							else
								txd_i    <= txd_para(5);
								txd_pty  <= txd_para(5) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
							end if;
						when "01101" =>
							if    (modereg(4 downto 2) = "001") then	-- no parity / 6bit
								txd_i    <= '1';
								txsftcnt <= "10100";
							elsif (modereg(4 downto 2) = "101") then	-- parity / 6bit
								txd_i    <= txd_pty;
								txsftcnt <= "10010";
							else
								txd_i    <= txd_para(6);
								txd_pty  <= txd_para(6) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
							end if;
						when "01111" =>
							if    (modereg(4 downto 2) = "010") then	-- no parity / 7bit
								txd_i    <= '1';
								txsftcnt <= "10100";
							elsif (modereg(4 downto 2) = "110") then	-- parity / 7bit
								txd_i    <= txd_pty;
								txsftcnt <= "10010";
							else
								txd_i    <= txd_para(7);
								txd_pty  <= txd_para(7) xor txd_pty;
								txsftcnt <= txsftcnt + 1;
							end if;
						when "10001" =>
							if    (modereg(4 downto 2) = "011") then	-- no parity / 8bit
								txd_i    <= '1';
								txsftcnt <= "10100";
							elsif (modereg(4 downto 2) = "111") then	-- parity / 8bit
								txd_i    <= txd_pty;
								txsftcnt <= txsftcnt + 1;
							end if;
						when "10011" =>
								txd_i    <= '1';
								txsftcnt <= txsftcnt + 1;
						when others =>
							txsftcnt <= txsftcnt + 1;
					end case;

					if    (modereg(7 downto 6) = "11") then		-- stop 2.0
						if (txsftcnt = 22) then
							txd_sflag <= '0';
						end if;
					elsif (modereg(7 downto 6) = "10") then		-- stop 1.5
						if (txsftcnt = 21) then
							txd_sflag <= '0';
						end if;
					else										-- stop 1.0
						if (txsftcnt = 20) then
							txd_sflag <= '0';
						end if;
					end if;

				end if;
			end if;
		end if;
	end process;

-- txrdy and txempty
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			txrdy_i   <= '0';
			txempty_i <= '1';
		elsif (CLK'event and CLK = '1') then
			if (txd_rflag = '0' and ctsn_f2 = '0' and txenb = '1') then
				txrdy_i   <= '1';
			else
				txrdy_i   <= '0';
			end if;
			if (ctsn_f2 = '1' or txenb = '0') then
				txempty_i <= '1';
			elsif (txd_rflag = '0' and txd_s_e = '0') then
				txempty_i <= '1';
			else
				txempty_i <= '0';
			end if;
		end if;
	end process;



-- RxD latch
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			rxd_f <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			rxd_f <= rxd_f(9 downto 0) & RXD;
		end if;
	end process;

-- 1           --
-- 09876543210 --
-- HHHxxxxxLLL --

	rxd_fedge <= '1' when (rxd_f(10 downto 8) = "111" and rxd_f(2 downto 0) = "000") else '0';


-- RX divide counter
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			rxdivcnt <= X"00001";
			detst    <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				rxdivcnt <= X"00001";
				detst    <= '0';
			else
				if (rxd_fedge = '1' and rxd_sflag = '0' and detst = '0' and rxenb = '1') then
					rxdivcnt <= X"00005";
				elsif (rxdivcnt = dtlendiv) then
					rxdivcnt <= X"00001";
				else
					rxdivcnt <= rxdivcnt + 1;
				end if;
				if (rxd_fedge = '1' and rxd_sflag = '0' and detst = '0' and rxenb = '1') then
					detst    <= '1';
				elsif (rxd_sflag = '1') then
					detst    <= '0';
				end if;
			end if;
		end if;
	end process;


-- RxD recieve
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			rxd_para  <= (others => '1');
			rxsftcnt  <= (others => '0');
			rxd_sflag <= '0';
			rxd_pty   <= '0';
			stopbit   <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				rxd_para  <= (others => '1');
				rxsftcnt  <= (others => '0');
				rxd_sflag <= '0';
				rxd_pty   <= '0';
				stopbit   <= '0';
			elsif (rxdivcnt = dtlendiv) then
				if (rxd_sflag = '0') then
					if (detst = '1' and rxd_f(1) = '0') then
						rxd_para  <= (others => '0');
						rxsftcnt  <= "00010";
						rxd_sflag <= '1';
						if (modereg(5) = '0') then
							rxd_pty   <= '1';
						else
							rxd_pty   <= '0';
						end if;
						stopbit   <= '0';
					end if;
				else

--                                1  1  1  1  1  1  1  1  1  1  2  2  2  2
--  0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6  7  8  9  0  1  2  3
-- ST ST D0 D0 D1 D1 D2 D2 D3 D3 D4 D4 D5 D5 D6 D6 D7 D7  P  P ST ST ST ST

					case rxsftcnt is
						when "00011" =>
							rxd_para(0) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							rxsftcnt    <= rxsftcnt + 1;
						when "00101" =>
							rxd_para(1) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							rxsftcnt    <= rxsftcnt + 1;
						when "00111" =>
							rxd_para(2) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							rxsftcnt    <= rxsftcnt + 1;
						when "01001" =>
							rxd_para(3) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							rxsftcnt    <= rxsftcnt + 1;
						when "01011" =>
							rxd_para(4) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							if    (modereg(4 downto 2) = "000") then	-- no parity / 5bit
								rxsftcnt    <= "10100";
							elsif (modereg(4 downto 2) = "100") then	-- parity / 5bit
								rxsftcnt    <= "10010";
							else
								rxsftcnt    <= rxsftcnt + 1;
							end if;
						when "01101" =>
							rxd_para(5) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							if    (modereg(4 downto 2) = "001") then	-- no parity / 6bit
								rxsftcnt    <= "10100";
							elsif (modereg(4 downto 2) = "101") then	-- parity / 6bit
								rxsftcnt    <= "10010";
							else
								rxsftcnt    <= rxsftcnt + 1;
							end if;
						when "01111" =>
							rxd_para(6) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							if    (modereg(4 downto 2) = "010") then	-- no parity / 7bit
								rxsftcnt    <= "10100";
							elsif (modereg(4 downto 2) = "110") then	-- parity / 7bit
								rxsftcnt    <= "10010";
							else
								rxsftcnt    <= rxsftcnt + 1;
							end if;
						when "10001" =>
							rxd_para(7) <= rxd_f(1);
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							if    (modereg(4 downto 2) = "011") then	-- no parity / 8bit
								rxsftcnt    <= "10100";
							elsif (modereg(4 downto 2) = "111") then	-- parity / 8bit
								rxsftcnt    <= rxsftcnt + 1;
							else
								rxsftcnt    <= rxsftcnt + 1;
							end if;
						when "10011" =>
							rxd_pty     <= rxd_f(1) xor rxd_pty;
							rxsftcnt    <= rxsftcnt + 1;
						when "10101" =>
							stopbit     <= rxd_f(1);
							rxd_sflag   <= '0';
						when others =>
							rxsftcnt    <= rxsftcnt + 1;
					end case;

				end if;

			end if;
		end if;
	end process;

-- RxD output
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			rxd_sflag_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			rxd_sflag_f1 <= rxd_sflag;
		end if;
	end process;

	process (CLK,rstn)
	begin
		if (rstn = '0') then
			rxd_reg <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				rxd_reg <= (others => '1');
			elsif (rxd_sflag = '0' and rxd_sflag_f1 = '1') then
				rxd_reg <= rxd_para;
			end if;
		end if;
	end process;

	process (CLK,rstn)
	begin
		if (rstn = '0') then
			rxrdy_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				rxrdy_i <= '0';
			elsif (rxd_sflag = '0' and rxd_sflag_f1 = '1') then
				rxrdy_i <= '1';
			elsif (csn_f2 = '0' and rdn_f2 = '0' and a0_f2 = '0') then
				rxrdy_i <= '0';
			end if;
		end if;
	end process;

-- RX error detect
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			overrunerr <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				overrunerr <= '0';
			elsif (flagrst = '1') then
				overrunerr <= '0';
			elsif (rxd_sflag = '0' and rxd_sflag_f1 = '1' and rxrdy_i = '1') then
				overrunerr <= '1';
			end if;
		end if;
	end process;

	process (CLK,rstn)
	begin
		if (rstn = '0') then
			framingerr <= '0';
			parityerr  <= '0';
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				framingerr <= '0';
				parityerr  <= '0';
			elsif (flagrst = '1') then
				framingerr <= '0';
				parityerr  <= '0';
			elsif (rxd_sflag = '0' and rxd_sflag_f1 = '1') then
				if (stopbit = '0') then
					framingerr <= '1';
				end if;
				if (modereg(4) = '1' and rxd_pty = '1') then
					parityerr  <= '1';
				end if;
			end if;
		end if;
	end process;

-- RX break detect
	process (CLK,rstn)
	begin
		if (rstn = '0') then
			bd_i  <= '0';
			bdcnt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (chiprst = '1') then
				bd_i  <= '0';
				bdcnt <= (others => '0');
			elsif (rxdivcnt = dtlendiv) then
				if (rxd_f(1) = '1') then
					bd_i  <= '0';
					bdcnt <= (others => '0');
				else
					if (bdcnt = 20) then
						bd_i  <= '1';
					else
						bdcnt <= bdcnt + 1;
					end if;
				end if;
			end if;
		end if;
	end process;


	DO      <= do_i;

	TXD     <= txd_i;
	RTSN    <= rtsn_i;
	DTRN    <= dtrn_i;
	TXRDY   <= txrdy_i;
	TXEMPTY <= txempty_i;
	RXRDY   <= rxrdy_i;
	BD      <= bd_i;

end RTL;
