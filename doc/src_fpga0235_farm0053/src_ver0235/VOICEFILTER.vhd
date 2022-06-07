--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity VOICEFILTER is
	port (
		DI			: in  std_logic_vector(13 downto 0);
		F1			: in  std_logic_vector(6 downto 0);
		F2			: in  std_logic_vector(6 downto 0);
		F3			: in  std_logic_vector(6 downto 0);
		F4			: in  std_logic_vector(6 downto 0);
		F5			: in  std_logic_vector(6 downto 0);
		B1			: in  std_logic_vector(5 downto 0);
		B2			: in  std_logic_vector(5 downto 0);
		B3			: in  std_logic_vector(5 downto 0);
		B4			: in  std_logic_vector(5 downto 0);
		B5			: in  std_logic_vector(5 downto 0);
		ENB			: in  std_logic;
		SRST		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(13 downto 0)
	);
end VOICEFILTER;

architecture RTL of VOICEFILTER is

	signal maincnt	: std_logic_vector(11 downto 0);

	signal mulp		: std_logic;
	signal atp1		: std_logic;
	signal atp2		: std_logic;
	signal atp3		: std_logic;
	signal atp4		: std_logic;
	signal atp5		: std_logic;

	signal b1ad		: std_logic_vector(12 downto 0);
	signal b2ad		: std_logic_vector(5 downto 0);
	signal b1dt		: std_logic_vector(9 downto 0);
	signal b2dt		: std_logic_vector(9 downto 0);
	signal rstp		: std_logic;
	signal b1out	: std_logic_vector(13 downto 0);
	signal b2out	: std_logic_vector(13 downto 0);

	signal mli1		: std_logic_vector(13 downto 0);
	signal mli2		: std_logic_vector(13 downto 0);

	signal b1out1lt	: std_logic_vector(13 downto 0);
	signal b1out2lt	: std_logic_vector(13 downto 0);
	signal b1out3lt	: std_logic_vector(13 downto 0);
	signal b1out4lt	: std_logic_vector(13 downto 0);
	signal b1out5lt	: std_logic_vector(13 downto 0);
	signal b2out1lt	: std_logic_vector(13 downto 0);
	signal b2out2lt	: std_logic_vector(13 downto 0);
	signal b2out3lt	: std_logic_vector(13 downto 0);
	signal b2out4lt	: std_logic_vector(13 downto 0);
	signal b2out5lt	: std_logic_vector(13 downto 0);

	signal addout1	: std_logic_vector(13 downto 0);
	signal addout2	: std_logic_vector(13 downto 0);
	signal addout3	: std_logic_vector(13 downto 0);
	signal addout4	: std_logic_vector(13 downto 0);
	signal addout5	: std_logic_vector(13 downto 0);

	signal dv1_d1	: std_logic_vector(13 downto 0);
	signal dv1_d2	: std_logic_vector(13 downto 0);
	signal dv1_q	: std_logic_vector(13 downto 0);
	signal dv2_d1	: std_logic_vector(13 downto 0);
	signal dv2_d2	: std_logic_vector(13 downto 0);
	signal dv2_q	: std_logic_vector(13 downto 0);
	signal dv3_d1	: std_logic_vector(13 downto 0);
	signal dv3_d2	: std_logic_vector(13 downto 0);
	signal dv3_q	: std_logic_vector(13 downto 0);
	signal dv4_d1	: std_logic_vector(13 downto 0);
	signal dv4_d2	: std_logic_vector(13 downto 0);
	signal dv4_q	: std_logic_vector(13 downto 0);
	signal dv5_d1	: std_logic_vector(13 downto 0);
	signal dv5_d2	: std_logic_vector(13 downto 0);
	signal dv5_q	: std_logic_vector(13 downto 0);

	signal do_i		: std_logic_vector(13 downto 0);

	component VOICEB1ROM is
		port (
			aclr	: in std_logic;
			address	: in std_logic_vector(12 downto 0);
			clock	: in std_logic;
			q		: out std_logic_vector(9 downto 0)
		);
	end component;

	component VOICEB2ROM is
		port (
			aclr	: in std_logic;
			address	: in std_logic_vector(5 downto 0);
			clock	: in std_logic;
			q		: out std_logic_vector(9 downto 0)
		);
	end component;

	component VOICEFILTER_MUL is
		port (
			DI			: in  std_logic_vector(13 downto 0);
			F			: in  std_logic_vector(9 downto 0);
			START		: in  std_logic;
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			DO			: out std_logic_vector(13 downto 0)
		);
	end component;

	component VOICEFILTER_ADD is
		port (
			A			: in  std_logic_vector(13 downto 0);
			B			: in  std_logic_vector(13 downto 0);
			C			: in  std_logic_vector(13 downto 0);
			DO			: out std_logic_vector(13 downto 0)
		);
	end component;

