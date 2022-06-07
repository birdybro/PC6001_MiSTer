-- PC6001 top module
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity PC6001 is
	port (
		DRAM_D			: inout std_logic_vector(15 downto 0);	-- SDRAM data bus
		DRAM_A			: out   std_logic_vector(12 downto 0);	-- SDRAM address bus
		DRAM_CLK		: out   std_logic;						-- SDRAM clock output
		DRAM_CKE		: out   std_logic;						-- SDRAM clock enable
		DRAM_LDQM		: out   std_logic;						-- SDRAM LowerByte Data Mask
		DRAM_UDQM		: out   std_logic;						-- SDRAM UpperByte Data Mask
		DRAM_WE_N		: out   std_logic;						-- SDRAM write Enable
		DRAM_CAS_N		: out   std_logic;						-- SDRAM CAS
		DRAM_RAS_N		: out   std_logic;						-- SDRAM RAS
		DRAM_CS_N		: out   std_logic;						-- SDRAM chip select
		DRAM_BA_1		: out   std_logic;						-- SDRAM Bank #1
		DRAM_BA_0		: out   std_logic;						-- SDRAM Bank #0
		FLASH_D15_AM1	: inout std_logic;						-- FLASH data bus bit15 or adrress-1
		FLASH_D			: inout std_logic_vector(14 downto 0);	-- FLASH data bus
		FLASH_A			: out   std_logic_vector(21 downto 0);	-- FLASH adrress bus
		FLASH_WE_N		: out   std_logic;						-- FLASH write enable
		FLASH_RESET_N	: out   std_logic;						-- FLASH reset
		FLASH_WP_N		: out   std_logic;						-- FLASH write protect
		FLASH_RY		: in    std_logic;						-- FLASH ready
		FLASH_CE_N		: out   std_logic;						-- FLASH chip enable
		FLASH_OE_N		: out   std_logic;						-- FLASH output enable
		FLASH_BYTE_N	: out   std_logic;						-- FLASH byte mode
		VGA_R			: out   std_logic_vector(3 downto 0);	-- VGA red data
		VGA_G			: out   std_logic_vector(3 downto 0);	-- VGA green data
		VGA_B			: out   std_logic_vector(3 downto 0);	-- VGA blue data
		VGA_HS			: out   std_logic;						-- VGA H_SYNC
		VGA_VS			: out   std_logic;						-- VGA V_SYNC
		HEX3_D			: out   std_logic_vector(6 downto 0);	-- 7segment #3
		HEX3_DP			: out   std_logic;						-- 7segment #3 DP
		HEX2_D			: out   std_logic_vector(6 downto 0);	-- 7segment #2
		HEX2_DP			: out   std_logic;						-- 7segment #2 DP
		HEX1_D			: out   std_logic_vector(6 downto 0);	-- 7segment #1
		HEX1_DP			: out   std_logic;						-- 7segment #1 DP
		HEX0_D			: out   std_logic_vector(6 downto 0);	-- 7segment #0
		HEX0_DP			: out   std_logic;						-- 7segment #0 DP
		LEDG			: out   std_logic_vector(9 downto 0);	-- LED
		LCD_D			: inout std_logic_vector(7 downto 0);	-- LCD data bus
		LCD_BLON		: out   std_logic;						-- LCD back light on
		LCD_RS			: out   std_logic;						-- LCD command/data select
		LCD_RW			: out   std_logic;						-- LCD read/write
		LCD_EN			: out   std_logic;						-- LCD enable
		CLK50M1			: in    std_logic;						-- clock 50MHz input #1
		CLK50M0			: in    std_logic;						-- clock 50MHz input #0
		UART_RXD		: in    std_logic;						-- UART Rx
		UART_RTS		: in    std_logic;						-- UART CTS(!!)
		UART_TXD		: out   std_logic;						-- UART Tx
		UART_CTS		: out   std_logic;						-- UART RTS(!!)
		PS2_KBDAT		: inout std_logic;						-- PS2 keyboard data
		PS2_KBCLK		: inout std_logic;						-- PS2 keyboard clock
		PS2_MSDAT		: inout std_logic;						-- PS2 mouse data
		PS2_MSCLK		: inout std_logic;						-- PS2 mouse clock
		BUTTON			: in    std_logic_vector(2 downto 0);	-- push button
		SW				: in    std_logic_vector(9 downto 0);	-- DIPSW
		GPIO1_D			: inout std_logic_vector(31 downto 0);	-- GPIO #1 data
		GPIO1_CLKIN		: in    std_logic_vector(1 downto 0);	-- GPIO #1 clock input
		GPIO1_CLKOUT	: out   std_logic_vector(1 downto 0);	-- GPIO #1 clock output
		GPIO0_D			: inout std_logic_vector(31 downto 0);	-- GPIO #0 data
		GPIO0_CLKIN		: in    std_logic_vector(1 downto 0);	-- GPIO #0 clock input
		GPIO0_CLKOUT	: out   std_logic_vector(1 downto 0);	-- GPIO #0 clock output
		SD_DAT			: inout std_logic_vector(3 downto 0);	-- SD card data
		SD_CMD			: inout std_logic;						-- SD card command
		SD_CLK			: out   std_logic;						-- SD card clock output
		SD_WP_N			: in    std_logic						-- SD card write protect
	);
end PC6001;

