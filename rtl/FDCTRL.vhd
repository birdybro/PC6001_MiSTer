--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FDCTRL is
	port (
		A			: in  std_logic_vector(15 downto 0);
		DI			: in  std_logic_vector(7 downto 0);
		MREQN		: in  std_logic;
		IORQN		: in  std_logic;
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		CTRL_A		: in  std_logic_vector(9 downto 0);
		CTRL_DI		: in  std_logic_vector(7 downto 0);
		CTRL_RDN	: in  std_logic;
		CTRL_WRN	: in  std_logic;
		FDEXTSEL	: in  std_logic;
		DMADIR		: in  std_logic;
		DMAONN		: in  std_logic;
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
		MK2MODE		: in  std_logic;
		P66MODE		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(7 downto 0);
		CTRL_DO		: out std_logic_vector(7 downto 0);
		FDINT		: out std_logic;
		DMASIZE		: out std_logic_vector(3 downto 0);
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
end FDCTRL;

architecture RTL of FDCTRL is

	component FDC765 is
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
	end component;

	component SPRAM_1024W8B is
		port (
			address	: in  std_logic_vector(9 downto 0);
			data	: in  std_logic_vector(7 downto 0);
			wren	: in  std_logic;
			clock	: in  std_logic;
			aclr	: in  std_logic;
			q		: out std_logic_vector(7 downto 0)
		);
	end component;

	signal csn_fdc		: std_logic;
	signal do_fdc		: std_logic_vector(7 downto 0);

	signal buf_add		: std_logic_vector(9 downto 0);
	signal buf_dat		: std_logic_vector(7 downto 0);
	signal buf_wr		: std_logic;
	signal buf_q		: std_logic_vector(7 downto 0);

	signal aclr			: std_logic;

	signal iorqn_f1		: std_logic;
	signal iorqn_f2		: std_logic;
	signal wrn_f1		: std_logic;
	signal wrn_f2		: std_logic;
	signal iowrn_f		: std_logic;

	signal dmasize_i	: std_logic_vector(3 downto 0);

begin

	U_FDC765 : FDC765
	port map (
		A0			=> A(0),
		DI			=> DI,
		CSN			=> csn_fdc,
		RDN			=> RDN,
		WRN			=> WRN,
		FDD0		=> FDD0,
		FDD1		=> FDD1,
		FLOPPY0		=> FLOPPY0,
		FLOPPY1		=> FLOPPY1,
		ST0			=> ST0,
		ST1			=> ST1,
		ST2			=> ST2,
		RST_C		=> RST_C,
		RST_H		=> RST_H,
		RST_R		=> RST_R,
		RST_N		=> RST_N,
		ENDTRG		=> ENDTRG,
		CLK			=> CLK,
		RSTN		=> RSTN,
		DO			=> do_fdc,
		FDINT		=> FDINT,
		COMMAND		=> COMMAND,
		COMEND		=> COMEND,
		MT			=> MT,
		MF			=> MF,
		SK			=> SK,
		DNUM		=> DNUM,
		HNUM		=> HNUM,
		IDRC		=> IDRC,
		IDRH		=> IDRH,
		IDRR		=> IDRR,
		IDRN		=> IDRN,
		EOT			=> EOT,
		GPL			=> GPL,
		DTL			=> DTL,
		CNUM0		=> CNUM0,
		CNUM1		=> CNUM1,
		FDCACT		=> FDCACT,
		FDCCNUM		=> FDCCNUM,
		FDCSNUM		=> FDCSNUM,
		MONOUT		=> MONOUT
	);


	csn_fdc <=	'1'    when (FDEXTSEL = '1') else
				'0'    when (A(7 downto 1) = "1101110" and iorqn_f1 = '0') else
				'1';

	DO      <=	X"FF"  when (FDEXTSEL = '1') else
				do_fdc when (A(7 downto 0) = "11011100") else
				do_fdc when (A(7 downto 0) = "11011101") else
				X"FC"  when (A(7 downto 0) = "11010100") else
				buf_q  when (A(7 downto 2) = "110100") else
				X"FF";


	U_SPRAM_1024W8B : SPRAM_1024W8B
	port map (
		address	=> buf_add,
		data	=> buf_dat,
		wren	=> buf_wr,
		clock	=> CLK,
		aclr	=> aclr,
		q		=> buf_q
	);

	buf_add <=	CTRL_A when (FDEXTSEL = '0' and DMAONN = '0') else
				A(1 downto 0) & A(15 downto 8);

	buf_dat <=	CTRL_DI  when (FDEXTSEL = '0' and DMAONN = '0') else
				DI;

	buf_wr  <=	'0'          when (FDEXTSEL = '1') else
				not CTRL_WRN when (DMAONN = '0' and DMADIR = '1') else
				'1'          when (DMAONN = '1' and A(7 downto 2) = "110100" and iowrn_f = '1') else
				'0'          when (DMAONN = '1') else
				'0';

	aclr     <= not RSTN;

	CTRL_DO  <= buf_q;

-- DMA size (port 0xDA)
	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			dmasize_i <= "0000";
		elsif (CLK'event and CLK = '1') then
			if (FDEXTSEL = '0' and A(7 downto 0) = "11011010" and iowrn_f = '1') then
				dmasize_i <= DI(3 downto 0);
			end if;
		end if;
	end process;


	DMASIZE <= dmasize_i;


-- AD/DT latch
	process (CLK,RSTN)
	begin
		if (rstn = '0') then
			iorqn_f1 <= '1';
			iorqn_f2 <= '1';
			wrn_f1   <= '1';
			wrn_f2   <= '1';
		elsif (CLK'event and CLK = '1') then
			iorqn_f1 <= IORQN;
			iorqn_f2 <= iorqn_f1;
			wrn_f1   <= WRN;
			wrn_f2   <= wrn_f1;
		end if;
	end process;

	iowrn_f <= '1' when (iorqn_f1 = '0' and wrn_f1 = '0' and (iorqn_f2 = '1' or wrn_f2 = '1')) else '0';

end RTL;
