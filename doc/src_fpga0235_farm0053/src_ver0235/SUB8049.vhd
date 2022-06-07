--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SUB8049 is
	port (
		DI			: in  std_logic_vector(7 downto 0);
		P2			: in  std_logic_vector(7 downto 0);
		INTN		: in  std_logic;
		T0			: in  std_logic;
		TAPERDDATA	: in  std_logic_vector(7 downto 0);
		TAPERDRDY	: in  std_logic;
		TAPEWRRDY	: in  std_logic;
		ACCCNT		: in  std_logic_vector(31 downto 0);
		MK2MODE		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(7 downto 0);
		P1			: out std_logic_vector(7 downto 0);
		STATEOUT	: out std_logic_vector(7 downto 0);
		STCNTOUT	: out std_logic_vector(7 downto 0);
		RDN			: out std_logic;
		WRN			: out std_logic;
		KEYSCANENB	: out std_logic;
		TAPERDOPEN	: out std_logic;
		TAPERDRQ	: out std_logic;
		TAPEACC		: out std_logic;
		TAPEWROPEN	: out std_logic;
		TAPEWRRQ	: out std_logic;
		TAPEWRDATA	: out std_logic_vector(7 downto 0)
	);
end SUB8049;

architecture RTL of SUB8049 is

	component MATRIXCONV is
		port (
			KEYMAT		: in  std_logic_vector(7 downto 0);
			STCNT		: in  std_logic_vector(7 downto 0);
			KEYENB		: in  std_logic;
			KANATG		: in  std_logic;
			HIRATG		: in  std_logic;
			MK2MODE		: in  std_logic;
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			KEYDATA		: out std_logic_vector(7 downto 0);
			KEYFUNC		: out std_logic_vector(7 downto 0);
			OUTENB		: out std_logic;
			MATSEL		: out std_logic_vector(3 downto 0);
			KANA		: out std_logic;
			HIRA		: out std_logic;
			DATALASTENB	: out std_logic;
			DATALAST	: out std_logic_vector(7 downto 0);
			FUNCLAST	: out std_logic_vector(7 downto 0)
		);
	end component;

	signal do_i		: std_logic_vector(7 downto 0);
	signal p1_i		: std_logic_vector(5 downto 0);

	signal rdn_i	: std_logic;
	signal wrn_i	: std_logic;

	signal incom	: std_logic_vector(8 downto 0);
	signal outcom1	: std_logic_vector(8 downto 0);
	signal outcom2	: std_logic_vector(8 downto 0);
	signal outcom1lt: std_logic_vector(8 downto 0);
	signal outcom2lt: std_logic_vector(8 downto 0);
	signal outcom1f	: std_logic_vector(8 downto 0);
	signal outcom2f	: std_logic_vector(8 downto 0);
	signal outflag	: std_logic;

	signal state	: std_logic_vector(7 downto 0);
	signal baud6	: std_logic;
	signal kana		: std_logic;
	signal hira		: std_logic;
	signal rdy_b	: std_logic;
	signal stcnt	: std_logic_vector(7 downto 0);
	signal stnxt	: std_logic_vector(7 downto 0);
	signal gamekey	: std_logic_vector(7 downto 0);

	signal kanatg	: std_logic;
	signal hiratg	: std_logic;

	signal keymat		: std_logic_vector(7 downto 0);
	signal outkey		: std_logic_vector(7 downto 0);
	signal keyfunc		: std_logic_vector(7 downto 0);
	signal outkeyenb	: std_logic;
	signal keyenb		: std_logic;
	signal matsel		: std_logic_vector(3 downto 0);
	signal datalastenb	: std_logic;
	signal datalast		: std_logic_vector(7 downto 0);
	signal funclast		: std_logic_vector(7 downto 0);
	signal rptcnt		: std_logic_vector(9 downto 0);
	signal rptst		: std_logic;

	signal pollcnt	: std_logic_vector(12 downto 0);
	signal pollst	: std_logic;
	signal keysrch	: std_logic;
	signal keymask	: std_logic;
	signal rxsrch	: std_logic;
	signal rxmask	: std_logic;

	signal p2_f1	: std_logic_vector(7 downto 0);
	signal p2_f2	: std_logic_vector(7 downto 0);
	signal t0_f1	: std_logic;

	signal intcnt	: std_logic_vector(8 downto 0);
	signal int_i_f1	: std_logic;
	signal int_i_f2	: std_logic;
	signal intn_tmp	: std_logic;
	signal rdcnt	: std_logic_vector(3 downto 0);
	signal int_f1	: std_logic;
	signal int_f2	: std_logic;

	signal wrcnt	: std_logic_vector(3 downto 0);
	signal int8049n	: std_logic;

	signal taperdrq_i	: std_logic;
	signal taperd_lt	: std_logic_vector(7 downto 0);
	signal taperdrdy_f1	: std_logic;
	signal taperdrdy_f2	: std_logic;
	signal loadclose	: std_logic;
	signal taperdopen_i	: std_logic;

	signal tapewrrdy_f1	: std_logic;
	signal tapewrrdy_f2	: std_logic;
	signal tapewropen_i	: std_logic;
	signal tapewrrq_i	: std_logic;
	signal tapewrdata_i	: std_logic_vector(7 downto 0);

	signal acccnt_i		: std_logic_vector(31 downto 0);
	signal tapeacc1_i	: std_logic;
	signal tapeacc2_i	: std_logic;
	signal tapeacc3_i	: std_logic;