architecture RTL of PC6001 is

	component CLKGEN is
		port (
			CLK50M1		: in  std_logic;	-- clock 50MHz input #1
			CLK50M0		: in  std_logic;	-- clock 50MHz input #0
			MK2MODE		: in  std_logic;
			RSTN		: in  std_logic;
			CLK14MOUT	: out std_logic;
			CLK16MOUT	: out std_logic;
			CLK100MOUT	: out std_logic;
			CLK100M_DI	: out std_logic;
			CLK50MOUT	: out std_logic;
			CLK25MOUT	: out std_logic;
			CLK4MOUT	: out std_logic;
			CLK4MCNTOUT	: out std_logic_vector(1 downto 0);
			CLK1SOUT	: out std_logic;
			LOCK_PLL	: out std_logic
		);
	end component;

	component RSTGEN is
		port (
			LOCK_PLL		: in  std_logic;
			SDRAM_INITDONE	: in  std_logic;
			SDCAD_INITDONE	: in  std_logic;
			CLK4MCNT		: in  std_logic_vector(1 downto 0);
			CLK100M			: in  std_logic;
			CLK50M			: in  std_logic;
			CLK16M			: in  std_logic;
			WRN				: in  std_logic;
			RSTN			: in  std_logic;
			SDRAM_INIT		: out std_logic;
			SDCAD_INIT		: out std_logic;
			SDCAD_INIT2		: out std_logic;
			CPU_RSTN		: out std_logic;
			PIO_RSTN		: out std_logic
		);
	end component;

	component CTRLROM_WRAP is
		port (
			ADDRESS	: in  std_logic_vector(13 downto 0);
			DATA	: in  std_logic_vector(7 downto 0);
			RDN		: in  std_logic;
			WRN		: in  std_logic;
			CLK		: in  std_logic;
			RSTN	: in  std_logic;
			Q		: out std_logic_vector(7 downto 0)
		);
	end component;

	component CTRLVRAM_WRAP is
		port (
			ADDA		: in  std_logic_vector(9 downto 0);
			DATA		: in  std_logic_vector(7 downto 0);
			RDAN		: in  std_logic;
			WRAN		: in  std_logic;
			ADDB		: in  std_logic_vector(9 downto 0);
			RDBN		: in  std_logic;
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			QA			: out std_logic_vector(7 downto 0);
			QB			: out std_logic_vector(7 downto 0)
		);
	end component;

	component SDREADIF is
		port (
			SD_DAT0		: in  std_logic;						-- from SD card
			SD_WP		: in  std_logic;						-- from SD card
			ADD			: in  std_logic_vector(9 downto 0);		-- from CPU
			DATAI		: in  std_logic_vector(7 downto 0);		-- from CPU
			WRN			: in  std_logic;						-- from CPU
			RDN			: in  std_logic;						-- from CPU
			CMTRDOPEN	: in  std_logic;						-- from 8049
			CMTRDREQ	: in  std_logic;						-- from 8049
			CMTRDACC	: in  std_logic;						-- from 8049
			CMTRDACCMD	: in  std_logic;
			CMTWROPEN	: in  std_logic;						-- from 8049
			CMTWRREQ	: in  std_logic;						-- from 8049
			CMTWRDT		: in  std_logic_vector(7 downto 0);		-- from 8049
			DETBLK		: in  std_logic;
			FDEXTSEL	: in  std_logic;
			DMADIR		: in  std_logic;
			DMAONN		: in  std_logic;
			DMASIZE		: in  std_logic_vector(3 downto 0);
			FDINT_EXT	: in  std_logic;						-- from EXT_FDC
			COMEND		: in  std_logic;						-- from FDC
			COMMAND		: in  std_logic_vector(4 downto 0);		-- from FDC
			MT			: in  std_logic;						-- from FDC
			MF			: in  std_logic;						-- from FDC
			SK			: in  std_logic;						-- from FDC
			DNUM		: in  std_logic_vector(1 downto 0);		-- from FDC
			HNUM		: in  std_logic;						-- from FDC
			IDRC		: in  std_logic_vector(7 downto 0);		-- from FDC
			IDRH		: in  std_logic_vector(7 downto 0);		-- from FDC
			IDRR		: in  std_logic_vector(7 downto 0);		-- from FDC
			IDRN		: in  std_logic_vector(7 downto 0);		-- from FDC
			EOT			: in  std_logic_vector(7 downto 0);		-- from FDC
			GPL			: in  std_logic_vector(7 downto 0);		-- from FDC
			DTL			: in  std_logic_vector(7 downto 0);		-- from FDC
			EXT_COMEND	: in  std_logic;						-- from EXT_FDC
			EXT_COMMAND	: in  std_logic_vector(4 downto 0);		-- from EXT_FDC
			EXT_MT		: in  std_logic;						-- from EXT_FDC
			EXT_MF		: in  std_logic;						-- from EXT_FDC
			EXT_SK		: in  std_logic;						-- from EXT_FDC
			EXT_DNUM	: in  std_logic_vector(1 downto 0);		-- from EXT_FDC
			EXT_HNUM	: in  std_logic;						-- from EXT_FDC
			EXT_IDRC	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			EXT_IDRH	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			EXT_IDRR	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			EXT_IDRN	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			EXT_EOT		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			EXT_GPL		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			EXT_DTL		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			CNUM0		: in  std_logic_vector(7 downto 0);		-- from FDC
			CNUM1		: in  std_logic_vector(7 downto 0);		-- from FDC
			CNUM2		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			CNUM3		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			FDCACT		: in  std_logic;						-- from FDC
			FDCCNUM		: in  std_logic_vector(7 downto 0);		-- from FDC
			FDCSNUM		: in  std_logic_vector(7 downto 0);		-- from FDC
			FDCEXTACT	: in  std_logic;						-- from EXT_FDC
			FDCEXTCNUM	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			FDCEXTSNUM	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
			CLK50M		: in  std_logic;
			RSTN		: in  std_logic;
			DATAO		: out std_logic_vector(7 downto 0);		-- to CPU
			SD_RDAD		: out std_logic_vector(18 downto 0);	-- to SDRAM/CGROM
			SD_RDDT		: out std_logic_vector(7 downto 0);		-- to SDRAM/CGROM
			SD_SDENB	: out std_logic;						-- to SDRAM
			SD_SDWRN	: out std_logic;						-- to SDRAM
			SD_RDDONE	: out std_logic;
			SD_ERR		: out std_logic;
			SD_OUTENB	: out std_logic;
			CMTRDRDY	: out std_logic;						-- to 8049
			CMTWRRDY	: out std_logic;						-- to 8049
			CMTRDDT		: out std_logic_vector(7 downto 0);		-- to 8049
			CMTCNT		: out std_logic_vector(15 downto 0);
			ACCCNT		: out std_logic_vector(31 downto 0);
			SD_CMD		: out std_logic;						-- to SD card
			SD_DAT		: out std_logic_vector(3 downto 1);		-- to SD card
			SD_CLK		: out std_logic;						-- to SD card
			EXT_DMADIR	: out std_logic;						-- to EXT_FDC
			EXT_DMAONN	: out std_logic;						-- to EXT_FDC
			EXT_DMASIZE	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			FDD0		: out std_logic_vector(2 downto 0);		-- to FDC
			FDD1		: out std_logic_vector(2 downto 0);		-- to FDC
			FDD2		: out std_logic_vector(2 downto 0);		-- to EXT_FDC
			FDD3		: out std_logic_vector(2 downto 0);		-- to EXT_FDC
			FLOPPY0		: out std_logic_vector(3 downto 0);		-- to FDC
			FLOPPY1		: out std_logic_vector(3 downto 0);		-- to FDC
			FLOPPY2		: out std_logic_vector(3 downto 0);		-- to EXT_FDC
			FLOPPY3		: out std_logic_vector(3 downto 0);		-- to EXT_FDC
			ST0			: out std_logic_vector(7 downto 0);		-- to FDC
			ST1			: out std_logic_vector(7 downto 0);		-- to FDC
			ST2			: out std_logic_vector(7 downto 0);		-- to FDC
			RST_C		: out std_logic_vector(7 downto 0);		-- to FDC
			RST_H		: out std_logic_vector(7 downto 0);		-- to FDC
			RST_R		: out std_logic_vector(7 downto 0);		-- to FDC
			RST_N		: out std_logic_vector(7 downto 0);		-- to FDC
			ENDTRG		: out std_logic;						-- to FDC
			EXT_ST0		: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			EXT_ST1		: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			EXT_ST2		: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			EXT_RST_C	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			EXT_RST_H	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			EXT_RST_R	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			EXT_RST_N	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
			EXT_ENDTRG	: out std_logic;						-- to EXT_FDC
			MONOUT		: out std_logic_vector(28 downto 0)
		);
	end component;

	component CTRLREG is
		port (
			ADD			: in  std_logic_vector(9 downto 0);		-- from CPU
			DATAI		: in  std_logic_vector(7 downto 0);		-- from CPU
			WRN			: in  std_logic;						-- from CPU
			RDN			: in  std_logic;						-- from CPU
			LCDMODE		: in  std_logic;
			MK2MODE		: in  std_logic;
			P66MODE		: in  std_logic;
			FUNCKEY		: in  std_logic_vector(23 downto 0);
			FPGAVER		: in  std_logic_vector(15 downto 0);
			CLK50M		: in  std_logic;
			RSTN		: in  std_logic;
			DATAO		: out std_logic_vector(7 downto 0);		-- to CPU
			LCDCS		: out std_logic;						-- to LCD controller
			LCDSDI		: out std_logic;						-- to LCD controller
			LCDSCL		: out std_logic;						-- to LCD controller
			LCDDONE		: out std_logic;
			CTRLSEL		: out std_logic;
			CTRLRSTN	: out std_logic;
			MEM16K		: out std_logic;
			SC4COLORON	: out std_logic;
			SC4COLORMD	: out std_logic_vector(3 downto 0);
			CTRLKEYDAT	: out std_logic_vector(7 downto 0);
			CTRLKEYENB	: out std_logic;
			UARTENB		: out std_logic;
			UARTLEN		: out std_logic_vector(19 downto 0);
			EXKANJIENB	: out std_logic;
			FIRMVER		: out std_logic_vector(15 downto 0);
			DBGTRG		: out std_logic_vector(7 downto 0)
		);
	end component;

	component VDGMEMCNT is
		port (
			D			: in  std_logic_vector(7 downto 0);
			CGROMD		: in  std_logic_vector(7 downto 0);
			BUSACKN		: in  std_logic;
			VRAMSW1		: in  std_logic;
			CRTKILLN	: in  std_logic;
			CLK14M		: in  std_logic;
			RSTN		: in  std_logic;
			AOUT		: out std_logic_vector(13 downto 0);
			CGAOUT		: out std_logic_vector(11 downto 0);
			BUSRQN		: out std_logic;
			VCASN		: out std_logic;
			VRASN		: out std_logic;
			RAM_RDN		: out std_logic;
			CGROM_RDN	: out std_logic;
			CGROM_ENBN	: out std_logic;
			DISPD		: out std_logic_vector(3 downto 0);
			DISPMD		: out std_logic_vector(3 downto 0);
			DISPTMG_LT	: out std_logic;					-- display data latch pulse
			DISPTMG_DT	: out std_logic;					-- display data            (256 x 192)
			DISPTMG_BD	: out std_logic;					-- display data and border (320 x 240)
			DISPTMG_HS	: out std_logic;					-- horizontal sync pulse
			DISPTMG_VS	: out std_logic						-- vertical sync pulse
		);
	end component;

	component CRTC is
		port (
			D			: in  std_logic_vector(7 downto 0);
			VRAMAD		: in  std_logic_vector(1 downto 0);
			BUSACKN		: in  std_logic;
			CRTKILLN	: in  std_logic;
			CHARMODE	: in  std_logic;	-- 0:40x20(60m) / 1:32x16
			GRAPHCHAR	: in  std_logic;	-- 0:graphic(screen3,4) / 1:character(screen1,2)
			GRAPHRESO	: in  std_logic;	-- 0:320x160 / 1:160x200
			CSS1		: in  std_logic;
			CSS2		: in  std_logic;
			CSS3		: in  std_logic;
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			AOUT		: out std_logic_vector(15 downto 0);
			RDN			: out std_logic;
			CGRD		: out std_logic;
			BUSRQN		: out std_logic;
			DISPAREAN	: out std_logic;
			HSYNCN		: out std_logic;
			VSYNCN		: out std_logic;
			CHARROWENB	: out std_logic;
			DISPD		: out std_logic_vector(3 downto 0);
			DISPMD		: out std_logic_vector(3 downto 0);
			DISPTMG_LT	: out std_logic;
			DISPTMG_DT	: out std_logic;
			DISPTMG_HS	: out std_logic;
			DISPTMG_VS	: out std_logic;
			HCNT		: out std_logic_vector(9 downto 0);
			VCNT		: out std_logic_vector(8 downto 0)
		);
	end component;

	component VGAOUT is
		port (
			DISPD		: in  std_logic_vector(3 downto 0);
			DISPMD		: in  std_logic_vector(3 downto 0);
			DISPTMG_HS	: in  std_logic;
			DISPTMG_VS	: in  std_logic;
			SC4COLORON	: in  std_logic;
			SC4COLORMD	: in  std_logic_vector(3 downto 0);
			MK2MODE		: in  std_logic;
			LCDMODE		: in  std_logic;
			LCDINITDONE	: in  std_logic;
			DISPMODE	: in  std_logic;
			RDSYNC		: in  std_logic;
			SYNCOFF		: in  std_logic;
			CLK14M		: in  std_logic;
			CLK25M		: in  std_logic;
			RSTN		: in  std_logic;
			MONOUT		: out  std_logic_vector(25 downto 0);
			BUSRQMASK	: out std_logic;
			VGA_R		: out std_logic_vector(3 downto 0);
			VGA_G		: out std_logic_vector(3 downto 0);
			VGA_B		: out std_logic_vector(3 downto 0);
			VGA_HS		: out std_logic;
			VGA_VS		: out std_logic;
			LCD_R		: out std_logic_vector(7 downto 0);
			LCD_G		: out std_logic_vector(7 downto 0);
			LCD_B		: out std_logic_vector(7 downto 0);
			LCD_HSN		: out std_logic;
			LCD_VSN		: out std_logic;
			LCD_DEN		: out std_logic;
			LCD_CLK		: out std_logic
		);
	end component;

	component T80s
		generic(
			Mode : integer := 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
			T2Write : integer := 0;	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
			IOWait : integer := 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
		);
		port(
			RESET_n		: in std_logic;
			CLK_n		: in std_logic;
			WAIT_n		: in std_logic;
			INT_n		: in std_logic;
			NMI_n		: in std_logic;
			BUSRQ_n		: in std_logic;
			M1_n		: out std_logic;
			MREQ_n		: out std_logic;
			IORQ_n		: out std_logic;
			RD_n		: out std_logic;
			WR_n		: out std_logic;
			RFSH_n		: out std_logic;
			HALT_n		: out std_logic;
			BUSAK_n		: out std_logic;
			A			: out std_logic_vector(15 downto 0);
			DI			: in std_logic_vector(7 downto 0);
			DO			: out std_logic_vector(7 downto 0)
		);
	end component;

	component SDRAM is
		port (
			DRAM_DI		: in  std_logic_vector(15 downto 0);	-- SDRAM data bus
			ADDRESS		: in  std_logic_vector(18 downto 0);
			DATA		: in  std_logic_vector(7 downto 0);
			RDN			: in  std_logic;
			WRN			: in  std_logic;
			INIT		: in  std_logic;
			MEMNOINIT	: in  std_logic;
			MEMERRMODE	: in  std_logic;
			CLK			: in  std_logic;
			CLK_DI		: in  std_logic;
			RSTN		: in  std_logic;
			DRAM_DO		: out std_logic_vector(15 downto 0);	-- SDRAM data bus
			DRAM_DOENB	: out std_logic;						-- SDRAM data output enable
			DRAM_A		: out std_logic_vector(12 downto 0);	-- SDRAM address bus
			DRAM_CLK	: out std_logic;						-- SDRAM clock output
			DRAM_CKE	: out std_logic;						-- SDRAM clock enable
			DRAM_LDQM	: out std_logic;						-- SDRAM LowerByte Data Mask
			DRAM_UDQM	: out std_logic;						-- SDRAM UpperByte Data Mask
			DRAM_WE_N	: out std_logic;						-- SDRAM write Enable
			DRAM_CAS_N	: out std_logic;						-- SDRAM CAS
			DRAM_RAS_N	: out std_logic;						-- SDRAM RAS
			DRAM_CS_N	: out std_logic;						-- SDRAM chip select
			DRAM_BA_1	: out std_logic;						-- SDRAM Bank #1
			DRAM_BA_0	: out std_logic;						-- SDRAM Bank #0
			Q			: out std_logic_vector(15 downto 0);
			INITDONE	: out std_logic;
			MEMERR		: out std_logic
		);
	end component;

	component PIO8255 is
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
	end component;

	component SUB8049 is
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
	end component;

	component AY38910 is
		port (
			BC1			: in  std_logic;
			BDIR		: in  std_logic;
			A9N			: in  std_logic;
			DAI			: in  std_logic_vector(7 downto 0);
			IA			: in  std_logic_vector(7 downto 0);
			IB			: in  std_logic_vector(7 downto 0);
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			SNDOUT		: out std_logic;
			DSND		: out std_logic_vector(8 downto 0);
			DAO			: out std_logic_vector(7 downto 0);
			OA			: out std_logic_vector(7 downto 0);
			OB			: out std_logic_vector(7 downto 0);
			ENBAN		: out std_logic;
			ENBBN		: out std_logic
		);
	end component;

	component PS2KEY is
		port (
			KEYMATY		: in  std_logic_vector(9 downto 0);
			PS2KBDAT	: in  std_logic;
			PS2KBCLK	: in  std_logic;
			CTRLKEYDAT	: in  std_logic_vector(7 downto 0);
			CTRLKEYENB	: in  std_logic;
			KEYSCANENB	: in  std_logic;
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			KEYMATX		: out std_logic_vector(7 downto 0);
			FUNCKEY		: out std_logic_vector(23 downto 0)
		);
	end component;

	component VOICE7752 is
		port (
			A			: in  std_logic_vector(1 downto 0);
			DI			: in  std_logic_vector(7 downto 0);
			CSN			: in  std_logic;
			RDN			: in  std_logic;
			WRN			: in  std_logic;
			CLK14M		: in  std_logic;
			RSTN		: in  std_logic;
			DO			: out std_logic_vector(7 downto 0);
			SNDOUT		: out std_logic;
			BUSY		: out std_logic;
			REQ			: out std_logic;
			DVO			: out std_logic_vector(13 downto 0);
			VSTB		: out std_logic
		);
	end component;

	component FDCTRL is
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
	end component;

	component FDUNIT is
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
	end component;

	component UART8251 is
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
	end component;

	component INTWAITGEN is
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
	end component;

	component SEG7DISP is
		port (
			FPGA_VER	: in  std_logic_vector(15 downto 0);
			FIRM_VER	: in  std_logic_vector(15 downto 0);
			CMT_COUNTER	: in  std_logic_vector(15 downto 0);
			CPU_ADD		: in  std_logic_vector(15 downto 0);
			BUTTON		: in  std_logic;
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			HEX3_D		: out std_logic_vector(6 downto 0);
			HEX3_DP		: out std_logic;
			HEX2_D		: out std_logic_vector(6 downto 0);
			HEX2_DP		: out std_logic;
			HEX1_D		: out std_logic_vector(6 downto 0);
			HEX1_DP		: out std_logic;
			HEX0_D		: out std_logic_vector(6 downto 0);
			HEX0_DP		: out std_logic
		);
	end component;

-- clkgen
	signal rstn			: std_logic;
	signal clk14m		: std_logic;
	signal clk16m		: std_logic;
	signal clk25m		: std_logic;
	signal clk50m		: std_logic;
	signal clk100m		: std_logic;
	signal clk100m_di	: std_logic;
	signal clk4m		: std_logic;
	signal clk4mcnt		: std_logic_vector(1 downto 0);
	signal clk1s		: std_logic;
	signal lock_pll		: std_logic;

-- rstgen
	signal sdram_init		: std_logic;
	signal sdram_initdone	: std_logic;
	signal sdcad_init		: std_logic;
	signal sdcad_init2		: std_logic;
	signal sdcad_initdone	: std_logic;
	signal sdcad_init_tmp	: std_logic;
	signal cpu_rstn			: std_logic;
	signal pio_rstn			: std_logic;
	signal pio_rst			: std_logic;

	signal rstsft_f1		: std_logic;
	signal rstsft_f2		: std_logic;
	signal rstsft_f3		: std_logic;
	signal mk2mode			: std_logic;
	signal mk2p66m			: std_logic;
	signal P66mode			: std_logic;

-- control CPU
	signal ctrl_m1n		: std_logic;
	signal ctrl_mreqn	: std_logic;
	signal ctrl_iorqn	: std_logic;
	signal ctrl_rdn		: std_logic;
	signal ctrl_wrn		: std_logic;
	signal ctrl_rfshn	: std_logic;
	signal ctrl_a		: std_logic_vector(15 downto 0);
	signal ctrl_a_f1	: std_logic_vector(15 downto 0);
	signal ctrl_a_f2	: std_logic_vector(15 downto 0);
	signal ctrl_di		: std_logic_vector(7 downto 0);
	signal ctrl_do		: std_logic_vector(7 downto 0);
	signal ctrl_addb	: std_logic_vector(9 downto 0);
	signal ctrl_rdbn	: std_logic;

-- control CPU decode signals
	signal ctrl_memrdn	: std_logic;
	signal ctrl_memwrn	: std_logic;

	signal ctrlrom_csn	: std_logic;
	signal ctrlrom_rdn	: std_logic;
	signal ctrlrom_wrn	: std_logic;
	signal ctrlrom_q	: std_logic_vector(7 downto 0);

	signal sd_csn_f1		: std_logic;
	signal sd_csn_f2		: std_logic;
	signal ctrlrom_csn_f1	: std_logic;
	signal ctrlrom_csn_f2	: std_logic;
	signal ctrlreg_csn_f1	: std_logic;
	signal ctrlreg_csn_f2	: std_logic;
	signal ctrlfdc_csn_f1	: std_logic;
	signal ctrlfdc_csn_f2	: std_logic;
	signal ctrlfdc_ext_csn_f1	: std_logic;
	signal ctrlfdc_ext_csn_f2	: std_logic;

-- control VRAM
	signal ctrlvram_csn		: std_logic;
	signal ctrlvram_rdan	: std_logic;
	signal ctrlvram_wran	: std_logic;
	signal ctrlvram_qa		: std_logic_vector(7 downto 0);
	signal ctrlvram_qb		: std_logic_vector(7 downto 0);

-- sdreadif
	signal sd_dat0_i	: std_logic;
	signal sd_datao		: std_logic_vector(7 downto 0);
	signal sd_rdad		: std_logic_vector(18 downto 0);
	signal sd_rddt		: std_logic_vector(7 downto 0);
	signal sd_sdenb		: std_logic;
	signal sd_sdwrn		: std_logic;
	signal sd_err		: std_logic;
	signal sd_outenb	: std_logic;
	signal sd_cmd_i		: std_logic;
	signal sd_dat_i		: std_logic_vector(3 downto 1);
	signal sd_clk_i		: std_logic;
	signal sd_monout	: std_logic_vector(28 downto 0);
	signal sd_wrn		: std_logic;
	signal sd_rdn		: std_logic;
	signal sd_csn		: std_logic;
	signal sd_cmtcnt	: std_logic_vector(15 downto 0);
	signal sd_firmver	: std_logic_vector(15 downto 0);

-- control register
	signal ctrlreg_datao	: std_logic_vector(7 downto 0);
	signal ctrlreg_wrn		: std_logic;
	signal ctrlreg_rdn		: std_logic;
	signal ctrlreg_csn		: std_logic;
	signal ctrlsel			: std_logic;
	signal ctrlrstn			: std_logic;
	signal mem16k			: std_logic;
	signal ctrlkeydat		: std_logic_vector(7 downto 0);
	signal ctrlkeyenb		: std_logic;

