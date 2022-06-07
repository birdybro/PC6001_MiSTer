//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [48:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

assign VGA_SL = 0;
assign VGA_F1 = 0;
assign VGA_SCALER = 0;
assign HDMI_FREEZE = 0;

assign AUDIO_S = 0;
assign AUDIO_L = 0;
assign AUDIO_R = 0;
assign AUDIO_MIX = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

wire [1:0] ar = status[122:121];

assign VIDEO_ARX = (!ar) ? 12'd4 : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? 12'd3 : 12'd0;

`include "build_id.v" 
localparam CONF_STR = {
	"PC6001;;",
	"-;",
	"O[122:121],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"-;",
	"R[0],Reset and close OSD;",
	"V,v",`BUILD_DATE 
};

wire forced_scandoubler;
wire   [1:0] buttons;
wire [127:0] status;
wire  [10:0] ps2_key;

hps_io #(.CONF_STR(CONF_STR)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),
	.gamma_bus(),

	.forced_scandoubler(forced_scandoubler),

	.buttons(buttons),
	.status(status),
	.status_menumask(),
	
	.ps2_key(ps2_key)
);

///////////////////////   CLOCKS   ///////////////////////////////

wire clk_sys, clk_sys2;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.outclk_1(clk_sys2)
);

wire reset = RESET | status[0] | buttons[1];

//////////////////////////////////////////////////////////////////

wire [1:0] col = status[4:3];

wire HBlank;
wire HSync;
wire VBlank;
wire VSync;
wire ce_pix;
wire [7:0] video;

assign CLK_VIDEO = clk_sys;
assign CE_PIXEL = ce_pix;
assign VGA_DE = ~(HBlank | VBlank);
assign VGA_HS = HSync;
assign VGA_VS = VSync;

PC6001 PC6001
(
	.DRAM_D(),			// inout std_logic_vector(15 downto 0);	-- SDRAM data bus
	.DRAM_A(),			// out   std_logic_vector(12 downto 0);	-- SDRAM address bus
	.DRAM_CLK(),		// out   std_logic;						-- SDRAM clock output
	.DRAM_CKE(),		// out   std_logic;						-- SDRAM clock enable
	.DRAM_LDQM(),		// out   std_logic;						-- SDRAM LowerByte Data Mask
	.DRAM_UDQM(),		// out   std_logic;						-- SDRAM UpperByte Data Mask
	.DRAM_WE_N(),		// out   std_logic;						-- SDRAM write Enable
	.DRAM_CAS_N(),		// out   std_logic;						-- SDRAM CAS
	.DRAM_RAS_N(),		// out   std_logic;						-- SDRAM RAS
	.DRAM_CS_N(),		// out   std_logic;						-- SDRAM chip select
	.DRAM_BA_1(),		// out   std_logic;						-- SDRAM Bank #1
	.DRAM_BA_0(),		// out   std_logic;						-- SDRAM Bank #0
	.FLASH_D15_AM1(),	// inout std_logic;						-- FLASH data bus bit15 or adrress-1
	.FLASH_D(),			// inout std_logic_vector(14 downto 0);	-- FLASH data bus
	.FLASH_A(),			// out   std_logic_vector(21 downto 0);	-- FLASH adrress bus
	.FLASH_WE_N(),		// out   std_logic;						-- FLASH write enable
	.FLASH_RESET_N(),	// out   std_logic;						-- FLASH reset
	.FLASH_WP_N(),		// out   std_logic;						-- FLASH write protect
	.FLASH_RY(),		// in    std_logic;						-- FLASH ready
	.FLASH_CE_N(),		// out   std_logic;						-- FLASH chip enable
	.FLASH_OE_N(),		// out   std_logic;						-- FLASH output enable
	.FLASH_BYTE_N(),	// out   std_logic;						-- FLASH byte mode
	.VGA_R(VGA_R),		// out   std_logic_vector(3 downto 0);	-- VGA red data
	.VGA_G(VGA_G),		// out   std_logic_vector(3 downto 0);	-- VGA green data
	.VGA_B(VGA_B),		// out   std_logic_vector(3 downto 0);	-- VGA blue data
	.VGA_HS(HSync),		// out   std_logic;						-- VGA H_SYNC
	.VGA_VS(VSync),		// out   std_logic;						-- VGA V_SYNC
	.HEX3_D(),			// out   std_logic_vector(6 downto 0);	-- 7segment #3
	.HEX3_DP(),			// out   std_logic;						-- 7segment #3 DP
	.HEX2_D(),			// out   std_logic_vector(6 downto 0);	-- 7segment #2
	.HEX2_DP(),			// out   std_logic;						-- 7segment #2 DP
	.HEX1_D(),			// out   std_logic_vector(6 downto 0);	-- 7segment #1
	.HEX1_DP(),			// out   std_logic;						-- 7segment #1 DP
	.HEX0_D(),			// out   std_logic_vector(6 downto 0);	-- 7segment #0
	.HEX0_DP(),			// out   std_logic;						-- 7segment #0 DP
	.LEDG(),			// out   std_logic_vector(9 downto 0);	-- LED
	.LCD_D(),			// inout std_logic_vector(7 downto 0);	-- LCD data bus
	.LCD_BLON(),		// out   std_logic;						-- LCD back light on
	.LCD_RS(),			// out   std_logic;						-- LCD command/data select
	.LCD_RW(),			// out   std_logic;						-- LCD read/write
	.LCD_EN(),			// out   std_logic;						-- LCD enable
	.CLK50M1(clk_sys2),	// in    std_logic;						-- clock 50MHz input #1
	.CLK50M0(clk_sys),	// in    std_logic;						-- clock 50MHz input #0
	.UART_RXD(),		// in    std_logic;						-- UART Rx
	.UART_RTS(),		// in    std_logic;						-- UART CTS(!!)
	.UART_TXD(),		// out   std_logic;						-- UART Tx
	.UART_CTS(),		// out   std_logic;						-- UART RTS(!!)
	.PS2_KBDAT(),		// inout std_logic;						-- PS2 keyboard data
	.PS2_KBCLK(),		// inout std_logic;						-- PS2 keyboard clock
	.PS2_MSDAT(),		// inout std_logic;						-- PS2 mouse data
	.PS2_MSCLK(),		// inout std_logic;						-- PS2 mouse clock
	.BUTTON(),			// in    std_logic_vector(2 downto 0);	-- push button
	.SW(),				// in    std_logic_vector(9 downto 0);	-- DIPSW
	.GPIO1_D(),			// inout std_logic_vector(31 downto 0);	-- GPIO #1 data
	.GPIO1_CLKIN(),		// in    std_logic_vector(1 downto 0);	-- GPIO #1 clock input
	.GPIO1_CLKOUT(),	// out   std_logic_vector(1 downto 0);	-- GPIO #1 clock output
	.GPIO0_D(),			// inout std_logic_vector(31 downto 0);	-- GPIO #0 data
	.GPIO0_CLKIN(),		// in    std_logic_vector(1 downto 0);	-- GPIO #0 clock input
	.GPIO0_CLKOUT(),	// out   std_logic_vector(1 downto 0);	-- GPIO #0 clock output
	.SD_DAT(),			// inout std_logic_vector(3 downto 0);	-- SD card data
	.SD_CMD(),			// inout std_logic;						-- SD card command
	.SD_CLK(),			// out   std_logic;						-- SD card clock output
	.SD_WP_N()			// in    std_logic						-- SD card write protect
);


endmodule
