--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FDUNIT is
	port (
		A			: in  std_logic_vector(15 downto 0);
		DI			: in  std_logic_vector(7 downto 0);
		MREQN		: in  std_logic;
		IORQN		: in  std_logic;
		RDN			: in  std_logic;
		WRN			: in  std_logic;
		CTRL_A		: in  std_logic_vector(15 downto 0);
		CTRL_DI		: in  std_logic_vector(7 downto 0);
		CTRL_RDN	: in  std_logic;
		CTRL_WRN	: in  std_logic;
		FDEXTSEL	: in  std_logic;
		DMADIR		: in  std_logic;
		DMAONN		: in  std_logic;
		DMASIZE		: in  std_logic_vector(7 downto 0);
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
		MK2P66M		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(7 downto 0);
		CTRL_DO		: out std_logic_vector(7 downto 0);
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
end FDUNIT;

architecture RTL of FDUNIT is

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

	component SPRAM_4096W8B is
		port (
			address	: in  std_logic_vector(11 downto 0);
			data	: in  std_logic_vector(7 downto 0);
			wren	: in  std_logic;
			clock	: in  std_logic;
			aclr	: in  std_logic;
			q		: out std_logic_vector(7 downto 0)
		);
	end component;

	component PIO8255M1 is
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
	end component;

	signal csn_fdc		: std_logic;
	signal do_fdc		: std_logic_vector(7 downto 0);

	signal bufrd_wr		: std_logic;
	signal bufwr_wr		: std_logic;
	signal bufrd_q		: std_logic_vector(7 downto 0);
	signal bufwr_q		: std_logic_vector(7 downto 0);

	signal aclr			: std_logic;

	signal csn_fdpio	: std_logic;
	signal csn_p6pio	: std_logic;
	signal do_fdpio		: std_logic_vector(7 downto 0);

	signal p6pio_pbo	: std_logic_vector(7 downto 0);
	signal p6pio_pco	: std_logic_vector(3 downto 0);
	signal p6pio_pai	: std_logic_vector(7 downto 0);
	signal p6pio_pci	: std_logic_vector(3 downto 0);
	signal fdpio_pbo	: std_logic_vector(7 downto 0);
	signal fdpio_pco	: std_logic_vector(3 downto 0);

begin

	U_FDC765 : FDC765
	port map (
		A0			=> CTRL_A(0),
		DI			=> CTRL_DI,
		CSN			=> csn_fdc,
		RDN			=> CTRL_RDN,
		WRN			=> CTRL_WRN,
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


	csn_fdc <=	'0' when (CTRL_A = X"9FF4") else
				'0' when (CTRL_A = X"9FF5") else
				'1';


	U_SPRAM_4096W8B_RD : SPRAM_4096W8B
	port map (
		address	=> CTRL_A(11 downto 0),
		data	=> CTRL_DI,
		wren	=> bufrd_wr,
		clock	=> CLK,
		aclr	=> aclr,
		q		=> bufrd_q
	);

	U_SPRAM_4096W8B_WR : SPRAM_4096W8B
	port map (
		address	=> CTRL_A(11 downto 0),
		data	=> CTRL_DI,
		wren	=> bufwr_wr,
		clock	=> CLK,
		aclr	=> aclr,
		q		=> bufwr_q
	);

	bufrd_wr  <= '1' when (CTRL_A(15 downto 12) = "1011" and CTRL_WRN = '0') else '0';
	bufwr_wr  <= '1' when (CTRL_A(15 downto 12) = "1010" and CTRL_WRN = '0') else '0';

	aclr     <= not RSTN;

	CTRL_DO  <= bufrd_q  when (CTRL_A(15 downto 12) = "1011") else
				bufwr_q  when (CTRL_A(15 downto 12) = "1010") else
				do_fdpio when (CTRL_A(15 downto  2) = (X"9FF" & "00")) else
				do_fdc;


	U_PIO8255M1_FD : PIO8255M1
	port map (
		A1		=> CTRL_A(1),
		A0		=> CTRL_A(0),
		DI		=> CTRL_DI,
		CSN		=> csn_fdpio,
		RDN		=> CTRL_RDN,
		WRN		=> CTRL_WRN,
		PAI		=> p6pio_pbo,
		PCI		=> p6pio_pco,
		CLK		=> CLK,
		RSTN	=> RSTN,
		DO		=> do_fdpio,
		PBO		=> fdpio_pbo,
		PCO		=> fdpio_pco
	);

	csn_fdpio <= '0' when (CTRL_A(15 downto 2) = (X"9FF" & "00")) else '1';


	U_PIO8255M1_P6 : PIO8255M1
	port map (
		A1		=> A(1),
		A0		=> A(0),
		DI		=> DI,
		CSN		=> csn_p6pio,
		RDN		=> RDN,
		WRN		=> WRN,
		PAI		=> p6pio_pai,
		PCI		=> p6pio_pci,
		CLK		=> CLK,
		RSTN	=> RSTN,
		DO		=> DO,
		PBO		=> p6pio_pbo,
		PCO		=> p6pio_pco
	);

	p6pio_pai <= fdpio_pbo when (FDD0(0) = '1' or FDD1(0) = '1') else (others => '1');
	p6pio_pci <= fdpio_pco when (FDD0(0) = '1' or FDD1(0) = '1') else (others => '1');

	csn_p6pio <=
		'0' when (FDEXTSEL = '1' and A(7 downto 4) = "1101"  and IORQN = '0' and MK2P66M = '0') else
		'0' when (FDEXTSEL = '1' and A(7 downto 3) = "11010" and IORQN = '0') else
		'1';

end RTL;