-- vdg
	signal vdg_di		: std_logic_vector(7 downto 0);
	signal vdg_cgdi		: std_logic_vector(7 downto 0);
	signal vdg_busackn	: std_logic;
	signal vdg_a		: std_logic_vector(13 downto 0);
	signal vdg_cga		: std_logic_vector(11 downto 0);
	signal vdg_busrqn	: std_logic;
	signal vdg_casn		: std_logic;
	signal vdg_rasn		: std_logic;
	signal vdg_rdn		: std_logic;
	signal vdg_cgrdn	: std_logic;
	signal vdg_cgenbn	: std_logic;
	signal sc4coloron	: std_logic;
	signal sc4colormd	: std_logic_vector(3 downto 0);

	signal vdg_dispd		: std_logic_vector(3 downto 0);
	signal vdg_dispmd		: std_logic_vector(3 downto 0);
	signal vdg_disptmg_hs	: std_logic;
	signal vdg_disptmg_vs	: std_logic;

-- crtc
	signal crtc_di			: std_logic_vector(7 downto 0);
	signal crtc_charmode	: std_logic;
	signal crtc_graphchar	: std_logic;
	signal crtc_busackn		: std_logic;
	signal crtc_a			: std_logic_vector(15 downto 0);
	signal crtc_rdn			: std_logic;
	signal crtc_cgrd		: std_logic;
	signal crtc_busrqn		: std_logic;
	signal crtc_hsyncn		: std_logic;
	signal crtc_vsyncn		: std_logic;
	signal crtc_dispd		: std_logic_vector(3 downto 0);
	signal crtc_dispmd		: std_logic_vector(3 downto 0);
	signal crtc_disptmg_hs	: std_logic;
	signal crtc_disptmg_vs	: std_logic;

	signal vramad		: std_logic_vector(1 downto 0);
	signal charmode		: std_logic;
	signal graphchar	: std_logic;
	signal graphreso	: std_logic;
	signal css1			: std_logic;
	signal css2			: std_logic;
	signal css3			: std_logic;

-- vgaout
	signal dispd		: std_logic_vector(3 downto 0);
	signal dispmd		: std_logic_vector(3 downto 0);
	signal disptmg_hs	: std_logic;
	signal disptmg_vs	: std_logic;
	signal busrqmask	: std_logic;
	signal dispmode		: std_logic;
	signal vga_r_i		: std_logic_vector(3 downto 0);
	signal vga_g_i		: std_logic_vector(3 downto 0);
	signal vga_b_i		: std_logic_vector(3 downto 0);
	signal vga_hs_i		: std_logic;
	signal vga_vs_i		: std_logic;

-- for lcd
	signal lcdmode		: std_logic;
	signal lcd_bl		: std_logic;
	signal lcd_cs_i		: std_logic;
	signal lcd_sdi_i	: std_logic;
	signal lcd_scl_i	: std_logic;
	signal lcdinitdone	: std_logic;
	signal lcd_r_i		: std_logic_vector(7 downto 0);
	signal lcd_g_i		: std_logic_vector(7 downto 0);
	signal lcd_b_i		: std_logic_vector(7 downto 0);
	signal lcd_hsn_i	: std_logic;
	signal lcd_vsn_i	: std_logic;
	signal lcd_den_i	: std_logic;
	signal lcd_clk_i	: std_logic;

-- main CPU
	signal waitn		: std_logic;
	signal intn			: std_logic;
	signal nmin			: std_logic;
	signal busrqn		: std_logic;
	signal m1n			: std_logic;
	signal mreqn		: std_logic;
	signal iorqn		: std_logic;
	signal rdn			: std_logic;
	signal wrn			: std_logic;
	signal rfshn		: std_logic;
	signal busackn		: std_logic;
	signal cpu_a		: std_logic_vector(15 downto 0);
	signal cpu_a_f1		: std_logic_vector(15 downto 0);
	signal cpu_a_f2		: std_logic_vector(15 downto 0);
	signal cpu_di		: std_logic_vector(7 downto 0);
	signal cpu_do		: std_logic_vector(7 downto 0);


-- decode signals
	signal iordn		: std_logic;
	signal iowrn		: std_logic;
	signal memrdn		: std_logic;
	signal memwrn		: std_logic;
	signal intackn		: std_logic;

	signal memrdn_f1	: std_logic;
	signal detblk		: std_logic;
	signal deted		: std_logic;

	signal cgrom_seln		: std_logic;
	signal cgrom_seln_f1	: std_logic;
	signal cgrom_seln_f2	: std_logic;
	signal pio_seln			: std_logic;
	signal pio_seln_f1		: std_logic;
	signal pio_seln_f2		: std_logic;
	signal psg_seln			: std_logic;
	signal psg_seln_f1		: std_logic;
	signal psg_seln_f2		: std_logic;
	signal voice_seln		: std_logic;
	signal voice_seln_f1	: std_logic;
	signal voice_seln_f2	: std_logic;
	signal port_b0_seln		: std_logic;
	signal port_b0_seln_f1	: std_logic;
	signal port_b0_seln_f2	: std_logic;
	signal port_c0_seln		: std_logic;
	signal port_c0_seln_f1	: std_logic;
	signal port_c0_seln_f2	: std_logic;
	signal port_d0_seln		: std_logic;
	signal port_d0_seln_f1	: std_logic;
	signal port_d0_seln_f2	: std_logic;
	signal port_d0_ext_seln		: std_logic;
	signal port_d0_ext_seln_f1	: std_logic;
	signal port_d0_ext_seln_f2	: std_logic;
	signal port_f0_seln		: std_logic;
	signal port_f0_seln_f1	: std_logic;
	signal port_f0_seln_f2	: std_logic;
	signal uart_seln		: std_logic;
	signal uart_seln_f1		: std_logic;
	signal uart_seln_f2		: std_logic;
	signal int8049_seln		: std_logic;
	signal int8049_seln_f1	: std_logic;
	signal int8049_seln_f2	: std_logic;
	signal intjoy7_seln		: std_logic;
	signal intjoy7_seln_f1	: std_logic;
	signal intjoy7_seln_f2	: std_logic;
	signal inttim2_seln		: std_logic;
	signal inttim2_seln_f1	: std_logic;
	signal inttim2_seln_f2	: std_logic;
	signal memc_seln		: std_logic;
	signal memc_seln_f1		: std_logic;
	signal memc_seln_f2		: std_logic;
	signal sdram_seln		: std_logic;
	signal sdram_seln_f1	: std_logic;
	signal sdram_seln_f2	: std_logic;
	signal m1dat			: std_logic_vector(7 downto 0);

-- sdram
	signal dram_di		: std_logic_vector(15 downto 0);
	signal dram_do		: std_logic_vector(15 downto 0);
	signal dram_doenb	: std_logic;
	signal sdram_add	: std_logic_vector(18 downto 0);
	signal sdram_rdn	: std_logic;
	signal sdram_wrn	: std_logic;
	signal sdram_memnoinit	: std_logic;
	signal sdram_memerrmode	: std_logic;
	signal sdram_memerr	: std_logic;

	signal sdram_di		: std_logic_vector(7 downto 0);
	signal sdram_do		: std_logic_vector(15 downto 0);

-- 8255
	signal pio_iocsn	: std_logic;
	signal pio_rdn		: std_logic;
	signal pio_csn		: std_logic;
	signal pio_wrn		: std_logic;
	signal pio_a1		: std_logic;
	signal pio_a0		: std_logic;
	signal pio_do		: std_logic_vector(7 downto 0);

	signal pio_pai		: std_logic_vector(7 downto 0);
	signal pio_pao		: std_logic_vector(7 downto 0);
	signal pio_pbo		: std_logic_vector(7 downto 0);
	signal pio_pco		: std_logic_vector(2 downto 0);
	signal pio_intr		: std_logic;
	signal pio_stbn		: std_logic;
	signal pio_ibf		: std_logic;
	signal pio_ackn		: std_logic;
	signal pio_obfn		: std_logic;

	signal pio_monout	: std_logic_vector(8 downto 0);

	signal cgswn		: std_logic;
	signal crtkilln		: std_logic;
	signal printstb		: std_logic;
	signal printdt		: std_logic_vector(7 downto 0);

-- 8049 and keymatrix and CMT
	signal sub_p1o		: std_logic_vector(7 downto 0);
	signal sub_p2i		: std_logic_vector(7 downto 0);
	signal int8049n		: std_logic;
	signal cmtout		: std_logic;
	signal cmtin		: std_logic;
	signal keymatx		: std_logic_vector(7 downto 0);
	signal keymaty		: std_logic_vector(9 downto 0);
	signal rxrdy		: std_logic;
	signal kanaled		: std_logic;
	signal sub_state	: std_logic_vector(7 downto 0);
	signal sub_stcnt	: std_logic_vector(7 downto 0);
	signal funckey		: std_logic_vector(23 downto 0);
	signal keyscanenb	: std_logic;

	signal sub_taperdopen	: std_logic;
	signal sub_taperdrq		: std_logic;
	signal sub_tapeinit		: std_logic;
	signal sub_taperddata	: std_logic_vector(7 downto 0);
	signal sub_taperdrdy	: std_logic;
	signal sub_tapewrrdy	: std_logic;
	signal sub_tapeacc		: std_logic;
	signal sub_tapeaccmd	: std_logic;
	signal sub_tapewropen	: std_logic;
	signal sub_tapewrrq		: std_logic;
	signal sub_tapewrdata	: std_logic_vector(7 downto 0);
	signal sub_acccnt		: std_logic_vector(31 downto 0);

-- AY-3-8910
	signal psg_iocsn	: std_logic;
	signal psg_bc1		: std_logic;
	signal psg_bdir		: std_logic;
	signal psg_sndout	: std_logic;
	signal psg_dsnd		: std_logic_vector(8 downto 0);
	signal psg_do		: std_logic_vector(7 downto 0);
	signal psg_ia		: std_logic_vector(7 downto 0);
	signal psg_ib		: std_logic_vector(7 downto 0);
	signal psg_oa		: std_logic_vector(7 downto 0);
	signal psg_ob		: std_logic_vector(7 downto 0);
	signal psg_enban	: std_logic;
	signal psg_enbbn	: std_logic;

-- VOICE
	signal voice_csn	: std_logic;
	signal voice_rdn	: std_logic;
	signal voice_wrn	: std_logic;
	signal voice_do		: std_logic_vector(7 downto 0);
	signal voice_sndout	: std_logic;
	signal voice_busy	: std_logic;
	signal voice_req	: std_logic;
	signal voice_dvo	: std_logic_vector(13 downto 0);
	signal voice_vstb	: std_logic;

-- FDC
	signal fdint			: std_logic;
	signal fdint_ext		: std_logic;
	signal fdextsel			: std_logic;
	signal dmadir			: std_logic;
	signal dmaonn			: std_logic;
	signal dmasize			: std_logic_vector(3 downto 0);
	signal fdc_ext_dmadir	: std_logic;
	signal fdc_ext_dmaonn	: std_logic;
	signal fdc_ext_dmasize	: std_logic_vector(7 downto 0);
	signal port_d0_do		: std_logic_vector(7 downto 0);
	signal port_d0_ext_do	: std_logic_vector(7 downto 0);
	signal fdc_fdd0			: std_logic_vector(2 downto 0);
	signal fdc_fdd1			: std_logic_vector(2 downto 0);
	signal fdc_fdd2			: std_logic_vector(2 downto 0);
	signal fdc_fdd3			: std_logic_vector(2 downto 0);
	signal fdc_floppy0		: std_logic_vector(3 downto 0);
	signal fdc_floppy1		: std_logic_vector(3 downto 0);
	signal fdc_floppy2		: std_logic_vector(3 downto 0);
	signal fdc_floppy3		: std_logic_vector(3 downto 0);
	signal fdc_st0			: std_logic_vector(7 downto 0);
	signal fdc_st1			: std_logic_vector(7 downto 0);
	signal fdc_st2			: std_logic_vector(7 downto 0);
	signal fdc_rst_c		: std_logic_vector(7 downto 0);
	signal fdc_rst_h		: std_logic_vector(7 downto 0);
	signal fdc_rst_r		: std_logic_vector(7 downto 0);
	signal fdc_rst_n		: std_logic_vector(7 downto 0);
	signal fdc_endtrg		: std_logic;
	signal fdc_ext_st0		: std_logic_vector(7 downto 0);
	signal fdc_ext_st1		: std_logic_vector(7 downto 0);
	signal fdc_ext_st2		: std_logic_vector(7 downto 0);
	signal fdc_ext_rst_c	: std_logic_vector(7 downto 0);
	signal fdc_ext_rst_h	: std_logic_vector(7 downto 0);
	signal fdc_ext_rst_r	: std_logic_vector(7 downto 0);
	signal fdc_ext_rst_n	: std_logic_vector(7 downto 0);
	signal fdc_ext_endtrg	: std_logic;
	signal fdc_command		: std_logic_vector(4 downto 0);
	signal fdc_comend		: std_logic;
	signal fdc_mt			: std_logic;
	signal fdc_mf			: std_logic;
	signal fdc_sk			: std_logic;
	signal fdc_dnum			: std_logic_vector(1 downto 0);
	signal fdc_hnum			: std_logic;
	signal fdc_idrc			: std_logic_vector(7 downto 0);
	signal fdc_idrh			: std_logic_vector(7 downto 0);
	signal fdc_idrr			: std_logic_vector(7 downto 0);
	signal fdc_idrn			: std_logic_vector(7 downto 0);
	signal fdc_eot			: std_logic_vector(7 downto 0);
	signal fdc_gpl			: std_logic_vector(7 downto 0);
	signal fdc_dtl			: std_logic_vector(7 downto 0);
	signal fdc_ext_command	: std_logic_vector(4 downto 0);
	signal fdc_ext_comend	: std_logic;
	signal fdc_ext_mt		: std_logic;
	signal fdc_ext_mf		: std_logic;
	signal fdc_ext_sk		: std_logic;
	signal fdc_ext_dnum		: std_logic_vector(1 downto 0);
	signal fdc_ext_hnum		: std_logic;
	signal fdc_ext_idrc		: std_logic_vector(7 downto 0);
	signal fdc_ext_idrh		: std_logic_vector(7 downto 0);
	signal fdc_ext_idrr		: std_logic_vector(7 downto 0);
	signal fdc_ext_idrn		: std_logic_vector(7 downto 0);
	signal fdc_ext_eot		: std_logic_vector(7 downto 0);
	signal fdc_ext_gpl		: std_logic_vector(7 downto 0);
	signal fdc_ext_dtl		: std_logic_vector(7 downto 0);
	signal fdc_cnum0		: std_logic_vector(7 downto 0);
	signal fdc_cnum1		: std_logic_vector(7 downto 0);
	signal fdc_cnum2		: std_logic_vector(7 downto 0);
	signal fdc_cnum3		: std_logic_vector(7 downto 0);
	signal fdc_fdcact		: std_logic;
	signal fdc_fdccnum		: std_logic_vector(7 downto 0);
	signal fdc_fdcsnum		: std_logic_vector(7 downto 0);
	signal fdc_ext_fdcact	: std_logic;
	signal fdc_ext_fdccnum	: std_logic_vector(7 downto 0);
	signal fdc_ext_fdcsnum	: std_logic_vector(7 downto 0);

	signal fdc_monout		: std_logic_vector(7 downto 0);
	signal fdc_ext_monout	: std_logic_vector(7 downto 0);

	signal ctrlfdc_datao		: std_logic_vector(7 downto 0);
	signal ctrlfdc_wrn			: std_logic;
	signal ctrlfdc_rdn			: std_logic;
	signal ctrlfdc_csn			: std_logic;
	signal ctrlfdc_ext_datao	: std_logic_vector(7 downto 0);
	signal ctrlfdc_ext_wrn		: std_logic;
	signal ctrlfdc_ext_rdn		: std_logic;
	signal ctrlfdc_ext_csn		: std_logic;

