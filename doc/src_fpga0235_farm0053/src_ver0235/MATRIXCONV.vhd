--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MATRIXCONV is
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
end MATRIXCONV;

architecture RTL of MATRIXCONV is

	component MATRIXROM is
		port (
			address	: in  std_logic_vector(10 downto 0);
			clock	: in  std_logic;
			aclr	: in  std_logic;
			q		: out std_logic_vector(8 downto 0)
		);
	end component;

	signal aclr		: std_logic;

	signal keyb1	: std_logic_vector(7 downto 0);
	signal keyb2	: std_logic_vector(7 downto 0);
	signal keyb3	: std_logic_vector(7 downto 0);
	signal keyb4	: std_logic_vector(7 downto 0);
	signal keyb5	: std_logic_vector(7 downto 0);
	signal keyb6	: std_logic_vector(7 downto 0);
	signal keyb7	: std_logic_vector(7 downto 0);
	signal keyb8	: std_logic_vector(7 downto 0);
	signal keyb9	: std_logic_vector(7 downto 0);
	signal keyb		: std_logic_vector(7 downto 0);

	signal sftkey	: std_logic_vector(3 downto 0);
	signal p2enc	: std_logic_vector(2 downto 0);
	signal p2mask	: std_logic_vector(7 downto 0);
	signal keyxor	: std_logic_vector(7 downto 0);
	signal addh		: std_logic_vector(3 downto 0);
	signal keybef	: std_logic_vector(7 downto 0);

	signal p2enclast: std_logic_vector(2 downto 0);
	signal addhlast	: std_logic_vector(3 downto 0);


	signal romadd	: std_logic_vector(10 downto 0);
	signal romdt	: std_logic_vector(8 downto 0);

	signal keydata_i	: std_logic_vector(7 downto 0);
	signal keyfunc_i	: std_logic_vector(7 downto 0);
	signal outenb_i		: std_logic;
	signal matsel_i		: std_logic_vector(3 downto 0);
	signal kana_i		: std_logic;
	signal hira_i		: std_logic;

	signal kanatg_f1	: std_logic;
	signal hiratg_f1	: std_logic;

	signal datalastenb_i: std_logic;
	signal datalast_i	: std_logic_vector(7 downto 0);
	signal funclast_i	: std_logic_vector(7 downto 0);

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
--	P1=8	RET	ST	↑	↓	→	←	TAB	ESC
--			RUN	OP
--	P1=9	か	INS	DEL	PA	HOME MO CA
--			な			GE	CLR  DE PS


	U_MATRIXROM : MATRIXROM
	port map (
		address	=> romadd,
		clock	=> CLK,
		aclr	=> aclr,
		q		=> romdt
	);

	aclr <= not RSTN;


-- a(9:6) -> P1 1-9
--
-- a(5:3)	"111":カタカナSHIFT
--			"110":カタカナ
--			"101":ひらがなSHIFT
--			"100":ひらがな
--			"011":GRAPH
--			"010":CTRL
--			"001":SHIFT
--			"000":NORMAL
--
-- a(2:0) -> P2 b0-7

	romadd <= addh & sftkey & p2enc;