begin

-- key matrix
--
--	P2		b0	b1	b2	b3	b4	b5	b6	b7
--
--	P1=0	 	CT	SHI	GRA
--				RL	FT	PH
--
--	P1=1	1	Q	A	Z	K	I	8	,
--
--	P1=2	2	W	S	X	L	O	9	.
--
--	P1=3	3	E	D	C	;	P	F1	/
--
--	P1=4	4	R	F	V	:	@	F2	_
--
--	P1=5	5	T	G	B	]	[	F3	SPC
--
--	P1=6	6	Y	H	N	-	^	F4	0
--
--	P1=7	7	U	J	M	 	\	F5	
--
--	P1=8	RET	ST	ª	«	¨	©	TAB	ESC
--			RUN	OP
--	P1=9	‚©	INS	DEL	PA	HOME MO CA
--			‚È			GE	CLR  DE PS

-- keymatrix convert
	U_MATRIXCONV : MATRIXCONV
	port map (
		KEYMAT		=> keymat,
		STCNT		=> stcnt,
		KEYENB		=> keyenb,
		KANATG		=> kanatg,
		HIRATG		=> hiratg,
		MK2MODE		=> MK2MODE,
		CLK			=> CLK,
		RSTN		=> RSTN,
		KEYDATA		=> outkey,
		KEYFUNC		=> keyfunc,
		OUTENB		=> outkeyenb,
		MATSEL		=> matsel,
		KANA		=> kana,
		HIRA		=> hira,
		DATALASTENB	=> datalastenb,
		DATALAST	=> datalast,
		FUNCLAST	=> funclast

	);

	keymat <= not p2_f2;

-- process state
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			kanatg  <= '0';
			hiratg  <= '0';
			state   <= X"00";
			baud6   <= '0';
			rdy_b   <= '1';
			outcom1 <= '0' & X"00";
			outcom2 <= '0' & X"00";
			stcnt   <= X"00";
			stnxt   <= X"00";
			p1_i	<= "111111";
			gamekey <= X"00";
			keyenb  <= '0';
			rptcnt  <= (others => '0');
			rptst   <= '0';
			taperdopen_i <= '0';
			taperdrq_i   <= '0';
			taperd_lt    <= (others => '0');
			tapewropen_i <= '0';
			tapewrrq_i   <= '0';
			tapewrdata_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (incom = '1' & X"2C" and state /= X"42") then	-- CMT initialize
				state   <= X"00";
				baud6   <= '0';
				outcom1 <= '0' & X"00";
				outcom2 <= '0' & X"00";
				stnxt   <= X"00";

			else
				case state is
					when X"00" =>							-- waiting command
						if (incom = '1' & X"0C") then		-- RxRDY initialize
							rdy_b <= '1';
						elsif (incom = '1' & X"04" and MK2MODE = '1') then	-- KANA toggle
							kanatg <= '1';
							hiratg <= '0';
						elsif (incom = '1' & X"05" and MK2MODE = '1') then	-- HIRAGANA/KATAKANA toggle
							kanatg <= '0';
							hiratg <= '1';
						elsif (incom = '1' & X"06") then	-- game key search
							state   <= X"60";
							kanatg <= '0';
							hiratg <= '0';
						elsif (incom = '1' & X"1E") then	-- CMT load (1200 baud)
							state   <= X"20";
							baud6   <= '0';
							kanatg <= '0';
							hiratg <= '0';
						elsif (incom = '1' & X"1D") then	-- CMT load (600 baud)
							state   <= X"20";
							baud6   <= '1';
							kanatg <= '0';
							hiratg <= '0';
						elsif (incom = '1' & X"3E") then	-- CMT save (1200 baud)
							state   <= X"40";
							baud6   <= '0';
							kanatg <= '0';
							hiratg <= '0';
						elsif (incom = '1' & X"3D") then	-- CMT save (600 baud)
							state   <= X"40";
							baud6   <= '1';
							kanatg <= '0';
							hiratg <= '0';
						elsif (keysrch = '1') then			-- keyboard polling
							state   <= X"80";
							kanatg <= '0';
							hiratg <= '0';
						elsif (rxsrch = '1') then			-- RxRDY polling
							state   <= X"A0";
							kanatg <= '0';
							hiratg <= '0';
						else
							kanatg <= '0';
							hiratg <= '0';
						end if;


					when X"20" =>							-- CMT load process
						if (loadclose = '1') then
							state        <= X"00";
							stcnt        <= X"00";
							taperdopen_i <= '0';
							taperdrq_i   <= '0';
						else
							if (incom = '1' & X"19") then		-- CMT load start
								p1_i(4) <= '0';
								p1_i(3 downto 0) <= "1000";
								state   <= X"21";
								stcnt   <= X"00";
								taperdopen_i <= '1';
								taperdrq_i   <= '0';
								taperd_lt    <= (others => '0');
							end if;
						end if;

					when X"21" =>							-- CMT data get
						if (loadclose = '1') then
							state        <= X"00";
							stcnt        <= X"00";
							taperdopen_i <= '0';
							taperdrq_i   <= '0';
						else
							if (stcnt = 16) then
								stcnt      <= X"00";
								state      <= X"24";
								taperdrq_i <= '0';
							elsif (stcnt = 8) then
								taperd_lt  <= TAPERDDATA;
								stcnt      <= stcnt + 1;
							elsif (stcnt = 7) then
								if (p2_f2(1) = '0') then		-- STOP key search
									stcnt   <= X"00";
									outcom1 <= '1' & X"10";
									outcom2 <= '0' & X"00";
									state   <= X"FF";
									stnxt   <= X"00";
									taperdopen_i <= '0';
								elsif (taperdrdy_f2 = '1') then
									stcnt <= stcnt + 1;
									p1_i(4) <= '0';
								else
									stcnt <= X"00";
									p1_i(4) <= '1';
									p1_i(3 downto 0) <= "1000";
								end if;
							elsif (stcnt < 7) then
								p1_i(4) <= '1';
								p1_i(3 downto 0) <= "1000";
								stcnt <= stcnt + 1;
							else
								p1_i(4) <= '0';
								stcnt <= stcnt + 1;

								if (12 <= stcnt and stcnt <= 15) then
									taperdrq_i <= '1';
								else
									taperdrq_i <= '0';
								end if;

							end if;
						end if;

					when X"24" =>
						if (loadclose = '1') then
							state   <= X"00";
							taperdopen_i <= '0';
						else
							outcom1 <= '1' & X"08";
							outcom2 <= '1' & taperd_lt;
							state   <= X"FF";
							stnxt   <= X"25";
						end if;

					when X"25" =>
						if (loadclose = '1') then
							stcnt <= X"00";
							state <= X"00";
							taperdopen_i <= '0';
						else
							stcnt <= X"00";
							state <= X"21";
						end if;


					when X"40" =>							-- CMT save process
						if ( (incom = '1' & X"1A") or (incom = '1' & X"3A") ) then
							state        <= X"00";
							stcnt        <= X"00";
							tapewropen_i <= '0';
							tapewrrq_i   <= '0';
						elsif (incom = '1' & X"39") then	-- CMT save start
							p1_i(4)          <= '1';
							p1_i(3 downto 0) <= "1000";
							state        <= X"41";
							stcnt        <= X"00";
							tapewropen_i <= '1';
							tapewrrq_i   <= '0';
						else
							tapewropen_i <= '0';
							tapewrrq_i   <= '0';
						end if;

					when X"41" =>
						if ( (incom = '1' & X"1A") or (incom = '1' & X"3A") ) then
							state        <= X"00";
							stcnt        <= X"00";
							tapewropen_i <= '0';
							tapewrrq_i   <= '0';
						elsif (incom = '1' & X"38") then	-- CMT save command
							state        <= X"42";
							stcnt        <= X"00";
							tapewropen_i <= '1';
							tapewrrq_i   <= '0';
						elsif (p2_f2(1) = '0') then			-- STOP key search
							stcnt   <= X"00";
							outcom1 <= '1' & X"0E";
							outcom2 <= '0' & X"00";
							state   <= X"FF";
							stnxt   <= X"00";
							tapewropen_i <= '0';
							tapewrrq_i   <= '0';
						else
							tapewropen_i <= '1';
							tapewrrq_i   <= '0';
						end if;

					when X"42" =>
						if (incom(8) = '1') then
							state        <= X"43";
							stcnt        <= X"00";
							tapewropen_i <= '1';
							tapewrrq_i   <= '0';
							tapewrdata_i <= incom(7 downto 0);
						else
							tapewropen_i <= '1';
							tapewrrq_i   <= '0';
						end if;

					when X"43" =>
						if (p2_f2(1) = '0') then			-- STOP key search
							stcnt   <= X"00";
							outcom1 <= '1' & X"0E";
							outcom2 <= '0' & X"00";
							state   <= X"FF";
							stnxt   <= X"00";
							tapewropen_i <= '0';
							tapewrrq_i   <= '0';
						elsif (tapewrrdy_f2 = '1') then
							state        <= X"41";
							stcnt        <= X"00";
							tapewropen_i <= '1';
							tapewrrq_i   <= '1';
						else
							tapewropen_i <= '1';
							tapewrrq_i   <= '0';
						end if;


					when X"60" =>							-- game key search process
						p1_i(4) <= '1';
						p1_i(3 downto 0) <= "0000";
						stcnt   <= X"00";
						state   <= X"61";
						gamekey <= X"00";

					when X"61" =>
						if (stcnt = 24) then
							stcnt   <= X"00";
							outcom1 <= '1' & X"16";
							outcom2 <= '1' & gamekey;
							state   <= X"FF";
							stnxt   <= X"00";
						else 								-- SPC "0" © ¨ « ª STOP SFT
							if (stcnt = 7) then
								gamekey <= gamekey or ("0000000" & (not p2_f2(2)) );
								p1_i(3 downto 0) <= "0101";
							elsif (stcnt = 15) then
								gamekey <= gamekey or ( (not p2_f2) and X"80");
								p1_i(3 downto 0) <= "1000";
							elsif (stcnt = 23) then
								gamekey <= gamekey or ( (not p2_f2) and X"3E");
								p1_i(3 downto 0) <= "1111";
							end if;
							stcnt <= stcnt + 1;
						end if;


					when X"80" =>							-- keyboard search process
						p1_i(4) <= '1';
						p1_i(3 downto 0) <= matsel;
						stcnt   <= X"00";
						state   <= X"81";
						keyenb  <= '1';

					when X"81" =>
						if (stcnt = X"50") then
							if (outkeyenb = '1') then
								stcnt   <= X"00";
								outcom1 <= '1' & keyfunc;
								outcom2 <= '1' & outkey;
								state   <= X"FF";
								stnxt   <= X"00";
								keyenb  <= '0';
								rptcnt  <= (others => '0');
								rptst   <= '0';
							elsif (datalastenb = '1') then
								if ( (rptst = '0' and rptcnt = 1000) or (rptst = '1' and rptcnt = 200) ) then
									stcnt   <= X"00";
									outcom1 <= '1' & funclast;
									outcom2 <= '1' & datalast;
									state   <= X"FF";
									stnxt   <= X"00";
									keyenb  <= '0';
									rptcnt  <= (others => '0');
									rptst   <= '1';
								else
									stcnt   <= X"00";
									state   <= X"00";
									keyenb  <= '0';
									rptcnt  <= rptcnt + 1;
								end if;
							else
								stcnt   <= X"00";
								state   <= X"00";
								keyenb  <= '0';
								rptcnt  <= (others => '0');
								rptst   <= '0';
							end if;
						else
							keyenb  <= '1';
							stcnt   <= stcnt + 1;
							p1_i(3 downto 0) <= matsel;
						end if;


					when X"A0" =>							-- RxRDY search process
						p1_i(4) <= '0';
						stcnt   <= X"00";
						state   <= X"A1";

					when X"A1" =>
						if (stcnt = 7) then
							stcnt   <= X"00";
							if (rdy_b = '1' and p2_f2(1) = '0') then
								outcom1 <= '1' & X"04";
								outcom2 <= '0' & X"00";
								state   <= X"FF";
								stnxt   <= X"00";
								rdy_b <= '0';
							else
								state   <= X"00";
							end if;
						else
							stcnt <= stcnt + 1;
						end if;


					when X"FF" =>							-- output data
						outcom1 <= '0' & X"00";
						outcom2 <= '0' & X"00";
						state   <= stnxt;
						stnxt   <= X"00";

--					when X"FF" =>							-- 1 clock wait for output data
--						state   <= X"FE";

					when others =>
						state   <= X"00";
						stnxt   <= X"00";
						p1_i    <= "111111";

				end case;
			end if;
		end if;
	end process;

	pollst <= '1';

-- polling counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			pollcnt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (pollst = '1') then
				if (pollcnt = 7999) then
					pollcnt <= (others => '0');
				else
					pollcnt <= pollcnt + 1;
				end if;
			end if;
		end if;
	end process;

	keysrch <= '1' when (pollcnt = 7999) else '0';
	keymask <= '1' when (7995 <= pollcnt and pollcnt <= 7999) else '0';
	rxsrch  <= '1' when (pollcnt = 3999) else '0';
	rxmask  <= '1' when (3995 <= pollcnt and pollcnt <= 3999) else '0';

-- input latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			p2_f1        <= (others => '0');
			p2_f2        <= (others => '0');
			t0_f1        <= '0';
			taperdrdy_f1 <= '0';
			taperdrdy_f2 <= '0';
			tapewrrdy_f1 <= '0';
			tapewrrdy_f2 <= '0';
		elsif (CLK'event and CLK = '1') then
			p2_f1        <= P2;
			p2_f2        <= p2_f1;
			t0_f1        <= T0;
			taperdrdy_f1 <= TAPERDRDY;
			taperdrdy_f2 <= taperdrdy_f1;
			tapewrrdy_f1 <= TAPEWRRDY;
			tapewrrdy_f2 <= tapewrrdy_f1;
		end if;
	end process;


-- 8255 -> 8049
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			int_i_f1 <= '1';
			int_i_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			int_i_f1 <= INTN;
			int_i_f2 <= int_i_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			intcnt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (int_i_f1 = '1') then
				intcnt <= "000000000";
			elsif (int_i_f1 = '0' and int_i_f2 = '1') then
				intcnt <= "000000001";
			elsif (intcnt(8) = '0') then
				intcnt <= intcnt + 1;
			end if;
		end if;
	end process;

	intn_tmp <= not intcnt(8);

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			int_f1 <= '1';
			int_f2 <= '1';
		elsif (CLK'event and CLK = '1') then
			if    (state = X"00" and keymask = '1') then
				int_f1 <= '1';
			elsif (state = X"00" and rxmask = '1') then
				int_f1 <= '1';
			elsif (state = X"00") then
				int_f1 <= intn_tmp;
			elsif (state(7 downto 4) = X"2") then
				int_f1 <= intn_tmp;
			elsif (state = X"40" or state = X"41" or state = X"42") then
				int_f1 <= intn_tmp;
			else
				int_f1 <= '1';
			end if;
			int_f2 <= int_f1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdcnt <= "1111";
		elsif (CLK'event and CLK = '1') then
			if (int_f1 = '0' and int_f2 = '1') then
					rdcnt <= "0000";
			elsif (rdcnt /= "1111") then
				rdcnt <= rdcnt + 1;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			rdn_i  <= '1';
		elsif (CLK'event and CLK = '1') then
			if (rdcnt = "0001" or rdcnt = "0010") then
				rdn_i  <= '0';
			else
				rdn_i  <= '1';
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			incom     <= '0' & X"00";
		elsif (CLK'event and CLK = '1') then
			if (rdcnt = "0010") then
				incom <= '1' & DI;
			else
				incom <= '0' & X"00";
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			loadclose <= '0';
		elsif (CLK'event and CLK = '1') then
			if (incom = '1' & X"1A") then
				loadclose <= '1';
			elsif (incom = '1' & X"3A") then
				loadclose <= '1';
			elsif (state = X"00") then
				loadclose <= '0';
			end if;
		end if;
	end process;


-- 8049 -> 8255
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			outcom1f <= (others => '0');
			outcom2f <= (others => '0');
		elsif (CLK'event and CLK = '1') then
--			if ((outcom1(8) = '1' and wrcnt = "0000") or
--				(outcom1(8) = '1' and wrcnt = "0111" and outcom2lt(8) = '0') or
--				(outcom1(8) = '1' and wrcnt = "1111")) then
		
			if (outcom1(8) = '1') then
				outcom1f <= outcom1;
				outcom2f <= outcom2;
			elsif (outcom1f(8) = '1' and outflag = '0') then
				outcom1f <= (others => '0');
				outcom2f <= (others => '0');
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			outflag   <= '0';
			outcom1lt <= (others => '0');
			outcom2lt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (outcom1f(8) = '1' and outflag = '0') then
				outflag <= '1';
				outcom1lt <= outcom1f;
				outcom2lt <= outcom2f;
			elsif (outcom2lt(8) = '0' and wrcnt = "0111" and T0 = '0') then
				outflag <= '0';
			elsif (wrcnt = "1111" and T0 = '0') then
				outflag <= '0';
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			wrcnt <= "0000";
		elsif (CLK'event and CLK = '1') then
			if (outflag = '0') then
				wrcnt <= "0000";
			elsif (wrcnt = "0111" and outcom2lt(8) = '1') then
				wrcnt <= "1000";
			elsif (wrcnt(2 downto 0) = "000") then
				if (T0 = '0') then
					wrcnt <= wrcnt + 1;
				end if;
			elsif (wrcnt(2 downto 0) /= "111") then
				wrcnt <= wrcnt + 1;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			wrn_i    <= '1';
			int8049n <= '1';
			do_i     <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (wrcnt(2 downto 0) = "011" or wrcnt(2 downto 0) = "010") then
				wrn_i    <= '0';
			else
				wrn_i    <= '1';
			end if;

			if (wrcnt = "0001") then
				do_i     <= outcom1lt(7 downto 0);
			elsif (wrcnt = "1001") then
				do_i     <= outcom2lt(7 downto 0);
			end if;

			if (wrcnt = "0001") then
				int8049n <= '0';
			elsif (T0 = '0' and t0_f1 = '1') then
				int8049n <= '1';
			end if;

		end if;
	end process;


	DO <= do_i;
	P1 <= int8049n & (not kana) & p1_i;

	RDN <= rdn_i;
	WRN <= wrn_i;

	STATEOUT <= state;
	STCNTOUT <= stcnt;

	TAPERDRQ   <= taperdrq_i;
	TAPERDOPEN <= taperdopen_i;
	TAPEWROPEN <= tapewropen_i;
	TAPEWRRQ   <= tapewrrq_i;
	TAPEWRDATA <= tapewrdata_i;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			acccnt_i   <= (others => '1');
			tapeacc1_i <= '0';
			tapeacc2_i <= '0';
			tapeacc3_i <= '0';
		elsif (CLK'event and CLK = '1') then
			if (state = X"20") then
				acccnt_i   <= (others => '0');
				tapeacc1_i <= '0';
				tapeacc2_i <= '0';
				tapeacc3_i <= '0';
			elsif (tapeacc1_i = '0' and state = X"24" and taperd_lt /= X"00") then
				tapeacc1_i <= '1';
				tapeacc2_i <= '0';
				tapeacc3_i <= '0';
			elsif (state = X"24" and taperd_lt /= X"00") then
				tapeacc1_i <= '1';
				tapeacc2_i <= '1';
				tapeacc3_i <= '0';
			elsif (acccnt_i = ACCCNT) then
				tapeacc1_i <= '1';
				tapeacc2_i <= '1';
				tapeacc3_i <= '1';
			elsif (tapeacc2_i = '1') then
				acccnt_i   <= acccnt_i + 1;
				tapeacc1_i <= '1';
				tapeacc2_i <= '1';
				tapeacc3_i <= '0';
			end if;
		end if;
	end process;

	TAPEACC  <= tapeacc3_i;

	KEYSCANENB <= keyenb;

end RTL;