-- uart
	signal uartenb		: std_logic;
	signal uartlen		: std_logic_vector(19 downto 0);
	signal uart_csn		: std_logic;
	signal uart_rdn		: std_logic;
	signal uart_wrn		: std_logic;
	signal uart_do		: std_logic_vector(7 downto 0);
	signal uart_txrdy	: std_logic;
	signal uart_txempty	: std_logic;
	signal uart_rxrdy	: std_logic;
	signal uart_bd		: std_logic;
	signal uart_rxd_i	: std_logic;
	signal uart_ctsn_i	: std_logic;
	signal uart_txd_i	: std_logic;
	signal uart_rtsn_i	: std_logic;

-- other
	signal intn_tmp		: std_logic;
	signal intn_f		: std_logic_vector(7 downto 0);


	signal int8049setn	: std_logic;
	signal intjoy7setn	: std_logic;
	signal inttim2setn	: std_logic;
	signal inttim2_do	: std_logic_vector(7 downto 0);

	signal port_b0		: std_logic_vector(3 downto 0);
	signal port_b1		: std_logic_vector(3 downto 0);
	signal port_b2		: std_logic_vector(3 downto 0);
	signal port_c0		: std_logic_vector(3 downto 0);
	signal port_c1		: std_logic_vector(3 downto 0);
	signal port_c2		: std_logic_vector(3 downto 0);
	signal port_f3		: std_logic_vector(7 downto 0);
	signal port_f4		: std_logic_vector(7 downto 0);
	signal port_f5		: std_logic_vector(7 downto 0);
	signal port_f7		: std_logic_vector(7 downto 0);

	signal basicromcsn	: std_logic;
	signal vo_knromcsn	: std_logic;
	signal slot2romcsn	: std_logic;
	signal slot3romcsn	: std_logic;
	signal intramcsn	: std_logic;
	signal extramcsn	: std_logic;
	signal memc_cgromcsn	: std_logic;
	signal memc_rdn		: std_logic;
	signal memc_wrn		: std_logic;
	signal port_b0_do	: std_logic_vector(7 downto 0);
	signal port_c0_do	: std_logic_vector(7 downto 0);
	signal port_f0_do	: std_logic_vector(7 downto 0);

	signal motor		: std_logic;
	signal vramsw2		: std_logic;
	signal vramsw1		: std_logic;
	signal timer2msn	: std_logic;

	signal cmt3out		: std_logic;
	signal cmt1out		: std_logic;

	signal kanjisel		: std_logic;
	signal vo_knsel		: std_logic;

	signal exkanjienb		: std_logic;
	signal exkanjiaddenb	: std_logic;
	signal exkanjiadd		: std_logic_vector(16 downto 0);

-- fpga_ver
	signal ver_sel		: std_logic_vector(15 downto 0);
	signal fpga_ver		: std_logic_vector(15 downto 0);
	signal sd_firmver_tmp	: std_logic_vector(15 downto 0);

-- cpu address monitor
	signal button1_f1	: std_logic;
	signal button1_f2	: std_logic;
	signal cpuad_set	: std_logic;
	signal cpuad_moni	: std_logic_vector(15 downto 0);

-- prob
	signal dbgtrg		: std_logic_vector(7 downto 0);
	signal gpio1_d_tmp		: std_logic_vector(31 downto 0);
	signal gpio1_clkout_tmp	: std_logic_vector(1 downto 0);

	signal probdat1		: std_logic_vector(7 downto 0);
	signal probdat2		: std_logic_vector(15 downto 0);
	signal probdat3		: std_logic_vector(7 downto 0);

	signal sw86			: std_logic_vector(2 downto 0);
	signal dec_firmad	: std_logic;
	signal dec_subst	: std_logic;

begin

-- clock generate
	rstn <= BUTTON(2);

	U_CLKGEN : CLKGEN
	port map (
		CLK50M1		=> CLK50M1,
		CLK50M0		=> CLK50M0,
		MK2MODE		=> mk2p66m,
		RSTN		=> rstn,
		CLK14MOUT	=> clk14m,
		CLK16MOUT	=> clk16m,
		CLK100MOUT	=> clk100m,
		CLK100M_DI	=> clk100m_di,
		CLK50MOUT	=> clk50m,
		CLK25MOUT	=> clk25m,
		CLK4MOUT	=> clk4m,
		CLK4MCNTOUT	=> clk4mcnt,
		CLK1SOUT	=> clk1s,
		LOCK_PLL	=> lock_pll
	);