begin

-- control counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			maincnt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				maincnt <= (others => '0');
			elsif (ENB = '1') then
				maincnt <= X"001";
			elsif (maincnt /= 0) then
				maincnt <= maincnt + 1;
			end if;
		end if;
	end process;

	mulp <=	'1' when (maincnt(11 downto 5) = 0 and maincnt(4 downto 0) = 3) else
			'1' when (maincnt(11 downto 5) = 1 and maincnt(4 downto 0) = 3) else
			'1' when (maincnt(11 downto 5) = 2 and maincnt(4 downto 0) = 3) else
			'1' when (maincnt(11 downto 5) = 3 and maincnt(4 downto 0) = 3) else
			'1' when (maincnt(11 downto 5) = 4 and maincnt(4 downto 0) = 3) else
			'0';

	atp1 <=	'1' when (maincnt(11 downto 5) = 0 and maincnt(4 downto 0) = 29) else '0';
	atp2 <=	'1' when (maincnt(11 downto 5) = 1 and maincnt(4 downto 0) = 29) else '0';
	atp3 <=	'1' when (maincnt(11 downto 5) = 2 and maincnt(4 downto 0) = 29) else '0';
	atp4 <=	'1' when (maincnt(11 downto 5) = 3 and maincnt(4 downto 0) = 29) else '0';
	atp5 <=	'1' when (maincnt(11 downto 5) = 4 and maincnt(4 downto 0) = 29) else '0';


	b1ad <=	F1 & B1 when (maincnt(11 downto 5) = 0) else
			F2 & B2 when (maincnt(11 downto 5) = 1) else
			F3 & B3 when (maincnt(11 downto 5) = 2) else
			F4 & B4 when (maincnt(11 downto 5) = 3) else
			F5 & B5 when (maincnt(11 downto 5) = 4) else
			(others => '0');

	b2ad <=	B1 when (maincnt(11 downto 5) = 0) else
			B2 when (maincnt(11 downto 5) = 1) else
			B3 when (maincnt(11 downto 5) = 2) else
			B4 when (maincnt(11 downto 5) = 3) else
			B5 when (maincnt(11 downto 5) = 4) else
			(others => '0');

	mli1 <=	dv1_d1 when (maincnt(11 downto 5) = 0) else
			dv2_d1 when (maincnt(11 downto 5) = 1) else
			dv3_d1 when (maincnt(11 downto 5) = 2) else
			dv4_d1 when (maincnt(11 downto 5) = 3) else
			dv5_d1 when (maincnt(11 downto 5) = 4) else
			(others => '0');

	mli2 <=	dv1_d2 when (maincnt(11 downto 5) = 0) else
			dv2_d2 when (maincnt(11 downto 5) = 1) else
			dv3_d2 when (maincnt(11 downto 5) = 2) else
			dv4_d2 when (maincnt(11 downto 5) = 3) else
			dv5_d2 when (maincnt(11 downto 5) = 4) else
			(others => '0');


	UVOICEB1ROM : VOICEB1ROM
	port map (
		aclr	=> rstp,
		address	=> b1ad,
		clock	=> CLK,
		q		=> b1dt
	);

	UVOICEB2ROM : VOICEB2ROM
	port map (
		aclr	=> rstp,
		address	=> b2ad,
		clock	=> CLK,
		q		=> b2dt
	);

	rstp <= not rstn;


	UFILTER_MUL : VOICEFILTER_MUL
	port map (
		DI			=> mli1,
		F			=> b1dt,
		START		=> mulp,
		CLK			=> CLK,
		RSTN		=> RSTN,
		DO			=> b1out
	);

	UFILTER_MUL2 : VOICEFILTER_MUL
	port map (
		DI			=> mli2,
		F			=> b2dt,
		START		=> mulp,
		CLK			=> CLK,
		RSTN		=> RSTN,
		DO			=> b2out
	);