-- shift key search
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sftkey <= "0000";
		elsif (CLK'event and CLK = '1') then
			if (KEYENB = '0') then
				sftkey <= "0000";
			elsif (STCNT = X"07") then
				if    (kana_i = '1' and hira_i = '0' and KEYMAT(3) = '1') then	-- カタカナ + GRAPH
					sftkey <= "1011";
				elsif (kana_i = '1' and hira_i = '0' and KEYMAT(1) = '1') then	-- カタカナ + CTRL
					sftkey <= "1010";
				elsif (kana_i = '1' and hira_i = '1' and KEYMAT(3) = '1') then	-- ひらがな + GRAPH
					sftkey <= "1001";
				elsif (kana_i = '1' and hira_i = '1' and KEYMAT(1) = '1') then	-- ひらがな + CTRL
					sftkey <= "1000";
				elsif (kana_i = '1' and hira_i = '0' and KEYMAT(2) = '1') then	-- カタカナ + SHIFT
					sftkey <= "0111";
				elsif (kana_i = '1' and hira_i = '0' and KEYMAT(2) = '0') then	-- カタカナ
					sftkey <= "0110";
				elsif (kana_i = '1' and hira_i = '1' and KEYMAT(2) = '1') then	-- ひらがな + SHIFT
					sftkey <= "0101";
				elsif (kana_i = '1' and hira_i = '1' and KEYMAT(2) = '0') then	-- ひらがな
					sftkey <= "0100";
				elsif (kana_i = '0' and                  KEYMAT(3) = '1') then	-- GRAPH
					sftkey <= "0011";
				elsif (kana_i = '0' and                  KEYMAT(1) = '1') then	-- CTRL
					sftkey <= "0010";
				elsif (kana_i = '0' and                  KEYMAT(2) = '1') then	-- SHIFT
					sftkey <= "0001";
				elsif (kana_i = '0' and                  KEYMAT(2) = '0') then	-- NORMAL
					sftkey <= "0000";
				end if;
			end if;
		end if;
	end process;


	addh <= "0000" when STCNT(6 downto 3) = "0001" else
			"0001" when STCNT(6 downto 3) = "0010" else
			"0010" when STCNT(6 downto 3) = "0011" else
			"0011" when STCNT(6 downto 3) = "0100" else
			"0100" when STCNT(6 downto 3) = "0101" else
			"0101" when STCNT(6 downto 3) = "0110" else
			"0110" when STCNT(6 downto 3) = "0111" else
			"0111" when STCNT(6 downto 3) = "1000" else
			"1000";

	keyb <= keyb1 when STCNT(6 downto 3) = "0001" else
			keyb2 when STCNT(6 downto 3) = "0010" else
			keyb3 when STCNT(6 downto 3) = "0011" else
			keyb4 when STCNT(6 downto 3) = "0100" else
			keyb5 when STCNT(6 downto 3) = "0101" else
			keyb6 when STCNT(6 downto 3) = "0110" else
			keyb7 when STCNT(6 downto 3) = "0111" else
			keyb8 when STCNT(6 downto 3) = "1000" else
			keyb9;

	keyxor <= (KEYMAT xor keyb) and KEYMAT;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			p2enc  <= "000";
			p2mask <= "11111111";
		elsif (CLK'event and CLK = '1') then

			if    (keyxor(7) = '1') then
				p2enc  <= "111";
				p2mask <= "10000000";
			elsif (keyxor(6) = '1') then
				p2enc  <= "110";
				p2mask <= "01000000";
			elsif (keyxor(5) = '1') then
				p2enc  <= "101";
				p2mask <= "00100000";
			elsif (keyxor(4) = '1') then
				p2enc  <= "100";
				p2mask <= "00010000";
			elsif (keyxor(3) = '1') then
				p2enc  <= "011";
				p2mask <= "00001000";
			elsif (keyxor(2) = '1') then
				p2enc  <= "010";
				p2mask <= "00000100";
			elsif (keyxor(1) = '1') then
				p2enc  <= "001";
				p2mask <= "00000010";
			elsif (keyxor(0) = '1') then
				p2enc  <= "000";
				p2mask <= "00000001";
			else
				p2enc  <= p2enclast;
				p2mask <= "11111111";
			end if;

		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			outenb_i  <= '0';
			keydata_i <= (others => '0');
			keyfunc_i <= (others => '0');
			keybef    <= (others => '0');
			keyb1     <= (others => '0');
			keyb2     <= (others => '0');
			keyb3     <= (others => '0');
			keyb4     <= (others => '0');
			keyb5     <= (others => '0');
			keyb6     <= (others => '0');
			keyb7     <= (others => '0');
			keyb8     <= (others => '0');
			keyb9     <= (others => '0');
			kana_i    <= '0';
			hira_i    <= '1';
			p2enclast <= "000";
			addhlast  <= (others => '0');
			datalastenb_i <= '0';
			datalast_i <= (others => '0');
			funclast_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (KEYENB = '1') then
				if (STCNT = X"01") then
					outenb_i  <= '0';
					keydata_i <= X"00";
					keyfunc_i <= X"00";
				elsif (STCNT(2 downto 0) = "110") then
					if (outenb_i = '0') then
						keybef <= KEYMAT and ((not keyxor) or p2mask);
					else
						keybef <= KEYMAT and (not keyxor);
					end if;
				elsif (STCNT(2 downto 0) = "111" and STCNT(6 downto 3) /= "0000") then
					if (keyxor /= "00000000" and outenb_i = '0') then
						if    (romdt = X"1FE") then		-- かな
							kana_i <= not kana_i;
						elsif (romdt = X"1FC") then		-- SHIFT + PAGE
							hira_i <= not hira_i;
						end if;

						if (MK2MODE = '0' and X"1FB" <= romdt and romdt <= X"1FE") then
							null;
						else
							outenb_i  <= '1';
							keydata_i <= romdt(7 downto 0);
							if (romdt(8) = '1') then
								keyfunc_i <= X"14";		-- interrupt2
							else
								keyfunc_i <= X"02";		-- interrupt3
							end if;
							p2enclast <= p2enc;
							addhlast  <= addh;
						end if;
					else
						if (addh = addhlast) then
							if (keyb(conv_integer(p2enclast)) = '1') then
								datalastenb_i <= '1';
								datalast_i <= romdt(7 downto 0);
								if (romdt(8) = '1') then
									funclast_i <= X"14";		-- interrupt2
								else
									funclast_i <= X"02";		-- interrupt3
								end if;
							else
								datalastenb_i <= '0';
								datalast_i <= (others => '0');
								funclast_i <= (others => '0');
							end if;
						end if;
					end if;
					if    (STCNT(6 downto 3) = "0001") then
						keyb1 <= keybef;
					elsif (STCNT(6 downto 3) = "0010") then
						keyb2 <= keybef;
					elsif (STCNT(6 downto 3) = "0011") then
						keyb3 <= keybef;
					elsif (STCNT(6 downto 3) = "0100") then
						keyb4 <= keybef;
					elsif (STCNT(6 downto 3) = "0101") then
						keyb5 <= keybef;
					elsif (STCNT(6 downto 3) = "0110") then
						keyb6 <= keybef;
					elsif (STCNT(6 downto 3) = "0111") then
						keyb7 <= keybef;
					elsif (STCNT(6 downto 3) = "1000") then
						keyb8 <= keybef;
					elsif (STCNT(6 downto 3) = "1001") then
						keyb9 <= keybef;
					end if;
				end if;
			else
				if (MK2MODE = '1') then
					if    (KANATG = '1' and kanatg_f1 = '0') then
						kana_i <= not kana_i;
					elsif (HIRATG = '1' and hiratg_f1 = '0') then
						hira_i <= not hira_i;
					end if;
				end if;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			kanatg_f1 <= '0';
			hiratg_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			kanatg_f1 <= KANATG;
			hiratg_f1 <= HIRATG;
		end if;
	end process;



	matsel_i <= STCNT(6 downto 3);

	KEYDATA		<= keydata_i;
	KEYFUNC		<= keyfunc_i;
	OUTENB		<= outenb_i;
	MATSEL      <= matsel_i;
	KANA		<= kana_i;
	HIRA		<= hira_i;

	DATALASTENB <= datalastenb_i;
	DATALAST    <= datalast_i;
	FUNCLAST    <= funclast_i;

end RTL;