-- reset generate
	U_RSTGEN : RSTGEN
	port map (
		LOCK_PLL		=> lock_pll,
		SDRAM_INITDONE	=> sdram_initdone,
		SDCAD_INITDONE	=> sdcad_init_tmp,
		CLK4MCNT		=> clk4mcnt,
		CLK100M			=> clk100m,
		CLK50M			=> clk50m,
		CLK16M			=> clk16m,
		WRN				=> wrn,
		RSTN			=> rstn,
		SDRAM_INIT		=> sdram_init,
		SDCAD_INIT		=> sdcad_init,
		SDCAD_INIT2		=> sdcad_init2,
		CPU_RSTN		=> cpu_rstn,
		PIO_RSTN		=> pio_rstn
	);

	pio_rst <= not pio_rstn;

	sdcad_init_tmp <= sdcad_initdone and ctrlrstn;

	process (clk50m,rstn)
	begin
		if (rstn = '0') then
			rstsft_f1 <= '0';
			rstsft_f2 <= '0';
			rstsft_f3 <= '0';
		elsif (clk50m'event and clk50m = '1') then
			rstsft_f1 <= sdram_initdone;
			rstsft_f2 <= rstsft_f1;
			rstsft_f3 <= rstsft_f2;
		end if;
	end process;

	process (clk50m,rstn)
	begin
		if (rstn = '0') then
			mk2mode <= '0';
			p66mode <= '0';
		elsif (clk50m'event and clk50m = '1') then
			if (rstsft_f3 = '0') then
				mk2mode <= SW(2);
				p66mode <= SW(3);
			end if;
		end if;
	end process;

	mk2p66m <= mk2mode or p66mode;

-- control CPU
	U_T80CTRL : T80s
	generic map (
		Mode 	=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write => 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait  => 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	)
	port map (
		RESET_n		=> sdcad_init2,
		CLK_n		=> clk4m,
		WAIT_n		=> '1',
		INT_n		=> '1',
		NMI_n		=> '1',
		BUSRQ_n		=> '1',
		M1_n		=> ctrl_m1n,
		MREQ_n		=> ctrl_mreqn,
		IORQ_n		=> ctrl_iorqn,
		RD_n		=> ctrl_rdn,
		WR_n		=> ctrl_wrn,
		RFSH_n		=> ctrl_rfshn,
		HALT_n		=> open,
		BUSAK_n		=> open,
		A			=> ctrl_a,
		DI			=> ctrl_di,
		DO			=> ctrl_do
	);

	ctrl_memrdn <= '0' when (ctrl_mreqn = '0' and ctrl_rdn = '0') else '1';
	ctrl_memwrn <= '0' when (ctrl_mreqn = '0' and ctrl_wrn = '0') else '1';

	ctrl_di <=	sd_datao      when (sd_csn      = '0' or sd_csn_f2      = '0') else
				ctrlrom_q     when (ctrlrom_csn = '0' or ctrlrom_csn_f2 = '0') else
				ctrlreg_datao when (ctrlreg_csn = '0' or ctrlreg_csn_f2 = '0') else
				ctrlfdc_datao when (ctrlfdc_csn = '0' or ctrlfdc_csn_f2 = '0') else
				ctrlfdc_ext_datao when (ctrlfdc_ext_csn = '0' or ctrlfdc_ext_csn_f2 = '0') else
				ctrlvram_qa;

	process (clk16m,rstn)
	begin
		if (rstn = '0') then
			ctrl_a_f1      <= (others => '0');
			ctrl_a_f2      <= (others => '0');
			sd_csn_f1      <= '1';
			sd_csn_f2      <= '1';
			ctrlrom_csn_f1 <= '1';
			ctrlrom_csn_f2 <= '1';
			ctrlreg_csn_f1 <= '1';
			ctrlreg_csn_f2 <= '1';
			ctrlfdc_csn_f1 <= '1';
			ctrlfdc_csn_f2 <= '1';
			ctrlfdc_ext_csn_f1 <= '1';
			ctrlfdc_ext_csn_f2 <= '1';
		elsif (clk16m'event and clk16m = '1') then
			ctrl_a_f1      <= ctrl_a;
			ctrl_a_f2      <= ctrl_a_f1;
			sd_csn_f1      <= sd_csn;
			sd_csn_f2      <= sd_csn_f1;
			ctrlrom_csn_f1 <= ctrlrom_csn;
			ctrlrom_csn_f2 <= ctrlrom_csn_f1;
			ctrlreg_csn_f1 <= ctrlreg_csn;
			ctrlreg_csn_f2 <= ctrlreg_csn_f1;
			ctrlfdc_csn_f1 <= ctrlfdc_csn;
			ctrlfdc_csn_f2 <= ctrlfdc_csn_f1;
			ctrlfdc_ext_csn_f1 <= ctrlfdc_ext_csn;
			ctrlfdc_ext_csn_f2 <= ctrlfdc_ext_csn_f1;
		end if;
	end process;


-- control ROM
	U_CTRLROM_WRAP : CTRLROM_WRAP
	port map (
		ADDRESS	=> ctrl_a_f2(13 downto 0),
		DATA	=> ctrl_do,
		RDN		=> ctrlrom_rdn,
		WRN		=> ctrlrom_wrn,
		CLK		=> clk50m,
		RSTN	=> sdcad_init,
		Q		=> ctrlrom_q
	);

	ctrlrom_csn <= '0' when (ctrl_a_f2(15 downto 14) = "00") else '1';
	ctrlrom_rdn <= ctrlrom_csn or ctrl_memrdn;
	ctrlrom_wrn <= ctrlrom_csn or ctrl_memwrn;


-- control VRAM
	U_CTRLVRAM_WRAP : CTRLVRAM_WRAP
	port map (
		ADDA	=> ctrl_a_f2(9 downto 0),
		DATA	=> ctrl_do,
		RDAN	=> ctrlvram_rdan,
		WRAN	=> ctrlvram_wran,
		ADDB	=> ctrl_addb,
		RDBN	=> ctrl_rdbn,
		CLK		=> clk50m,
		RSTN	=> sdcad_init,
		QA		=> ctrlvram_qa,
		QB		=> ctrlvram_qb
	);

	ctrlvram_csn  <= '0' when (ctrl_a_f2(15 downto 10) = "110000") else '1';
	ctrlvram_rdan <= ctrlvram_csn or ctrl_memrdn;
	ctrlvram_wran <= ctrlvram_csn or ctrl_memwrn;

	ctrl_addb <= crtc_a(9 downto 0) when (mk2p66m = '1') else vdg_a(9 downto 0);
	ctrl_rdbn <= crtc_rdn           when (mk2p66m = '1') else vdg_rdn;


-- SD card read
	U_SDREADIF : SDREADIF
	port map (
		SD_DAT0		=> sd_dat0_i,
		SD_WP		=> SD_WP_N,
		ADD			=> ctrl_a_f2(9 downto 0),
		DATAI		=> ctrl_do,
		WRN			=> sd_wrn,
		RDN			=> sd_rdn,
		CMTRDOPEN	=> sub_taperdopen,
		CMTRDREQ	=> sub_taperdrq,
		CMTRDACC	=> sub_tapeacc,
		CMTRDACCMD	=> sub_tapeaccmd,
		CMTWROPEN	=> sub_tapewropen,
		CMTWRREQ	=> sub_tapewrrq,
		CMTWRDT		=> sub_tapewrdata,
		DETBLK		=> detblk,
		FDEXTSEL	=> fdextsel,
		DMADIR		=> dmadir,
		DMAONN		=> dmaonn,
		DMASIZE		=> dmasize,
		FDINT_EXT	=> fdint_ext,
		COMEND		=> fdc_comend,
		COMMAND		=> fdc_command,
		MT			=> fdc_mt,
		MF			=> fdc_mf,
		SK			=> fdc_sk,
		DNUM		=> fdc_dnum,
		HNUM		=> fdc_hnum,
		IDRC		=> fdc_idrc,
		IDRH		=> fdc_idrh,
		IDRR		=> fdc_idrr,
		IDRN		=> fdc_idrn,
		EOT			=> fdc_eot,
		GPL			=> fdc_gpl,
		DTL			=> fdc_dtl,
		EXT_COMEND	=> fdc_ext_comend,
		EXT_COMMAND	=> fdc_ext_command,
		EXT_MT		=> fdc_ext_mt,
		EXT_MF		=> fdc_ext_mf,
		EXT_SK		=> fdc_ext_sk,
		EXT_DNUM	=> fdc_ext_dnum,
		EXT_HNUM	=> fdc_ext_hnum,
		EXT_IDRC	=> fdc_ext_idrc,
		EXT_IDRH	=> fdc_ext_idrh,
		EXT_IDRR	=> fdc_ext_idrr,
		EXT_IDRN	=> fdc_ext_idrn,
		EXT_EOT		=> fdc_ext_eot,
		EXT_GPL		=> fdc_ext_gpl,
		EXT_DTL		=> fdc_ext_dtl,
		CNUM0		=> fdc_cnum0,
		CNUM1		=> fdc_cnum1,
		CNUM2		=> fdc_cnum2,
		CNUM3		=> fdc_cnum3,
		FDCACT		=> fdc_fdcact,
		FDCCNUM		=> fdc_fdccnum,
		FDCSNUM		=> fdc_fdcsnum,
		FDCEXTACT	=> fdc_ext_fdcact,
		FDCEXTCNUM	=> fdc_ext_fdccnum,
		FDCEXTSNUM	=> fdc_ext_fdcsnum,
		CLK50M		=> clk50m,
		RSTN		=> sdcad_init,
		DATAO		=> sd_datao,
		SD_RDAD		=> sd_rdad,
		SD_RDDT		=> sd_rddt,
		SD_SDENB	=> sd_sdenb,
		SD_SDWRN	=> sd_sdwrn,
		SD_RDDONE	=> sdcad_initdone,
		SD_ERR		=> sd_err,
		SD_OUTENB	=> sd_outenb,
		CMTRDRDY	=> sub_taperdrdy,
		CMTWRRDY	=> sub_tapewrrdy,
		CMTRDDT		=> sub_taperddata,
		CMTCNT		=> sd_cmtcnt,
		ACCCNT		=> sub_acccnt,
		SD_CMD		=> sd_cmd_i,
		SD_DAT		=> sd_dat_i,
		SD_CLK		=> sd_clk_i,
		EXT_DMADIR	=> fdc_ext_dmadir,
		EXT_DMAONN	=> fdc_ext_dmaonn,
		EXT_DMASIZE	=> fdc_ext_dmasize,
		FDD0		=> fdc_fdd0,
		FDD1		=> fdc_fdd1,
		FDD2		=> fdc_fdd2,
		FDD3		=> fdc_fdd3,
		FLOPPY0		=> fdc_floppy0,
		FLOPPY1		=> fdc_floppy1,
		FLOPPY2		=> fdc_floppy2,
		FLOPPY3		=> fdc_floppy3,
		ST0			=> fdc_st0,
		ST1			=> fdc_st1,
		ST2			=> fdc_st2,
		RST_C		=> fdc_rst_c,
		RST_H		=> fdc_rst_h,
		RST_R		=> fdc_rst_r,
		RST_N		=> fdc_rst_n,
		ENDTRG		=> fdc_endtrg,
		EXT_ST0		=> fdc_ext_st0,
		EXT_ST1		=> fdc_ext_st1,
		EXT_ST2		=> fdc_ext_st2,
		EXT_RST_C	=> fdc_ext_rst_c,
		EXT_RST_H	=> fdc_ext_rst_h,
		EXT_RST_R	=> fdc_ext_rst_r,
		EXT_RST_N	=> fdc_ext_rst_n,
		EXT_ENDTRG	=> fdc_ext_endtrg,
		MONOUT		=> sd_monout
	);

	sub_tapeaccmd  <= not SW(4);

	sd_csn <= '0' when (ctrl_a_f2(15 downto 10) = "100000") else '1';
	sd_rdn <= sd_csn or ctrl_memrdn;
	sd_wrn <= sd_csn or ctrl_memwrn;

	sd_dat0_i <= SD_DAT(0);

	SD_CMD    <= sd_cmd_i when (sd_outenb = '1') else 'Z';
	SD_CLK    <= sd_clk_i;
	SD_DAT(3) <= sd_dat_i(3) when (sd_outenb = '1') else 'Z';
	SD_DAT(2) <= 'Z';
	SD_DAT(1) <= 'Z';
	SD_DAT(0) <= 'Z';


-- control register
	U_CTRLREG : CTRLREG
	port map (
		ADD			=> ctrl_a_f2(9 downto 0),
		DATAI		=> ctrl_do,
		WRN			=> ctrlreg_wrn,
		RDN			=> ctrlreg_rdn,
		LCDMODE		=> lcdmode,
		MK2MODE		=> mk2mode,
		P66MODE		=> p66mode,
		FUNCKEY		=> funckey,
		FPGAVER		=> fpga_ver,
		CLK50M		=> clk50m,
		RSTN		=> sdcad_init,
		DATAO		=> ctrlreg_datao,
		LCDCS		=> lcd_cs_i,
		LCDSDI		=> lcd_sdi_i,
		LCDSCL		=> lcd_scl_i,
		LCDDONE		=> lcdinitdone,
		CTRLSEL		=> ctrlsel,
		CTRLRSTN	=> ctrlrstn,
		MEM16K		=> mem16k,
		SC4COLORON	=> sc4coloron,
		SC4COLORMD	=> sc4colormd,
		CTRLKEYDAT	=> ctrlkeydat,
		CTRLKEYENB	=> ctrlkeyenb,
		UARTENB		=> uartenb,
		UARTLEN		=> uartlen,
		EXKANJIENB	=> exkanjienb,
		FIRMVER		=> sd_firmver,
		DBGTRG		=> dbgtrg
	);


	ctrlreg_csn <= '0' when (ctrl_a_f2(15 downto 10) = "100001") else '1';
	ctrlreg_rdn <= ctrlreg_csn or ctrl_memrdn;
	ctrlreg_wrn <= ctrlreg_csn or ctrl_memwrn;


-- video display generate
	U_VDGMEMCNT : VDGMEMCNT
	port map (
		D			=> vdg_di,
		CGROMD		=> vdg_cgdi,
		BUSACKN		=> vdg_busackn,
		VRAMSW1		=> vramsw1,
		CRTKILLN	=> crtkilln,
		CLK14M		=> clk14m,
		RSTN		=> rstn,
		AOUT		=> vdg_a,
		CGAOUT		=> vdg_cga,
		BUSRQN		=> vdg_busrqn,
		VCASN		=> vdg_casn,
		VRASN		=> vdg_rasn,
		RAM_RDN		=> vdg_rdn,
		CGROM_RDN	=> vdg_cgrdn,
		CGROM_ENBN	=> vdg_cgenbn,
		DISPD		=> vdg_dispd,
		DISPMD		=> vdg_dispmd,
		DISPTMG_LT	=> open,
		DISPTMG_DT	=> open,
		DISPTMG_BD	=> open,
		DISPTMG_HS	=> vdg_disptmg_hs,
		DISPTMG_VS	=> vdg_disptmg_vs
	);

	vdg_di      <= sdram_do(7 downto 0) when (ctrlsel = '0') else ctrlvram_qb;
	vdg_cgdi    <= sdram_do(7 downto 0);

	vdg_busackn <= busackn;

-- CRT controller
	U_CRTC : CRTC
	port map (
		D			=> crtc_di,
		VRAMAD		=> vramad,
		BUSACKN		=> crtc_busackn,
		CRTKILLN	=> crtkilln,
		CHARMODE	=> crtc_charmode,
		GRAPHCHAR	=> crtc_graphchar,
		GRAPHRESO	=> graphreso,
		CSS1		=> css1,
		CSS2		=> css2,
		CSS3		=> css3,
		CLK			=> clk14m,
		RSTN		=> rstn,
		AOUT		=> crtc_a,
		RDN			=> crtc_rdn,
		CGRD		=> crtc_cgrd,
		BUSRQN		=> crtc_busrqn,
		DISPAREAN	=> open,
		HSYNCN		=> crtc_hsyncn,
		VSYNCN		=> crtc_vsyncn,
		CHARROWENB	=> open,
		DISPD		=> crtc_dispd,
		DISPMD		=> crtc_dispmd,
		DISPTMG_LT	=> open,
		DISPTMG_DT	=> open,
		DISPTMG_HS	=> crtc_disptmg_hs,
		DISPTMG_VS	=> crtc_disptmg_vs,
		HCNT		=> open,
		VCNT		=> open
	);

	vramad(1) <= not vramsw2;
	vramad(0) <= vramsw1;

	crtc_charmode  <= charmode  when (ctrlsel = '0') else '1';
	crtc_graphchar <= graphchar when (ctrlsel = '0') else '1';

	crtc_di      <= sdram_do(7 downto 0) when (ctrlsel = '0' or crtc_cgrd = '1') else ctrlvram_qb;
	crtc_busackn <= busackn;

-- VGA output
	U_VGAOUT : VGAOUT
	port map (
		DISPD		=> dispd,
		DISPMD		=> dispmd,
		DISPTMG_HS	=> disptmg_hs,
		DISPTMG_VS	=> disptmg_vs,
		SC4COLORON	=> sc4coloron,
		SC4COLORMD	=> sc4colormd,
		MK2MODE		=> mk2p66m,
		LCDMODE		=> lcdmode,
		LCDINITDONE	=> lcdinitdone,
		DISPMODE	=> dispmode,
		RDSYNC		=> pio_rstn,
		SYNCOFF		=> '0',
		CLK14M		=> clk14m,
		CLK25M		=> clk25m,
		RSTN		=> rstn,
		MONOUT		=> open,
		BUSRQMASK	=> busrqmask,
		VGA_R		=> vga_r_i,
		VGA_G		=> vga_g_i,
		VGA_B		=> vga_b_i,
		VGA_HS		=> vga_hs_i,
		VGA_VS		=> vga_vs_i,
		LCD_R		=> lcd_r_i,
		LCD_G		=> lcd_g_i,
		LCD_B		=> lcd_b_i,
		LCD_HSN		=> lcd_hsn_i,
		LCD_VSN		=> lcd_vsn_i,
		LCD_DEN		=> lcd_den_i,
		LCD_CLK		=> lcd_clk_i
	);

	dispd      <= crtc_dispd      when (mk2p66m = '1') else vdg_dispd;
	dispmd     <= crtc_dispmd     when (mk2p66m = '1') else vdg_dispmd;
	disptmg_hs <= crtc_disptmg_hs when (mk2p66m = '1') else vdg_disptmg_hs;
	disptmg_vs <= crtc_disptmg_vs when (mk2p66m = '1') else vdg_disptmg_vs;

	dispmode <=	'1' when (sub_tapeaccmd = '1' and sub_taperdopen = '1') else
				'1' when (SW(0) = '1') else
				'0';

	VGA_R  <= vga_r_i;
	VGA_G  <= vga_g_i;
	VGA_B  <= vga_b_i;
	VGA_HS <= vga_hs_i;
	VGA_VS <= vga_vs_i;

	lcdmode <= SW(5);

	lcd_bl <= lcdmode;

	gpio1_d_tmp(0)		<= 'Z';				-- N.C.
	gpio1_d_tmp(1)		<= 'Z';				-- N.C.
	gpio1_d_tmp(2)		<= lcd_bl;			-- N.C.
	gpio1_d_tmp(3)		<= rstn;			-- RESET
	gpio1_d_tmp(4)		<= lcd_cs_i;		-- CS
	gpio1_d_tmp(5)		<= lcd_scl_i;		-- SCL
	gpio1_d_tmp(6)		<= lcd_sdi_i;		-- SDI
	gpio1_d_tmp(7)		<= lcd_b_i(0);		-- B(0)
	gpio1_d_tmp(8)		<= lcd_b_i(1);		-- B(1)
	gpio1_d_tmp(9)		<= lcd_b_i(2);		-- B(2)
	gpio1_d_tmp(10)		<= lcd_b_i(3);		-- B(3)
	gpio1_d_tmp(11)		<= lcd_b_i(4);		-- B(4)
	gpio1_d_tmp(12)		<= lcd_b_i(5);		-- B(5)
	gpio1_d_tmp(13)		<= lcd_b_i(6);		-- B(6)
	gpio1_clkout_tmp(0)	<= lcd_b_i(7);		-- B(7)
	gpio1_d_tmp(14)		<= lcd_g_i(0);		-- G(0)
	gpio1_clkout_tmp(1)	<= lcd_g_i(1);		-- G(1)
	gpio1_d_tmp(15)		<= lcd_g_i(2);		-- G(2)
	gpio1_d_tmp(16)		<= lcd_g_i(3);		-- G(3)
	gpio1_d_tmp(17)		<= lcd_g_i(4);		-- G(4)
	gpio1_d_tmp(18)		<= lcd_g_i(5);		-- G(5)
	gpio1_d_tmp(19)		<= lcd_g_i(6);		-- G(6)
	gpio1_d_tmp(20)		<= lcd_g_i(7);		-- G(7)
	gpio1_d_tmp(21)		<= lcd_r_i(0);		-- R(0)
	gpio1_d_tmp(22)		<= lcd_r_i(1);		-- R(1)
	gpio1_d_tmp(23)		<= lcd_r_i(2);		-- R(2)
	gpio1_d_tmp(24)		<= lcd_r_i(3);		-- R(3)
	gpio1_d_tmp(25)		<= lcd_r_i(4);		-- R(4)
	gpio1_d_tmp(26)		<= lcd_r_i(5);		-- R(5)
	gpio1_d_tmp(27)		<= lcd_r_i(6);		-- R(6)
	gpio1_d_tmp(28)		<= lcd_r_i(7);		-- R(7)
	gpio1_d_tmp(29)		<= lcd_hsn_i;		-- HSYNC
	gpio1_d_tmp(30)		<= lcd_vsn_i;		-- VSYNC
	gpio1_d_tmp(31)		<= lcd_clk_i;		-- DOTCLK


-- main CPU
	U_T80S : T80s
	generic map (
		Mode 	=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write => 0,	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait  => 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	)
	port map (
		RESET_n		=> cpu_rstn,
		CLK_n		=> clk4m,
		WAIT_n		=> waitn,
		INT_n		=> intn,
		NMI_n		=> nmin,
		BUSRQ_n		=> busrqn,
		M1_n		=> m1n,
		MREQ_n		=> mreqn,
		IORQ_n		=> iorqn,
		RD_n		=> rdn,
		WR_n		=> wrn,
		RFSH_n		=> rfshn,
		HALT_n		=> open,
		BUSAK_n		=> busackn,
		A			=> cpu_a,
		DI			=> cpu_di,
		DO			=> cpu_do
	);

	nmin  <= '1';

	busrqn <= 	'1' when (busrqmask = '1') else
				crtc_busrqn when (mk2p66m = '1') else vdg_busrqn;

	cgrom_seln   <= '0' when (mk2p66m = '0' and memrdn = '0' and cpu_a(15 downto 13) = "011" and
					cgswn = '0') else '1';
	pio_seln     <= '0' when (pio_rdn = '0' and pio_csn = '0') else '1';
	psg_seln     <= '0' when (psg_bdir = '0' and psg_bc1 = '1') else '1';
	voice_seln   <= '0' when (mk2p66m = '1' and voice_rdn = '0' and voice_csn = '0') else '1';
	int8049_seln <= '0' when (mk2p66m = '1' and int8049setn = '0' and intackn = '0' and
					port_f3(3) = '1') else '1';
	intjoy7_seln <= '0' when (mk2p66m = '1' and intjoy7setn = '0' and intackn = '0' and
					port_f3(4) = '1') else '1';
	inttim2_seln <= '0' when (inttim2setn = '0' and intackn = '0') else '1';
	port_b0_seln <= '0' when (mk2p66m = '1' and iordn = '0' and cpu_a(7 downto 4) = "1011" and
					p66mode = '1') else '1';
	port_c0_seln <= '0' when (mk2p66m = '1' and iordn = '0' and cpu_a(7 downto 4) = "1100") else '1';
	port_d0_seln <= '0' when (fdextsel = '0' and iordn = '0' and cpu_a(7 downto 4) = "1101") else '1';
	port_d0_ext_seln <= '0' when (fdextsel = '1' and iordn = '0' and cpu_a(7 downto 4) = "1101") else '1';
	port_f0_seln <= '0' when (iordn = '0' and cpu_a(7 downto 4) = "1111") else '1';
	uart_seln    <= '0' when (uart_rdn = '0' and uart_csn = '0') else '1';

	memc_seln    <= '0' when (mk2p66m = '1' and memc_rdn = '0') else '1';
	sdram_seln   <= '0' when (mk2p66m = '0' and m1n = '0' and mreqn = '0') else '1';

	cpu_di  <=
		sdram_do(7 downto 0) when (cgrom_seln   = '0' or cgrom_seln_f2   = '0') else
		port_f4              when (int8049_seln = '0' or int8049_seln_f2 = '0') else
		port_f5              when (intjoy7_seln = '0' or intjoy7_seln_f2 = '0') else
		inttim2_do           when (inttim2_seln = '0' or inttim2_seln_f2 = '0') else
		pio_do               when (pio_seln     = '0' or pio_seln_f2     = '0') else
		psg_do               when (psg_seln     = '0' or psg_seln_f2     = '0') else
		voice_do             when (voice_seln   = '0' or voice_seln_f2   = '0') else
		port_b0_do           when (port_b0_seln = '0' or port_b0_seln_f2 = '0') else
		port_c0_do           when (port_c0_seln = '0' or port_c0_seln_f2 = '0') else
		port_d0_do           when (port_d0_seln = '0' or port_d0_seln_f2 = '0') else
		port_d0_ext_do       when (port_d0_ext_seln = '0' or port_d0_ext_seln_f2 = '0') else
		port_f0_do           when (port_f0_seln = '0' or port_f0_seln_f2 = '0') else
		uart_do              when (uart_seln    = '0' or uart_seln_f2    = '0') else
		X"FF"                when (iordn = '0') else
		sdram_do(7 downto 0) when (memc_seln    = '0' or memc_seln_f2    = '0') else
		X"FF"                when (mk2p66m = '0' and cpu_a(15 downto 14) = "10" and mem16k = '1') else
		sdram_do(7 downto 0) when (sdram_seln   = '0' or sdram_seln_f2   = '0') else
		m1dat                when (rfshn = '0') else
		sdram_do(7 downto 0);


	process (clk16m,pio_rstn)
	begin
		if (pio_rstn = '0') then
			cpu_a_f1        <= (others => '0');
			cpu_a_f2        <= (others => '0');
			cgrom_seln_f1   <= '1';
			cgrom_seln_f2   <= '1';
			pio_seln_f1     <= '1';
			pio_seln_f2     <= '1';
			psg_seln_f1     <= '1';
			psg_seln_f2     <= '1';
			voice_seln_f1   <= '1';
			voice_seln_f2   <= '1';
			port_b0_seln_f1 <= '1';
			port_b0_seln_f2 <= '1';
			port_c0_seln_f1 <= '1';
			port_c0_seln_f2 <= '1';
			port_d0_seln_f1 <= '1';
			port_d0_seln_f2 <= '1';
			port_d0_ext_seln_f1 <= '1';
			port_d0_ext_seln_f2 <= '1';
			port_f0_seln_f1 <= '1';
			port_f0_seln_f2 <= '1';
			uart_seln_f1    <= '1';
			uart_seln_f2    <= '1';
			int8049_seln_f1 <= '1';
			int8049_seln_f2 <= '1';
			intjoy7_seln_f1 <= '1';
			intjoy7_seln_f2 <= '1';
			inttim2_seln_f1 <= '1';
			inttim2_seln_f2 <= '1';
			memc_seln_f1    <= '1';
			memc_seln_f2    <= '1';
			sdram_seln_f1   <= '1';
			sdram_seln_f2   <= '1';
		elsif (clk16m'event and clk16m = '1') then
			cpu_a_f1        <= cpu_a;
			cpu_a_f2        <= cpu_a_f1;
			cgrom_seln_f1   <= cgrom_seln;
			cgrom_seln_f2   <= cgrom_seln_f1;
			pio_seln_f1     <= pio_seln;
			pio_seln_f2     <= pio_seln_f1;
			psg_seln_f1     <= psg_seln;
			psg_seln_f2     <= psg_seln_f1;
			voice_seln_f1   <= voice_seln;
			voice_seln_f2   <= voice_seln_f1;
			port_b0_seln_f1 <= port_b0_seln;
			port_b0_seln_f2 <= port_b0_seln_f1;
			port_c0_seln_f1 <= port_c0_seln;
			port_c0_seln_f2 <= port_c0_seln_f1;
			port_d0_seln_f1 <= port_d0_seln;
			port_d0_seln_f2 <= port_d0_seln_f1;
			port_d0_ext_seln_f1 <= port_d0_ext_seln;
			port_d0_ext_seln_f2 <= port_d0_ext_seln_f1;
			port_f0_seln_f1 <= port_f0_seln;
			port_f0_seln_f2 <= port_f0_seln_f1;
			uart_seln_f1    <= uart_seln;
			uart_seln_f2    <= uart_seln_f1;
			int8049_seln_f1 <= int8049_seln;
			int8049_seln_f2 <= int8049_seln_f1;
			intjoy7_seln_f1 <= intjoy7_seln;
			intjoy7_seln_f2 <= intjoy7_seln_f1;
			inttim2_seln_f1 <= inttim2_seln;
			inttim2_seln_f2 <= inttim2_seln_f1;
			memc_seln_f1    <= memc_seln;
			memc_seln_f2    <= memc_seln_f1;
			sdram_seln_f1   <= sdram_seln;
			sdram_seln_f2   <= sdram_seln_f1;
		end if;
	end process;

	process (clk16m,pio_rstn)
	begin
		if (pio_rstn = '0') then
			m1dat <= (others => '0');
		elsif (clk16m'event and clk16m = '1') then
			if (m1n = '0') then
				m1dat <= cpu_di;
			end if;
		end if;
	end process;



-- address decoder

	iordn   <= iorqn or rdn;
	iowrn   <= iorqn or wrn;
	memrdn  <= mreqn or rdn;
	memwrn  <= mreqn or wrn;
	intackn <= iorqn or m1n;


-- LDIR/LDDR/CPIR/CPDR detect
	process (clk16m,pio_rstn)
	begin
		if (pio_rstn = '0') then
			memrdn_f1 <= '1';
		elsif (clk16m'event and clk16m = '1') then
			memrdn_f1 <= m1n or memrdn;
		end if;
	end process;

	process (clk16m,pio_rstn)
	begin
		if (pio_rstn = '0') then
			detblk <= '0';
			deted  <= '0';
		elsif (clk16m'event and clk16m = '1') then
			if (m1n = '1' and memrdn = '1' and memrdn_f1 = '0') then
				if (cpu_di = X"ED") then
					deted  <= '1';
				elsif (cpu_di = X"DD" or cpu_di = X"FD" or cpu_di = X"CB") then
					null;
				else
					deted  <= '0';
					if (deted = '1') then
						if (cpu_di = X"B0" or cpu_di = X"B8" or cpu_di = X"B1" or cpu_di = X"B9") then
							detblk <= '1';
						else
							detblk <= '0';
						end if;
					else
						detblk <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;


-- main ram and SDRAM control
	sdram_add <=
		sd_rdad                                when (sd_sdenb = '1') else
		"010" & "1010" & vdg_cga               when (mk2p66m = '0' and busackn = '0' and vdg_cgenbn = '0') else
		"000" & "1" & (not vramsw2) & vdg_a    when (mk2p66m = '0' and busackn = '0' and vdg_cgenbn = '1') else
		"11" & exkanjiadd                      when (mk2p66m = '0' and exkanjiaddenb = '1') else
		"010" & "1010" & cpu_a_f2(11 downto 0) when (mk2p66m = '0' and cgswn = '0' and cpu_a_f2(15 downto 13) = "011") else
		"000" & "1"    & cpu_a_f2(14 downto 0) when (mk2p66m = '0' and cpu_a_f2(15) = '1') else
		"010" & "00"   & cpu_a_f2(13 downto 0) when (mk2p66m = '0' and cpu_a_f2(15 downto 14) = "00") else
		"010" & "11"   & cpu_a_f2(13 downto 0) when (mk2p66m = '0' and cpu_a_f2(15 downto 14) = "01") else
		"000" & crtc_a                         when (mk2p66m = '1' and busackn = '0' and crtc_cgrd = '0') else
		"011" & "10"  & crtc_a(13 downto 0)    when (mk2p66m = '1' and busackn = '0' and crtc_cgrd = '1') else
		"11" & exkanjiadd                      when (mk2p66m = '1' and exkanjiaddenb = '1') else
		"011" & "100"  & cpu_a_f2(12 downto 0) when (mk2p66m = '1' and memc_cgromcsn = '0' and charmode = '0') else
		"011" & "101"  & cpu_a_f2(12 downto 0) when (mk2p66m = '1' and memc_cgromcsn = '0' and charmode = '1') else
		"011" & "0"    & cpu_a_f2(14 downto 0) when (mk2p66m = '1' and basicromcsn = '0') else
		"011" & "11"   & cpu_a_f2(13 downto 0) when (mk2p66m = '1' and vo_knromcsn = '0' and vo_knsel = '0') else
		"100" & "0" & kanjisel & cpu_a_f2(13 downto 0) when (mk2p66m = '1' and vo_knromcsn = '0' and vo_knsel = '1') else
		"010" & "110"  & cpu_a_f2(12 downto 0) when (mk2p66m = '1' and slot2romcsn = '0') else
		"010" & "111"  & cpu_a_f2(12 downto 0) when (mk2p66m = '1' and slot3romcsn = '0') else
		"000" & cpu_a_f2                       when (mk2p66m = '1' and intramcsn = '0') else
		"001" & cpu_a_f2                       when (mk2p66m = '1' and extramcsn = '0') else
		(others => '0');

	sdram_rdn <=
		(vdg_rdn and vdg_cgrdn) when (mk2p66m = '0' and busackn = '0') else
		crtc_rdn                when (mk2p66m = '1' and busackn = '0') else
		'0'                     when (exkanjiaddenb = '1') else
		memrdn                  when (mk2p66m = '0') else
		memc_rdn                when (mk2p66m = '1') else
		'1';

	sdram_wrn <=
		sd_sdwrn when (sd_sdenb = '1') else
		'1'      when (busackn = '0') else
		memwrn   when (mk2p66m = '0' and mem16k  = '1' and cpu_a_f2(15 downto 14) = "11") else
		memwrn   when (mk2p66m = '0' and mem16k  = '0' and cpu_a_f2(15) = '1') else
		memc_wrn when (mk2p66m = '1') else
		'1';

	sdram_di <=
		sd_rddt when (sd_sdenb = '1') else
		cpu_do;


	U_SDRAM : SDRAM
	port map (
		DRAM_DI		=> dram_di,
		ADDRESS		=> sdram_add,
		DATA		=> sdram_di,
		RDN			=> sdram_rdn,
		WRN			=> sdram_wrn,
		INIT		=> sdram_init,
		MEMNOINIT	=> sdram_memnoinit,
		MEMERRMODE	=> sdram_memerrmode,
		CLK			=> clk100m,
		CLK_DI		=> clk100m_di,
		RSTN		=> rstn,
		DRAM_DO		=> dram_do,
		DRAM_DOENB	=> dram_doenb,
		DRAM_A		=> DRAM_A,
		DRAM_CLK	=> DRAM_CLK,
		DRAM_CKE	=> DRAM_CKE,
		DRAM_LDQM	=> DRAM_LDQM,
		DRAM_UDQM	=> DRAM_UDQM,
		DRAM_WE_N	=> DRAM_WE_N,
		DRAM_CAS_N	=> DRAM_CAS_N,
		DRAM_RAS_N	=> DRAM_RAS_N,
		DRAM_CS_N	=> DRAM_CS_N,
		DRAM_BA_1	=> DRAM_BA_1,
		DRAM_BA_0	=> DRAM_BA_0,
		Q			=> sdram_do,
		INITDONE	=> sdram_initdone,
		MEMERR		=> sdram_memerr
	);

	DRAM_D  <= dram_do when (dram_doenb = '1') else (others => 'Z');
	dram_di <= DRAM_D;

	sdram_memnoinit  <= '0';
	sdram_memerrmode <= '0';


-- 8255
	pio_iocsn <= '0'     when (cpu_a_f2(7 downto 4) = "1001" and (iordn = '0' or iowrn = '0') ) else '1';
	pio_rdn   <=
		intackn when (int8049setn = '0' and pio_iocsn = '1' and mk2p66m = '0') else
		intackn when (int8049setn = '0' and pio_iocsn = '1' and mk2p66m = '1' and port_f3(3) = '0') else
		rdn;
	pio_csn   <= '0'     when (int8049setn = '0' and pio_iocsn = '1') else pio_iocsn;
	pio_a1    <= '0'     when (int8049setn = '0' and pio_iocsn = '1') else cpu_a_f2(1);
	pio_a0    <= '0'     when (int8049setn = '0' and pio_iocsn = '1') else cpu_a_f2(0);
	pio_wrn   <= '0'     when (pio_iocsn = '0' and wrn = '0') else '1';

	U_PIO8255 : PIO8255
	port map (
		A1			=> pio_a1,
		A0			=> pio_a0,
		DI			=> cpu_do,
		CSN			=> pio_csn,
		RDN			=> pio_rdn,
		WRN			=> pio_wrn,
		PAI			=> pio_pai,
		PC4_STBN	=> pio_stbn,
		PC6_ACKN	=> pio_ackn,
		CLK			=> clk16m,
		RSTN		=> pio_rstn,
		DO			=> pio_do,
		PAO			=> pio_pao,
		PBO			=> pio_pbo,
		PCO			=> pio_pco,
		PC3_INTR	=> pio_intr,
		PC5_IBF		=> pio_ibf,
		PC7_OBFN	=> pio_obfn,
		MONOUT		=> pio_monout
	);

	cgswn    <= pio_pco(2);
	crtkilln <= pio_pco(1);
	printstb <= not pio_pco(0);
	printdt  <= not pio_pbo;


-- 8049
	U_SUB8049 : SUB8049
	port map (
		DI			=> pio_pao,
		P2			=> sub_p2i,
		INTN		=> pio_obfn,
		T0			=> pio_ibf,
		TAPERDDATA	=> sub_taperddata,
		TAPERDRDY	=> sub_taperdrdy,
		TAPEWRRDY	=> sub_tapewrrdy,
		ACCCNT		=> sub_acccnt,
		MK2MODE		=> mk2p66m,
		CLK			=> clk16m,
		RSTN		=> pio_rstn,
		DO			=> pio_pai,
		P1			=> sub_p1o,
		STATEOUT	=> sub_state,
		STCNTOUT	=> sub_stcnt,
		RDN			=> pio_ackn,
		WRN			=> pio_stbn,
		KEYSCANENB	=> keyscanenb,
		TAPERDOPEN	=> sub_taperdopen,
		TAPERDRQ	=> sub_taperdrq,
		TAPEACC		=> sub_tapeacc,
		TAPEWROPEN	=> sub_tapewropen,
		TAPEWRRQ	=> sub_tapewrrq,
		TAPEWRDATA	=> sub_tapewrdata
	);

	int8049n <= sub_p1o(7);
	cmtout   <= not sub_p1o(5);

	keymaty <=	"1111111110" when sub_p1o(3 downto 0) = "0000" else
				"1111111101" when sub_p1o(3 downto 0) = "0001" else
				"1111111011" when sub_p1o(3 downto 0) = "0010" else
				"1111110111" when sub_p1o(3 downto 0) = "0011" else
				"1111101111" when sub_p1o(3 downto 0) = "0100" else
				"1111011111" when sub_p1o(3 downto 0) = "0101" else
				"1110111111" when sub_p1o(3 downto 0) = "0110" else
				"1101111111" when sub_p1o(3 downto 0) = "0111" else
				"1011111111" when sub_p1o(3 downto 0) = "1000" else
				"0111111111" when sub_p1o(3 downto 0) = "1001" else
				"1111111111";

	sub_p2i <=	"11111111"                         when (sub_p1o(4) = '1' and ctrlsel = '1') else
				"1111" & cmtin & '1' & rxrdy & '1' when (sub_p1o(4) = '0' and ctrlsel = '1') else
				keymatx                            when (sub_p1o(4) = '1' and ctrlsel = '0') else
				keymatx(7 downto 4) & cmtin & '1' & rxrdy & '1';


	kanaled <= sub_p1o(6);

	cmtin   <= '1';
	rxrdy   <= (not uart_rxrdy) when (uartenb = '1') else '1';

-- PS/2 KEY
	U_PS2KEY : PS2KEY
	port map (
		KEYMATY		=> keymaty,
		PS2KBDAT	=> PS2_KBDAT,
		PS2KBCLK	=> PS2_KBCLK,
		CTRLKEYDAT	=> ctrlkeydat,
		CTRLKEYENB	=> ctrlkeyenb,
		KEYSCANENB	=> keyscanenb,
		CLK			=> clk16m,
		RSTN		=> rstn,
		KEYMATX		=> keymatx,
		FUNCKEY		=> funckey
	);

	PS2_KBDAT		<= 'Z';
	PS2_KBCLK		<= 'Z';
	PS2_MSDAT		<= 'Z';
	PS2_MSCLK		<= 'Z';


-- AY-3-8910
	psg_iocsn <= '0' when (cpu_a_f2(7 downto 4) = "1010" and (iordn = '0' or iowrn = '0') ) else '1';
	psg_bc1   <= ( not cpu_a_f2(0) ) when (psg_iocsn = '0') else '0';
	psg_bdir  <= ( not cpu_a_f2(1) ) when (psg_iocsn = '0') else '0';


	U_AY38910 : AY38910
	port map (
		BC1			=> psg_bc1,
		BDIR		=> psg_bdir,
		A9N			=> psg_iocsn,
		DAI			=> cpu_do,
		IA			=> psg_ia,
		IB			=> psg_ib,
		CLK			=> clk16m,
		RSTN		=> pio_rstn,
		SNDOUT		=> psg_sndout,
		DSND		=> psg_dsnd,
		DAO			=> psg_do,
		OA			=> psg_oa,
		OB			=> psg_ob,
		ENBAN		=> psg_enban,
		ENBBN		=> psg_enbbn
	);

	psg_ia(7) <= crtc_vsyncn when (mk2p66m = '1') else '1';
	psg_ia(6) <= crtc_hsyncn when (mk2p66m = '1') else '1';
	psg_ia(5) <= GPIO0_D(13) when (psg_ob(6) = '0' and psg_enbbn = '0') else GPIO0_D(6);
	psg_ia(4) <= GPIO0_D(12) when (psg_ob(6) = '0' and psg_enbbn = '0') else GPIO0_D(5);
	psg_ia(3) <= GPIO0_D(11) when (psg_ob(6) = '0' and psg_enbbn = '0') else GPIO0_D(4);
	psg_ia(2) <= GPIO0_D(10) when (psg_ob(6) = '0' and psg_enbbn = '0') else GPIO0_D(3);
	psg_ia(1) <= GPIO0_D(9)  when (psg_ob(6) = '0' and psg_enbbn = '0') else GPIO0_D(2);
	psg_ia(0) <= GPIO0_D(8)  when (psg_ob(6) = '0' and psg_enbbn = '0') else GPIO0_D(1);

	psg_ib    <= (others => '1');


	GPIO0_D(31 downto 24) <= (others => 'Z');

	GPIO0_D(23) <= psg_sndout or voice_sndout;

	GPIO0_D(22 downto 15) <= (others => 'Z');

	GPIO0_D(14) <= psg_ob(4) when (psg_enbbn = '0') else 'Z';
	GPIO0_D(13) <= psg_ob(1) when (psg_ob(7) = '0' and psg_enbbn = '0') else 'Z';
	GPIO0_D(12) <= psg_ob(0) when (psg_ob(7) = '0' and psg_enbbn = '0') else 'Z';
	GPIO0_D(11) <= 'Z';
	GPIO0_D(10) <= 'Z';
	GPIO0_D(9)  <= 'Z';
	GPIO0_D(8)  <= 'Z';
	GPIO0_D(7)  <= psg_ob(5) when (psg_enbbn = '0') else 'Z';
	GPIO0_D(6)  <= psg_ob(3) when (psg_ob(7) = '0' and psg_enbbn = '0') else 'Z';
	GPIO0_D(5)  <= psg_ob(2) when (psg_ob(7) = '0' and psg_enbbn = '0') else 'Z';
	GPIO0_D(4)  <= 'Z';
	GPIO0_D(3)  <= 'Z';
	GPIO0_D(2)  <= 'Z';
	GPIO0_D(1)  <= 'Z';
	GPIO0_D(0)  <= '0' when (psg_ob(7) = '0' and psg_enbbn = '0') else '1';

	GPIO0_CLKOUT(1 downto 0)	<= (others => 'Z');


-- VOICE (uPD7752)

	U_VOICE : VOICE7752
	port map (
		A			=> cpu_a_f2(1 downto 0),
		DI			=> cpu_do,
		CSN			=> voice_csn,
		RDN			=> voice_rdn,
		WRN			=> voice_wrn,
		CLK14M		=> clk14m,
		RSTN		=> pio_rstn,
		DO			=> voice_do,
		SNDOUT		=> voice_sndout,
		BUSY		=> voice_busy,
		REQ			=> voice_req,
		DVO			=> voice_dvo,
		VSTB		=> voice_vstb
	);

	voice_csn <= '0' when (cpu_a_f2(7 downto 3) = "11100" and mk2p66m = '1') else '1';
	voice_rdn <= iordn;
	voice_wrn <= iowrn;

-- FDC (internal)

	U_FDCTRL : FDCTRL
	port map (
		A			=> cpu_a_f2,
		DI			=> cpu_do,
		MREQN		=> mreqn,
		IORQN		=> iorqn,
		RDN			=> rdn,
		WRN			=> wrn,
		CTRL_A		=> ctrl_a_f2(9 downto 0),
		CTRL_DI		=> ctrl_do,
		CTRL_RDN	=> ctrlfdc_rdn,
		CTRL_WRN	=> ctrlfdc_wrn,
		FDEXTSEL	=> fdextsel,
		DMADIR		=> dmadir,
		DMAONN		=> dmaonn,
		FDD0		=> fdc_fdd0,
		FDD1		=> fdc_fdd1,
		FLOPPY0		=> fdc_floppy0,
		FLOPPY1		=> fdc_floppy1,
		ST0			=> fdc_st0,
		ST1			=> fdc_st1,
		ST2			=> fdc_st2,
		RST_C		=> fdc_rst_c,
		RST_H		=> fdc_rst_h,
		RST_R		=> fdc_rst_r,
		RST_N		=> fdc_rst_n,
		ENDTRG		=> fdc_endtrg,
		MK2MODE		=> mk2mode,
		P66MODE		=> p66mode,
		CLK			=> clk16m,
		RSTN		=> pio_rstn,
		DO			=> port_d0_do,
		CTRL_DO		=> ctrlfdc_datao,
		FDINT		=> fdint,
		DMASIZE		=> dmasize,
		COMMAND		=> fdc_command,
		COMEND		=> fdc_comend,
		MT			=> fdc_mt,
		MF			=> fdc_mf,
		SK			=> fdc_sk,
		DNUM		=> fdc_dnum,
		HNUM		=> fdc_hnum,
		IDRC		=> fdc_idrc,
		IDRH		=> fdc_idrh,
		IDRR		=> fdc_idrr,
		IDRN		=> fdc_idrn,
		EOT			=> fdc_eot,
		GPL			=> fdc_gpl,
		DTL			=> fdc_dtl,
		CNUM0		=> fdc_cnum0,
		CNUM1		=> fdc_cnum1,
		FDCACT		=> fdc_fdcact,
		FDCCNUM		=> fdc_fdccnum,
		FDCSNUM		=> fdc_fdcsnum,
		MONOUT		=> fdc_monout
	);

	ctrlfdc_csn <= '0' when (ctrl_a_f2(15 downto 10) = "100100") else '1';
	ctrlfdc_rdn <= ctrlfdc_csn or ctrl_memrdn;
	ctrlfdc_wrn <= ctrlfdc_csn or ctrl_memwrn;

-- FDC (external)

	U_FDUNIT : FDUNIT
	port map (
		A			=> cpu_a_f2,
		DI			=> cpu_do,
		MREQN		=> mreqn,
		IORQN		=> iorqn,
		RDN			=> rdn,
		WRN			=> wrn,
		CTRL_A		=> ctrl_a_f2,
		CTRL_DI		=> ctrl_do,
		CTRL_RDN	=> ctrlfdc_ext_rdn,
		CTRL_WRN	=> ctrlfdc_ext_wrn,
		FDEXTSEL	=> fdextsel,
		DMADIR		=> fdc_ext_dmadir,
		DMAONN		=> fdc_ext_dmaonn,
		DMASIZE		=> fdc_ext_dmasize,
		FDD0		=> fdc_fdd2,
		FDD1		=> fdc_fdd3,
		FLOPPY0		=> fdc_floppy2,
		FLOPPY1		=> fdc_floppy3,
		ST0			=> fdc_ext_st0,
		ST1			=> fdc_ext_st1,
		ST2			=> fdc_ext_st2,
		RST_C		=> fdc_ext_rst_c,
		RST_H		=> fdc_ext_rst_h,
		RST_R		=> fdc_ext_rst_r,
		RST_N		=> fdc_ext_rst_n,
		ENDTRG		=> fdc_ext_endtrg,
		MK2P66M		=> mk2p66m,
		CLK			=> clk16m,
		RSTN		=> pio_rstn,
		DO			=> port_d0_ext_do,
		CTRL_DO		=> ctrlfdc_ext_datao,
		FDINT		=> fdint_ext,
		COMMAND		=> fdc_ext_command,
		COMEND		=> fdc_ext_comend,
		MT			=> fdc_ext_mt,
		MF			=> fdc_ext_mf,
		SK			=> fdc_ext_sk,
		DNUM		=> fdc_ext_dnum,
		HNUM		=> fdc_ext_hnum,
		IDRC		=> fdc_ext_idrc,
		IDRH		=> fdc_ext_idrh,
		IDRR		=> fdc_ext_idrr,
		IDRN		=> fdc_ext_idrn,
		EOT			=> fdc_ext_eot,
		GPL			=> fdc_ext_gpl,
		DTL			=> fdc_ext_dtl,
		CNUM0		=> fdc_cnum2,
		CNUM1		=> fdc_cnum3,
		FDCACT		=> fdc_ext_fdcact,
		FDCCNUM		=> fdc_ext_fdccnum,
		FDCSNUM		=> fdc_ext_fdcsnum,
		MONOUT		=> fdc_ext_monout
	);

	ctrlfdc_ext_csn <=	'0' when (ctrl_a_f2(15 downto  4) = X"9FF") else
						'0' when (ctrl_a_f2(15 downto 13) = "101") else
						'1';
	ctrlfdc_ext_rdn <= ctrlfdc_ext_csn or ctrl_memrdn;
	ctrlfdc_ext_wrn <= ctrlfdc_ext_csn or ctrl_memwrn;

-- uart
	U_UART8251 : UART8251
	port map (
		A0			=> cpu_a_f2(0),
		DI			=> cpu_do,
		CSN			=> uart_csn,
		RDN			=> uart_rdn,
		WRN			=> uart_wrn,
		RXD			=> uart_rxd_i,
		CTSN		=> uart_ctsn_i,
		DSRN		=> '0',
		DTLEN		=> uartlen,
		RESET		=> pio_rst,
		CLK			=> clk50m,
		DO			=> uart_do,
		TXD			=> uart_txd_i,
		RTSN		=> uart_rtsn_i,
		DTRN		=> open,
		TXRDY		=> uart_txrdy,
		TXEMPTY		=> uart_txempty,
		RXRDY		=> uart_rxrdy,
		BD			=> uart_bd
	);

	uart_csn <= '0' when (cpu_a_f2(7 downto 4) = "1000" and uartenb = '1') else '1';
	uart_rdn <= iordn;
	uart_wrn <= iowrn;

	uart_rxd_i  <= UART_RXD;
	uart_ctsn_i <= UART_RTS;
	UART_TXD    <= uart_txd_i;
	UART_CTS    <= uart_rtsn_i;

-- other
	U_INTWAITGEN : INTWAITGEN
	port map (
		A			=> cpu_a_f2,
		DI			=> cpu_do,
		RAMDI		=> sdram_do(7 downto 0),
		M1N			=> m1n,
		MREQN		=> mreqn,
		IORQN		=> iorqn,
		RDN			=> rdn,
		WRN			=> wrn,
		RFSHN		=> rfshn,
		INT8049N	=> int8049n,
		INTJOY7N	=> psg_ia(5),
		CGSWN		=> cgswn,
		FDINT		=> fdint,
		MK2MODE		=> mk2p66m,
		MEM128K		=> mem16k,
		EXKANJIENB	=> exkanjienb,
		CLK4MCNT	=> clk4mcnt,
		CLK16M		=> clk16m,
		RSTN		=> pio_rstn,
		BASICROMCSN	=> basicromcsn,
		VO_KNROMCSN	=> vo_knromcsn,
		SLOT2ROMCSN	=> slot2romcsn,
		SLOT3ROMCSN	=> slot3romcsn,
		INTRAMCSN	=> intramcsn,
		EXTRAMCSN	=> extramcsn,
		CGROMCSN	=> memc_cgromcsn,
		SDRAMRDN	=> memc_rdn,
		SDRAMWRN	=> memc_wrn,
		PORT_B0H	=> port_b0,
		PORT_B1H	=> port_b1,
		PORT_B2H	=> port_b2,
		PORT_C0H	=> port_c0,
		PORT_C1H	=> port_c1,
		PORT_C2H	=> port_c2,
		PORT_F3H	=> port_f3,
		PORT_F4H	=> port_f4,
		PORT_F5H	=> port_f5,
		PORT_F7H	=> port_f7,
		DO_PORT_B0H	=> port_b0_do,
		DO_PORT_C0H	=> port_c0_do,
		DO_PORT_F0H	=> port_f0_do,
		EXKANJIADDENB	=> exkanjiaddenb,
		EXKANJIADD	=> exkanjiadd,
		INT8049SETN	=> int8049setn,
		INTJOY7SETN	=> intjoy7setn,
		INTTIM2SETN	=> inttim2setn,
		WAITN		=> waitn,
		INTN		=> intn_tmp
	);

	intn <= intn_tmp;
	inttim2_do <= X"06" when (mk2p66m = '0') else port_f7;

	motor     <= port_b0(3);
	vramsw2   <= port_b0(2);
	vramsw1   <= port_b0(1);
	timer2msn <= port_b0(0);
	fdextsel  <= port_b1(2);
	dmadir    <= port_b1(1);
	dmaonn    <= port_b1(0);
	cmt3out   <= port_b2(3);
	cmt1out   <= port_b2(1);

	css1      <= port_c0(0);
	css2      <= port_c0(1);
	css3      <= port_c0(2);
	charmode  <= port_c1(1);
	graphchar <= port_c1(2);
	graphreso <= port_c1(3);
	kanjisel  <= port_c2(1);
	vo_knsel  <= port_c2(0);



-- cpu address monitor
	process (clk16m,rstn)
	begin
		if (rstn = '0') then
			button1_f1 <= '0';
			button1_f2 <= '0';
		elsif (clk16m'event and clk16m = '1') then
			button1_f1 <= BUTTON(1);
			button1_f2 <= button1_f1;
		end if;
	end process;

	process (clk16m,rstn)
	begin
		if (rstn = '0') then
			cpuad_moni <= X"CADD";
			cpuad_set  <= '0';
		elsif (clk16m'event and clk16m = '1') then
			if (SW(9) = '0') then

				if (cpu_rstn = '0') then
					cpuad_moni <= X"CADD";
					cpuad_set  <= '0';
				elsif (cpuad_set = '1') then
					if (m1n = '0' and rdn = '0') then
						cpuad_moni <= cpu_a_f2;
						cpuad_set  <= '0';
					end if;
				elsif (button1_f2 = '1' and button1_f1 = '0') then
					cpuad_set  <= '1';
				end if;

			else

				if (sdcad_init = '0') then
					cpuad_moni <= X"CADD";
					cpuad_set  <= '0';
				elsif (cpuad_set = '1') then
					if (ctrl_m1n = '0' and ctrl_rdn = '0') then
						cpuad_moni <= ctrl_a_f2;
						cpuad_set  <= '0';
					end if;
				elsif (button1_f2 = '0' and button1_f1 = '1') then
					cpuad_set  <= '1';
				end if;

			end if;
		end if;
	end process;

-- fpga version
	U_SEG7DISP : SEG7DISP
	port map (
		FPGA_VER	=> fpga_ver,
		FIRM_VER	=> sd_firmver_tmp,
		CMT_COUNTER	=> sd_cmtcnt,
		CPU_ADD		=> cpuad_moni,
		BUTTON		=> BUTTON(0),
		CLK			=> clk16m,
		RSTN		=> rstn,
		HEX3_D		=> HEX3_D,
		HEX3_DP		=> HEX3_DP,
		HEX2_D		=> HEX2_D,
		HEX2_DP		=> HEX2_DP,
		HEX1_D		=> HEX1_D,
		HEX1_DP		=> HEX1_DP,
		HEX0_D		=> HEX0_D,
		HEX0_DP		=> HEX0_DP
	);

	sd_firmver_tmp <= X"F" & sd_firmver(11 downto 0) when (SW(9) = '0') else sd_firmver;

	LEDG(0) <= sd_outenb;
	LEDG(1) <= (sd_err and clk1s);
	LEDG(2) <= (sdram_memerr and clk1s);
	LEDG(3) <= '0';
	LEDG(4) <= '0';
	LEDG(5) <= '0';
	LEDG(6) <= '0';
	LEDG(7) <=	'0' when (motor = '0') else
				sub_taperddata(0) when (sub_taperdopen = '1') else
				sub_tapewrdata(0) when (sub_tapewropen = '1') else
				'0';
	LEDG(8) <= motor;
	LEDG(9) <= not kanaled;

-- probe output

	sw86 <= SW(8 downto 6);

	dec_firmad <= '1' when (cpu_a_f2 = sd_firmver and m1n = '0' and rdn = '0') else '0';
--	dec_firmad <= '1' when (ctrl_a_f2(15 downto 9) = "1000000" and ctrl_wrn = '0') else '0';
	dec_subst  <= '1' when (sub_state = sd_firmver(7 downto 0)) else '0';

	probdat1 <=
--		detblk & iorqn & mreqn & rdn & wrn & rfshn & m1n & cpu_rstn			when (sw86 = "000") else
--		dec_firmad & iorqn & mreqn & rdn & wrn & fdextsel & dmadir & dmaonn	when (sw86 = "000") else
--		intn & iorqn & mreqn & rdn & wrn & rfshn & m1n & cpu_rstn			when (sw86 = "000") else
		voice_vstb & iorqn & mreqn & rdn & wrn & voice_req & m1n & voice_busy		when (sw86 = "000") else
		dec_firmad & iorqn & mreqn & rdn & wrn & rfshn & m1n & cpu_rstn		when (sw86 = "001") else
--		dec_firmad & iorqn & mreqn & rdn & wrn & rfshn & m1n & cpu_rstn		when (sw86 = "010") else
--		intn & iorqn & mreqn & rdn & wrn & rfshn & m1n & cpu_rstn			when (sw86 = "011") else
--		"00000" & voice_sndout & psg_sndout & psg_dsnd(8)	when (sw86 = "011") else
--		dbgtrg(0) & sub_tapewrrdy & sub_tapewropen & sub_tapewrrq & sd_monout(27 downto 24)	when (sw86 = "010") else
--		sdram_add(18 downto 16) & sd_sdwrn & memwrn & dbgtrg(2 downto 0) when (sw86 = "010") else
--		sdram_rdn & sdram_wrn & clk4m & rdn & wrn & rfshn & m1n & cpu_rstn	when (sw86 = "010") else
--		sdram_rdn & sdram_wrn & clk4m & rdn & wrn & rfshn & m1n & cpu_rstn	when (sw86 = "011") else
--		uartenb & uart_wrn & uart_rdn & uart_csn & uart_rxd_i & uart_ctsn_i & uart_txd_i & uart_rtsn_i	when (sw86 = "010") else
--		uart_txrdy & uart_txempty & uart_rxrdy & uart_csn & uart_rxd_i & uart_bd & uart_txd_i & uart_rxrdy	when (sw86 = "011") else
--		"0" & sub_taperdopen & sub_taperdrq & sub_taperdrdy & pio_obfn & pio_ibf & pio_ackn & pio_stbn when (sw86 = "100") else
--		dec_subst & sub_tapewropen & sub_tapewrrq & sub_tapewrrdy & pio_obfn & pio_ibf & pio_ackn & pio_stbn when (sw86 = "101") else
--		pio_monout(8) & sub_tapewropen & sub_tapewrrq & sub_tapewrrdy & pio_obfn & pio_ibf & pio_ackn & pio_stbn when (sw86 = "101") else
--		ctrl_m1n & ctrl_rdn & ctrl_wrn & ctrl_rfshn & sd_cmd_i & sd_clk_i & sd_dat_i(3) & sd_dat0_i;
--		dec_firmad & sd_cmd_i & sd_clk_i & sd_dat_i(3) & sd_dat0_i & dbgtrg(2 downto 0) when (sw86 = "110") else
--		sd_monout(28 downto 24) & dbgtrg(2 downto 0) when (sw86 = "110") else
		ctrl_m1n & ctrl_rdn & ctrl_wrn & ctrl_rfshn & dec_firmad & dbgtrg(2 downto 0);

	probdat2 <=
		cpu_a_f2				when (sw86 = "000") else
		cpu_a_f2				when (sw86 = "001") else
--		cpu_a_f2(7 downto 0) & pio_monout(7 downto 0)	when (sw86 = "010") else
--		cpu_a_f2(7 downto 0) & "000" & uart_csn & pio_rdn & pio_wrn & pio_csn & rxrdy	when (sw86 = "011") else
--		"00" & voice_dvo 		when (sw86 = "011") else
--		cpu_a_f2				when (sw86 = "011") else
--		sdram_add(15 downto 0)	when (sw86 = "010") else
--		pio_pai & sub_state		when (sw86 = "100") else
--		pio_pao & sub_state		when (sw86 = "101") else
--		sd_monout(15 downto 0)	when (sw86 = "110") else
--		fdc_ext_monout & cpu_a_f2(7 downto 0)	when (sw86 = "110") else
		ctrl_a_f2;

	probdat3 <=
		cpu_di					when (sw86 = "000") else
		cpu_do					when (sw86 = "001") else
--		cpu_di					when (sw86 = "010") else
--		psg_dsnd(7 downto 0)	when (sw86 = "011") else
--		cpu_do					when (sw86 = "011") else
--		sd_monout(23 downto 16)	when (sw86 = "010") else
--		sdram_di(7 downto 0)	when (sw86 = "010") else
--		sub_taperddata			when (sw86 = "100") else
--		sub_tapewrdata			when (sw86 = "101") else
--		pio_monout(7 downto 0)	when (sw86 = "101") else
--		ctrl_do					when (sw86 = "110") else
--		sd_monout(23 downto 16)	when (sw86 = "110") else
--		ctrl_di					when (sw86 = "110") else
		ctrl_di;

	gpio1_d_tmp(13)		<= lcd_b_i(6);		-- B(6)
	gpio1_clkout_tmp(0)	<= lcd_b_i(7);		-- B(7)

	GPIO1_D(0)		<= gpio1_d_tmp(0)		;
	GPIO1_D(1)		<= gpio1_d_tmp(1)		;

	GPIO1_D(3)		<= gpio1_d_tmp(3)      when (SW(9) = '0') else probdat1(0)	;	-- PROBE #00(trigger)
	GPIO1_D(2)		<= gpio1_d_tmp(2)      when (SW(9) = '0') else probdat1(1)	;	-- PROBE #01(trigger)
	GPIO1_D(5)		<= gpio1_d_tmp(5)      when (SW(9) = '0') else probdat1(2)	;	-- PROBE #02(trigger)
	GPIO1_D(4)		<= gpio1_d_tmp(4)      when (SW(9) = '0') else probdat1(3)	;	-- PROBE #03(trigger)
	GPIO1_D(7)		<= gpio1_d_tmp(7)      when (SW(9) = '0') else probdat1(4)	;	-- PROBE #04(trigger)
	GPIO1_D(6)		<= gpio1_d_tmp(6)      when (SW(9) = '0') else probdat1(5)	;	-- PROBE #05(trigger)
	GPIO1_D(9)		<= gpio1_d_tmp(9)      when (SW(9) = '0') else probdat1(6)	;	-- PROBE #06(trigger)
	GPIO1_D(8)		<= gpio1_d_tmp(8)      when (SW(9) = '0') else probdat1(7)	;	-- PROBE #07(trigger)
	GPIO1_D(11)		<= gpio1_d_tmp(11)     when (SW(9) = '0') else probdat2(0)	;	-- PROBE #08(trigger)
	GPIO1_D(10)		<= gpio1_d_tmp(10)     when (SW(9) = '0') else probdat2(1)	;	-- PROBE #09(trigger)
	GPIO1_D(13)		<= gpio1_d_tmp(13)     when (SW(9) = '0') else probdat2(2)	;	-- PROBE #10(trigger)
	GPIO1_D(12)		<= gpio1_d_tmp(12)     when (SW(9) = '0') else probdat2(3)	;	-- PROBE #11(trigger)
	GPIO1_D(14)		<= gpio1_d_tmp(14)     when (SW(9) = '0') else probdat2(4)	;	-- PROBE #12(trigger)
	GPIO1_CLKOUT(0)	<= gpio1_clkout_tmp(0) when (SW(9) = '0') else probdat2(5)	;	-- PROBE #13(trigger)
	GPIO1_D(15)		<= gpio1_d_tmp(15)     when (SW(9) = '0') else probdat2(6)	;	-- PROBE #14(trigger)
	GPIO1_CLKOUT(1)	<= gpio1_clkout_tmp(1) when (SW(9) = '0') else probdat2(7)	;	-- PROBE #15
	GPIO1_D(17)		<= gpio1_d_tmp(17)     when (SW(9) = '0') else probdat2(8)	;	-- PROBE #16
	GPIO1_D(16)		<= gpio1_d_tmp(16)     when (SW(9) = '0') else probdat2(9)	;	-- PROBE #17
	GPIO1_D(19)		<= gpio1_d_tmp(19)     when (SW(9) = '0') else probdat2(10)	;	-- PROBE #18
	GPIO1_D(18)		<= gpio1_d_tmp(18)     when (SW(9) = '0') else probdat2(11)	;	-- PROBE #19
	GPIO1_D(21)		<= gpio1_d_tmp(21)     when (SW(9) = '0') else probdat2(12)	;	-- PROBE #20
	GPIO1_D(20)		<= gpio1_d_tmp(20)     when (SW(9) = '0') else probdat2(13)	;	-- PROBE #21
	GPIO1_D(23)		<= gpio1_d_tmp(23)     when (SW(9) = '0') else probdat2(14)	;	-- PROBE #22
	GPIO1_D(22)		<= gpio1_d_tmp(22)     when (SW(9) = '0') else probdat2(15)	;	-- PROBE #23
	GPIO1_D(25)		<= gpio1_d_tmp(25)     when (SW(9) = '0') else probdat3(0)	;	-- PROBE #24
	GPIO1_D(24)		<= gpio1_d_tmp(24)     when (SW(9) = '0') else probdat3(1)	;	-- PROBE #25
	GPIO1_D(27)		<= gpio1_d_tmp(27)     when (SW(9) = '0') else probdat3(2)	;	-- PROBE #26
	GPIO1_D(26)		<= gpio1_d_tmp(26)     when (SW(9) = '0') else probdat3(3)	;	-- PROBE #27
	GPIO1_D(29)		<= gpio1_d_tmp(29)     when (SW(9) = '0') else probdat3(4)	;	-- PROBE #28
	GPIO1_D(28)		<= gpio1_d_tmp(28)     when (SW(9) = '0') else probdat3(5)	;	-- PROBE #29
	GPIO1_D(31)		<= gpio1_d_tmp(31)     when (SW(9) = '0') else probdat3(6)	;	-- PROBE #30
	GPIO1_D(30)		<= gpio1_d_tmp(30)     when (SW(9) = '0') else probdat3(7)	;	-- PROBE #31

-- unused pin
	FLASH_A			<= (others => '0');
	FLASH_WE_N		<= '1';
	FLASH_RESET_N	<= '0';
	FLASH_OE_N		<= '1';
	FLASH_CE_N		<= '1';
	FLASH_WP_N		<= '1';
	FLASH_BYTE_N	<= '1';
	LCD_BLON		<= '0';
	LCD_RW			<= '0';
	LCD_EN			<= '0';
	LCD_RS			<= '0';

	FLASH_D15_AM1	<= 'Z';
	FLASH_D			<= (others => 'Z');
	LCD_D			<= (others => 'Z');

-- fpga version

	fpga_ver <= X"0235";

end RTL;