-- data latch #1
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			b1out1lt <= (others => '0');
			b2out1lt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				b1out1lt <= (others => '0');
				b2out1lt <= (others => '0');
			elsif (atp1 = '1') then
				b1out1lt <= b1out;
				b2out1lt <= b2out;
			end if;
		end if;
	end process;

	UFILTER_ADD1 : VOICEFILTER_ADD
	port map (
		A			=> DI,
		B			=> b1out1lt,
		C			=> b2out1lt,
		DO			=> addout1
	);

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv1_q <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			dv1_q <= addout1;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv1_d1 <= (others => '0');
			dv1_d2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				dv1_d1 <= (others => '0');
				dv1_d2 <= (others => '0');
			elsif (ENB = '1') then
				dv1_d1 <= dv1_q;
				dv1_d2 <= dv1_d1;
			end if;
		end if;
	end process;


-- data latch #2
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			b1out2lt <= (others => '0');
			b2out2lt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				b1out2lt <= (others => '0');
				b2out2lt <= (others => '0');
			elsif (atp2 = '1') then
				b1out2lt <= b1out;
				b2out2lt <= b2out;
			end if;
		end if;
	end process;

	UFILTER_ADD2 : VOICEFILTER_ADD
	port map (
		A			=> dv1_q,
		B			=> b1out2lt,
		C			=> b2out2lt,
		DO			=> addout2
	);

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv2_q <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			dv2_q <= addout2;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv2_d1 <= (others => '0');
			dv2_d2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				dv2_d1 <= (others => '0');
				dv2_d2 <= (others => '0');
			elsif (ENB = '1') then
				dv2_d1 <= dv2_q;
				dv2_d2 <= dv2_d1;
			end if;
		end if;
	end process;


-- data latch #3
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			b1out3lt <= (others => '0');
			b2out3lt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				b1out3lt <= (others => '0');
				b2out3lt <= (others => '0');
			elsif (atp3 = '1') then
				b1out3lt <= b1out;
				b2out3lt <= b2out;
			end if;
		end if;
	end process;

	UFILTER_ADD3 : VOICEFILTER_ADD
	port map (
		A			=> dv2_q,
		B			=> b1out3lt,
		C			=> b2out3lt,
		DO			=> addout3
	);

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv3_q <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			dv3_q <= addout3;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv3_d1 <= (others => '0');
			dv3_d2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				dv3_d1 <= (others => '0');
				dv3_d2 <= (others => '0');
			elsif (ENB = '1') then
				dv3_d1 <= dv3_q;
				dv3_d2 <= dv3_d1;
			end if;
		end if;
	end process;


-- data latch #4
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			b1out4lt <= (others => '0');
			b2out4lt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				b1out4lt <= (others => '0');
				b2out4lt <= (others => '0');
			elsif (atp4 = '1') then
				b1out4lt <= b1out;
				b2out4lt <= b2out;
			end if;
		end if;
	end process;

	UFILTER_ADD4 : VOICEFILTER_ADD
	port map (
		A			=> dv3_q,
		B			=> b1out4lt,
		C			=> b2out4lt,
		DO			=> addout4
	);

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv4_q <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			dv4_q <= addout4;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv4_d1 <= (others => '0');
			dv4_d2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				dv4_d1 <= (others => '0');
				dv4_d2 <= (others => '0');
			elsif (ENB = '1') then
				dv4_d1 <= dv4_q;
				dv4_d2 <= dv4_d1;
			end if;
		end if;
	end process;


-- data latch #5
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			b1out5lt <= (others => '0');
			b2out5lt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				b1out5lt <= (others => '0');
				b2out5lt <= (others => '0');
			elsif (atp5 = '1') then
				b1out5lt <= b1out;
				b2out5lt <= b2out;
			end if;
		end if;
	end process;

	UFILTER_ADD5 : VOICEFILTER_ADD
	port map (
		A			=> dv4_q,
		B			=> b1out5lt,
		C			=> b2out5lt,
		DO			=> addout5
	);

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv5_q <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			dv5_q <= addout5;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dv5_d1 <= (others => '0');
			dv5_d2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				dv5_d1 <= (others => '0');
				dv5_d2 <= (others => '0');
			elsif (ENB = '1') then
				dv5_d1 <= dv5_q;
				dv5_d2 <= dv5_d1;
			end if;
		end if;
	end process;


-- output latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			do_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (SRST = '1') then
				do_i <= (others => '0');
			elsif (ENB = '1') then
				do_i <= dv5_q;
			end if;
		end if;
	end process;

	DO <= do_i;

end RTL;
