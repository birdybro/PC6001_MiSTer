--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity VGAOUT is
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
		MONOUT		: out std_logic_vector(25 downto 0);
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
end VGAOUT;

architecture RTL of VGAOUT is

	component DPRAM_4096W5B is
		port (
			data		: in  std_logic_vector(4 downto 0);
			wraddress	: in  std_logic_vector(11 downto 0);
			wren		: in  std_logic;
			wrclock		: in  std_logic;
			rdaddress	: in  std_logic_vector(11 downto 0);
			rd_aclr		: in  std_logic;
			rdclock		: in  std_logic;
			q			: out std_logic_vector(4 downto 0)
		);
	end component;

	signal hcntwr	: std_logic_vector(9 downto 0);
	signal vcntwr	: std_logic_vector(8 downto 0);

	signal vcntwrskip		: std_logic;
	signal vcntwrskip_f1	: std_logic;
	signal vcntwrskip_f2	: std_logic;
	signal wcnt00		: std_logic;
	signal wcnt00_f1	: std_logic;
	signal wcnt00_f2	: std_logic;
	signal wcnt00_f3	: std_logic;

	signal ramwad_h	: std_logic_vector(9 downto 0);
	signal ramwad_v	: std_logic_vector(8 downto 0);

	signal w_hvld_i	: std_logic;
	signal w_vvld_i	: std_logic;

	signal dispmode_f1	: std_logic;
	signal busrqcntst	: std_logic_vector(3 downto 0);
	signal busrqcnt		: std_logic_vector(3 downto 0);
	signal busrqmask_i	: std_logic;

	signal dispsc		: std_logic_vector(2 downto 0);
	signal aclr			: std_logic;
	signal ramwad		: std_logic_vector(15 downto 0);
	signal ramwenb		: std_logic;
	signal ramwadenb	: std_logic;
	signal ramwdt		: std_logic_vector(4 downto 0);
	signal ramwdt_f1	: std_logic_vector(4 downto 0);

	signal ramwenb_bd	: std_logic;
	signal ram_bd		: std_logic_vector(4 downto 0);

	signal rdsync_f1	: std_logic;
	signal rdsync_f2	: std_logic;
	signal rdstart		: std_logic;

	signal hcntrd	: std_logic_vector(10 downto 0);
	signal vcntrd	: std_logic_vector(9 downto 0);
	signal ramrad	: std_logic_vector(15 downto 0);
	signal ramrdt	: std_logic_vector(4 downto 0);

	signal ramrad_h	: std_logic_vector(10 downto 0);
	signal ramrad_v	: std_logic_vector(9 downto 0);

	signal vga_hs_i		: std_logic;
	signal vga_vs_i		: std_logic;
	signal r_hblk_i		: std_logic;
	signal r_hblk_f1	: std_logic;
	signal r_hblk_f2	: std_logic;
	signal r_hblk_f3	: std_logic;
	signal r_hblk_f4	: std_logic;
	signal r_hblk_f5	: std_logic;
	signal r_hblk_f6	: std_logic;
	signal r_hblk_f7	: std_logic;
	signal r_hblk_f8	: std_logic;
	signal r_hblk_f9	: std_logic;
	signal r_hblk_f10	: std_logic;
	signal r_hblk_f11	: std_logic;
	signal r_hblk_f12	: std_logic;
	signal r_vblk_i		: std_logic;
	signal r_vblk_f1	: std_logic;
	signal r_vblk_f2	: std_logic;
	signal r_vblk_f3	: std_logic;
	signal r_vblk_f4	: std_logic;
	signal r_vblk_f5	: std_logic;
	signal r_vblk_f6	: std_logic;
	signal r_vblk_f7	: std_logic;
	signal r_vblk_f8	: std_logic;
	signal r_vblk_f9	: std_logic;
	signal r_vblk_f10	: std_logic;
	signal r_vblk_f11	: std_logic;
	signal r_vblk_f12	: std_logic;
	signal r_hvld_i		: std_logic;
	signal r_hvld_f1	: std_logic;
	signal r_hvld_f2	: std_logic;
	signal r_vvld_i		: std_logic;
	signal r_vvld_f1	: std_logic;
	signal r_vvld_f2	: std_logic;

	signal ramrdt_mux	: std_logic_vector(4 downto 0);

	signal ramrdt_mux_f1	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f2	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f3	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f4	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f5	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f6	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f7	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f8	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f9	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f10	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f11	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f12	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f13	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f14	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f15	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f16	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f17	: std_logic_vector(4 downto 0);
	signal ramrdt_mux_f18	: std_logic_vector(4 downto 0);

	signal bitpat		: std_logic_vector(4 downto 0);
	signal set2p		: std_logic_vector(23 downto 0);
	signal set2r		: std_logic_vector(23 downto 0);
	signal set2g		: std_logic_vector(23 downto 0);
	signal set2b		: std_logic_vector(23 downto 0);

	signal bitpt2		: std_logic_vector(4 downto 0);
	signal st2p2		: std_logic_vector(23 downto 0);
	signal st2r2		: std_logic_vector(23 downto 0);
	signal st2g2		: std_logic_vector(23 downto 0);
	signal st2b2		: std_logic_vector(23 downto 0);

	signal vgadat		: std_logic_vector(23 downto 0);

	signal vga_hs_f1	: std_logic;
	signal vga_hs_f2	: std_logic;
	signal vga_hs_f3	: std_logic;
	signal vga_hs_f4	: std_logic;
	signal vga_hs_f5	: std_logic;
	signal vga_hs_f6	: std_logic;
	signal vga_hs_f7	: std_logic;
	signal vga_hs_f8	: std_logic;
	signal vga_hs_f9	: std_logic;
	signal vga_hs_f10	: std_logic;
	signal vga_hs_f11	: std_logic;
	signal vga_hs_f12	: std_logic;
	signal vga_hs_f13	: std_logic;
	signal vga_vs_f1	: std_logic;
	signal vga_vs_f2	: std_logic;
	signal vga_vs_f3	: std_logic;
	signal vga_vs_f4	: std_logic;
	signal vga_vs_f5	: std_logic;
	signal vga_vs_f6	: std_logic;
	signal vga_vs_f7	: std_logic;
	signal vga_vs_f8	: std_logic;
	signal vga_vs_f9	: std_logic;
	signal vga_vs_f10	: std_logic;
	signal vga_vs_f11	: std_logic;
	signal vga_vs_f12	: std_logic;
	signal vga_vs_f13	: std_logic;

	signal lcd_hs_f13	: std_logic;
	signal lcd_vs_f13	: std_logic;

	signal vga_r_f12	: std_logic_vector(7 downto 0);
	signal vga_r_f13	: std_logic_vector(7 downto 0);
	signal vga_g_f12	: std_logic_vector(7 downto 0);
	signal vga_g_f13	: std_logic_vector(7 downto 0);
	signal vga_b_f12	: std_logic_vector(7 downto 0);
	signal vga_b_f13	: std_logic_vector(7 downto 0);

	signal lcd_r_f13	: std_logic_vector(7 downto 0);
	signal lcd_g_f13	: std_logic_vector(7 downto 0);
	signal lcd_b_f13	: std_logic_vector(7 downto 0);

	signal lcd_clk_f1	: std_logic;

begin

---- CLK14M write

-- horizontal counter for write
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			hcntwr <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (DISPTMG_HS = '1') then
				hcntwr <= (others => '0');
			else
				hcntwr <= hcntwr + 1;
			end if;
		end if;
	end process;

-- vertical counter for write
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			vcntwr <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (DISPTMG_HS = '1') then
				if (DISPTMG_VS = '1') then
					vcntwr <= (others => '0');
				else
					vcntwr <= vcntwr + 1;
				end if;
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			vcntwrskip <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (vcntwr = 7 or vcntwr = 8 or SYNCOFF = '1') then
				vcntwrskip <= '1';
			else
				vcntwrskip <= '0';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			wcnt00 <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (vcntwr = 11) then
				wcnt00 <= '1';
			else
				wcnt00 <= '0';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			vcntwrskip_f1 <= '0';
			vcntwrskip_f2 <= '0';
			wcnt00_f1     <= '0';
			wcnt00_f2     <= '0';
			wcnt00_f3     <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			vcntwrskip_f1 <= vcntwrskip;
			vcntwrskip_f2 <= vcntwrskip_f1;
			wcnt00_f1     <= wcnt00;
			wcnt00_f2     <= wcnt00_f1 or wcnt00;
			wcnt00_f3     <= wcnt00_f2;
		end if;
	end process;


-- display mask mode
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			dispmode_f1 <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (DISPTMG_HS = '1' and DISPTMG_VS = '1') then
				dispmode_f1 <= DISPMODE;
			end if;
		end if;
	end process;

-- bus request mask start counter
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			busrqcntst <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (DISPTMG_HS = '1' and DISPTMG_VS = '1') then
				if (busrqcntst = "1011") then
					busrqcntst <= (others => '0');
				else
					busrqcntst <= busrqcntst + 1;
				end if;
			end if;
		end if;
	end process;

-- bus request mask counter
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			busrqcnt <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (dispmode_f1 = '0') then
				busrqcnt <= (others => '0');
			elsif (DISPTMG_HS = '1') then
				if (DISPTMG_VS = '1') then
					busrqcnt <= (others => '0');
				elsif (busrqcnt = "1011") then
					busrqcnt <= (others => '0');
				else
					busrqcnt <= busrqcnt + 1;
				end if;
			end if;
		end if;
	end process;

-- bus request mask
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			busrqmask_i <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (dispmode_f1 = '0') then
				busrqmask_i <= '0';
			elsif (busrqcnt = busrqcntst) then
				busrqmask_i <= '0';
			else
				busrqmask_i <= '1';
			end if;
		end if;
	end process;


	w_hvld_i <=	'1' when (176 <= hcntwr and hcntwr < 816) else
				'0';

	w_vvld_i <=	'1' when ( 40 <= vcntwr and vcntwr < 240) else
				'0';


--	ramwenb <=		'0' when (busrqmask_i = '1') else
	ramwenb <=
					'0' when (w_hvld_i = '0' or w_vvld_i = '0') else
					hcntwr(0);

	ramwadenb <=	'0' when (w_hvld_i = '0' or w_vvld_i = '0') else
					hcntwr(0);

	ramwenb_bd	<=	'0' when (busrqmask_i = '1') else
					'1' when (hcntwr = 817 and vcntwr = 239) else
					'0';


	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			ramwad <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (DISPTMG_HS = '1' and DISPTMG_VS = '1') then
				ramwad <= (others => '0');
			elsif (ramwadenb = '1') then
				ramwad <= ramwad + 1;
			end if;
		end if;
	end process;

-- DISPD  = 0000 Green
-- DISPD  = 0001 Yellow
-- DISPD  = 0010 Blue
-- DISPD  = 0011 Red
-- DISPD  = 0100 Buff
-- DISPD  = 0101 Cyan
-- DISPD  = 0110 Magenta
-- DISPD  = 0111 Orange
-- DISPD  = 1000 Black
-- DISPMD = 00X0 SCREEN 1 set1 (charactor)
-- DISPMD = 00X1 SCREEN 1 set2 (charactor)
-- DISPMD = 01XX SCREEN 2      (semi graphic)
-- DISPMD = 1X00 SCREEN 3 set1 (color graphic)
-- DISPMD = 1X01 SCREEN 3 set2 (color graphic)
-- DISPMD = 1X10 SCREEN 4 set1 (reso graphic)
-- DISPMD = 1X11 SCREEN 4 set2 (reso graphic)

	dispsc <=	"000" when (MK2MODE = '0' and DISPMD(3 downto 2) = "00") else			-- P6  SCREEN1
				"001" when (MK2MODE = '0' and DISPMD(3 downto 2) = "01") else			-- P6  SCREEN2
				"010" when (MK2MODE = '0' and DISPMD(3) = '1' and DISPMD(1) = '0') else	-- P6  SCREEN3
				"011" when (MK2MODE = '0' and DISPMD(3) = '1' and DISPMD(1) = '1') else	-- P6  SCREEN4
				"100" when (MK2MODE = '1' and DISPMD = "0111") else						-- mk2 SCREEN4 set2
				"111";

	ramwdt <=
		"00000" when (dispsc = "000"  and DISPD = "0000" and DISPMD(0) = '0') else	-- mode1 set1 Green
		"00001" when (dispsc = "000"  and DISPD = "0100" and DISPMD(0) = '0') else	-- mode1 set1 Buff
		"00010" when (dispsc = "000"  and DISPD = "0111" and DISPMD(0) = '1') else	-- mode1 set2 Orange
		"00011" when (dispsc = "000"  and DISPD = "0100" and DISPMD(0) = '1') else	-- mode1 set2 Buff
		"01011" when (dispsc = "000"  and DISPD = "1000") else						-- mode1 set1/2 Black
		"10000" when (dispsc = "001"  and DISPD = "1000") else						-- mode2 Black
		"00101" when (dispsc = "001"  and DISPD = "0000") else						-- mode2 Green
		"11110" when (dispsc = "001"  and DISPD = "0001") else						-- mode2 Yellow
		"11001" when (dispsc = "001"  and DISPD = "0010") else						-- mode2 Blue
		"11010" when (dispsc = "001"  and DISPD = "0011") else						-- mode2 Red
		"11111" when (dispsc = "001"  and DISPD = "0100") else						-- mode2 Buff
		"11101" when (dispsc = "001"  and DISPD = "0101") else						-- mode2 Cyan
		"11011" when (dispsc = "001"  and DISPD = "0110") else						-- mode2 Magenta
		"00111" when (dispsc = "001"  and DISPD = "0111") else						-- mode2 Orange
		"01000" when (dispsc = "010"  and DISPD = "0000" and DISPMD(0) = '0') else	-- mode3 set1 Green
		"11110" when (dispsc = "010"  and DISPD = "0001" and DISPMD(0) = '0') else	-- mode3 set1 Yellow
		"11001" when (dispsc = "010"  and DISPD = "0010" and DISPMD(0) = '0') else	-- mode3 set1 Blue
		"11010" when (dispsc = "010"  and DISPD = "0011" and DISPMD(0) = '0') else	-- mode3 set1 Red
		"11111" when (dispsc = "010"  and DISPD = "0100" and DISPMD(0) = '1') else	-- mode3 set2 Buff
		"11101" when (dispsc = "010"  and DISPD = "0101" and DISPMD(0) = '1') else	-- mode3 set2 Cyan
		"11011" when (dispsc = "010"  and DISPD = "0110" and DISPMD(0) = '1') else	-- mode3 set2 Magenta
		"01001" when (dispsc = "010"  and DISPD = "0111" and DISPMD(0) = '1') else	-- mode3 set2 Orange
		"00001" when (dispsc = "011"  and DISPD = "0000" and DISPMD(0) = '0') else	-- mode4 set1 Green
		"00000" when (dispsc = "011"  and DISPD = "1000" and DISPMD(0) = '0') else	-- mode4 set1 Black
		"01110" when (dispsc = "011"  and DISPD = "0100" and DISPMD(0) = '1') else	-- mode4 set2 Buff
		"01111" when (dispsc = "011"  and DISPD = "1000" and DISPMD(0) = '1') else	-- mode4 set2 Black
		"00100" when (dispsc = "100"  and DISPD = "1111") else						-- mk2 mode4 set2 白
		"00110" when (dispsc = "100"  and DISPD = "0000") else						-- mk2 mode4 set2 黒
		"10000" when (dispsc = "111"  and DISPD = "0000") else						-- mk2   透明(黒)
		"10001" when (dispsc = "111"  and DISPD = "0001") else						-- mk2   青紫
		"10010" when (dispsc = "111"  and DISPD = "0010") else						-- mk2   橙
		"10011" when (dispsc = "111"  and DISPD = "0011") else						-- mk2   赤紫
		"10100" when (dispsc = "111"  and DISPD = "0100") else						-- mk2   青緑
		"10101" when (dispsc = "111"  and DISPD = "0101") else						-- mk2   空色
		"10110" when (dispsc = "111"  and DISPD = "0110") else						-- mk2   黄緑
		"10111" when (dispsc = "111"  and DISPD = "0111") else						-- mk2   灰色
		"11000" when (dispsc = "111"  and DISPD = "1000") else						-- mk2   黒
		"11001" when (dispsc = "111"  and DISPD = "1001") else						-- mk2   青
		"11010" when (dispsc = "111"  and DISPD = "1010") else						-- mk2   赤
		"11011" when (dispsc = "111"  and DISPD = "1011") else						-- mk2   マゼンタ
		"11100" when (dispsc = "111"  and DISPD = "1100") else						-- mk2   緑
		"11101" when (dispsc = "111"  and DISPD = "1101") else						-- mk2   シアン
		"11110" when (dispsc = "111"  and DISPD = "1110") else						-- mk2   黄
		"11111" when (dispsc = "111"  and DISPD = "1111") else						-- mk2   白
		"01010";


	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			ramwdt_f1 <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (busrqmask_i = '1') then
				ramwdt_f1 <= "10000";
			else
				ramwdt_f1 <= ramwdt;
			end if;
		end if;
	end process;


	aclr <= not RSTN;

	U_DPRAM_4096W5B : DPRAM_4096W5B
	port map (
		data		=> ramwdt_f1,
		wraddress	=> ramwad(11 downto 0),
		wren		=> ramwenb,
		wrclock		=> CLK14M,
		rdaddress	=> ramrad(11 downto 0),
		rd_aclr		=> aclr,
		rdclock		=> CLK25M,
		q			=> ramrdt
	);

	MONOUT(1  downto  0) <= ramwad(11 downto 10);
	MONOUT(10 downto  2) <= vcntwr;
	MONOUT(11)           <= ramwadenb;
	MONOUT(12)           <= ramwenb;
	MONOUT(13)           <= vcntwrskip;
	MONOUT(15 downto 14) <= ramrad(11 downto 10);
	MONOUT(25 downto 16) <= vcntrd;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			ram_bd <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (ramwenb_bd = '1') then
				ram_bd <= ramwdt_f1;
			end if;
		end if;
	end process;


---- CLK25M read start
	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			rdsync_f1 <= '0';
			rdsync_f2 <= '0';
		elsif (CLK25M'event and CLK25M = '1') then
			rdsync_f1 <= RDSYNC;
			rdsync_f2 <= rdsync_f1;
		end if;
	end process;

	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			rdstart <= '0';
		elsif (CLK25M'event and CLK25M = '1') then
			if (rdsync_f2 = '0') then
				rdstart <= '0';
			elsif (wcnt00_f3 = '1') then
				rdstart <= '1';
			end if;
		end if;
	end process;

---- CLK25M read
	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			hcntrd <= (others => '0');
		elsif (CLK25M'event and CLK25M = '1') then
			if (rdstart = '0') then
				hcntrd <= (others => '0');
			elsif (LCDMODE = '0') then
				if (hcntrd = 799) then
					hcntrd <= (others => '0');
				else
					hcntrd <= hcntrd + 1;
				end if;
			else
				if (LCDINITDONE = '0') then
					hcntrd <= (others => '0');
				elsif (hcntrd = 1599) then
					hcntrd <= (others => '0');
				else
					hcntrd <= hcntrd + 1;
				end if;
			end if;
		end if;
	end process;

	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			vcntrd <= (others => '0');
		elsif (CLK25M'event and CLK25M = '1') then
			if (rdstart = '0') then
				vcntrd <= (others => '0');
			elsif (LCDMODE = '0') then
				if (hcntrd = 799) then
					if (vcntrd = 523) then
						vcntrd <= (others => '0');
					elsif (vcntrd = 517 and vcntwrskip_f2 = '0') then
						vcntrd <= conv_std_logic_vector(520,10);
					else
						vcntrd <= vcntrd + 1;
					end if;
				end if;
			else
				if (hcntrd = 1599) then
					if (vcntrd = 261) then
						vcntrd <= (others => '0');
					elsif (vcntrd = 258 and vcntwrskip_f2 = '0') then
						vcntrd <= conv_std_logic_vector(260,10);
					else
						vcntrd <= vcntrd + 1;
					end if;
				end if;
			end if;
		end if;
	end process;


	vga_hs_i <=	'0' when (LCDMODE = '0' and  704 <= hcntrd and hcntrd <  800) else
				'0' when (LCDMODE = '1' and    0 <= hcntrd and hcntrd <    4) else
				'1';

	vga_vs_i <=	'0' when (LCDMODE = '0' and  522 <= vcntrd and vcntrd <  524) else
				'0' when (LCDMODE = '1' and    0 <= vcntrd and vcntrd <    1) else
				'1';

	r_hblk_i <=	'0' when (LCDMODE = '0' and   48 <= hcntrd and hcntrd <  688) else
				'0' when (LCDMODE = '1' and  280 <= hcntrd and hcntrd < 1560) else
				'1';

	r_vblk_i <=	'0' when (LCDMODE = '0' and   33 <= vcntrd and vcntrd <  513) else
				'0' when (LCDMODE = '1' and   13 <= vcntrd and vcntrd <  253) else
				'1';

	r_hvld_i <=	'1' when (LCDMODE = '0' and   48 <= hcntrd and hcntrd <  688) else
				'1' when (LCDMODE = '1' and  280 <= hcntrd and hcntrd < 1560) else
				'0';

	r_vvld_i <=	'1' when (LCDMODE = '0' and   73 <= vcntrd and vcntrd <  473) else
				'1' when (LCDMODE = '1' and   33 <= vcntrd and vcntrd <  233) else
				'0';


	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			ramrad <= (others => '0');
		elsif (CLK25M'event and CLK25M = '1') then
			if (LCDMODE = '0') then
				if (hcntrd = 799 and vcntrd = 523) then
					ramrad <= (others => '0');
				elsif (hcntrd = 0) then
					if (r_vvld_i = '1' and vcntrd(0) = '0') then
						ramrad <= ramrad - 320;
					end if;
				else
					if (r_vvld_i = '1' and r_hvld_i = '1' and hcntrd(0) = '1') then
						ramrad <= ramrad + 1;
					end if;
				end if;
			else
				if (hcntrd = 1599 and vcntrd = 261) then
					ramrad <= (others => '0');
				else
					if (r_vvld_i = '1' and r_hvld_i = '1' and hcntrd(1 downto 0) = "11") then
						ramrad <= ramrad + 1;
					end if;
				end if;
			end if;
		end if;
	end process;


	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			vga_hs_f1  <= '1';
			vga_hs_f2  <= '1';
			vga_hs_f3  <= '1';
			vga_hs_f4  <= '1';
			vga_hs_f5  <= '1';
			vga_hs_f6  <= '1';
			vga_hs_f7  <= '1';
			vga_hs_f8  <= '1';
			vga_hs_f9  <= '1';
			vga_hs_f10 <= '1';
			vga_hs_f11 <= '1';
			vga_hs_f12 <= '1';
			vga_vs_f1  <= '1';
			vga_vs_f2  <= '1';
			vga_vs_f3  <= '1';
			vga_vs_f4  <= '1';
			vga_vs_f5  <= '1';
			vga_vs_f6  <= '1';
			vga_vs_f7  <= '1';
			vga_vs_f8  <= '1';
			vga_vs_f9  <= '1';
			vga_vs_f10 <= '1';
			vga_vs_f11 <= '1';
			vga_vs_f12 <= '1';
			r_hblk_f1  <= '1';
			r_hblk_f2  <= '1';
			r_hblk_f3  <= '1';
			r_hblk_f4  <= '1';
			r_hblk_f5  <= '1';
			r_hblk_f6  <= '1';
			r_hblk_f7  <= '1';
			r_hblk_f8  <= '1';
			r_hblk_f9  <= '1';
			r_hblk_f10 <= '1';
			r_hblk_f11 <= '1';
			r_hblk_f12 <= '1';
			r_vblk_f1  <= '1';
			r_vblk_f2  <= '1';
			r_vblk_f3  <= '1';
			r_vblk_f4  <= '1';
			r_vblk_f5  <= '1';
			r_vblk_f6  <= '1';
			r_vblk_f7  <= '1';
			r_vblk_f8  <= '1';
			r_vblk_f9  <= '1';
			r_vblk_f10 <= '1';
			r_vblk_f11 <= '1';
			r_vblk_f12 <= '1';
			r_hvld_f1  <= '0';
			r_hvld_f2  <= '0';
			r_vvld_f1  <= '0';
			r_vvld_f2  <= '0';
		elsif (CLK25M'event and CLK25M = '1') then
			vga_hs_f1  <= vga_hs_i;
			vga_hs_f2  <= vga_hs_f1;
			vga_hs_f3  <= vga_hs_f2;
			vga_hs_f4  <= vga_hs_f3;
			vga_hs_f5  <= vga_hs_f4;
			vga_hs_f6  <= vga_hs_f5;
			vga_hs_f7  <= vga_hs_f6;
			vga_hs_f8  <= vga_hs_f7;
			vga_hs_f9  <= vga_hs_f8;
			vga_hs_f10 <= vga_hs_f9;
			vga_hs_f11 <= vga_hs_f10;
			vga_hs_f12 <= vga_hs_f11;
			vga_vs_f1  <= vga_vs_i;
			vga_vs_f2  <= vga_vs_f1;
			vga_vs_f3  <= vga_vs_f2;
			vga_vs_f4  <= vga_vs_f3;
			vga_vs_f5  <= vga_vs_f4;
			vga_vs_f6  <= vga_vs_f5;
			vga_vs_f7  <= vga_vs_f6;
			vga_vs_f8  <= vga_vs_f7;
			vga_vs_f9  <= vga_vs_f8;
			vga_vs_f10 <= vga_vs_f9;
			vga_vs_f11 <= vga_vs_f10;
			vga_vs_f12 <= vga_vs_f11;
			r_hblk_f1  <= r_hblk_i;
			r_hblk_f2  <= r_hblk_f1;
			r_hblk_f3  <= r_hblk_f2;
			r_hblk_f4  <= r_hblk_f3;
			r_hblk_f5  <= r_hblk_f4;
			r_hblk_f6  <= r_hblk_f5;
			r_hblk_f7  <= r_hblk_f6;
			r_hblk_f8  <= r_hblk_f7;
			r_hblk_f9  <= r_hblk_f8;
			r_hblk_f10 <= r_hblk_f9;
			r_hblk_f11 <= r_hblk_f10;
			r_hblk_f12 <= r_hblk_f11;
			r_vblk_f1  <= r_vblk_i;
			r_vblk_f2  <= r_vblk_f1;
			r_vblk_f3  <= r_vblk_f2;
			r_vblk_f4  <= r_vblk_f3;
			r_vblk_f5  <= r_vblk_f4;
			r_vblk_f6  <= r_vblk_f5;
			r_vblk_f7  <= r_vblk_f6;
			r_vblk_f8  <= r_vblk_f7;
			r_vblk_f9  <= r_vblk_f8;
			r_vblk_f10 <= r_vblk_f9;
			r_vblk_f11 <= r_vblk_f10;
			r_vblk_f12 <= r_vblk_f11;
			r_hvld_f1  <= r_hvld_i;
			r_hvld_f2  <= r_hvld_f1;
			r_vvld_f1  <= r_vvld_i;
			r_vvld_f2  <= r_vvld_f1;
		end if;
	end process;

	ramrdt_mux <=	ramrdt when (r_hvld_f2 = '1' and r_vvld_f2 = '1') else
					ram_bd;

	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			ramrdt_mux_f1  <= (others => '0');
			ramrdt_mux_f2  <= (others => '0');
			ramrdt_mux_f3  <= (others => '0');
			ramrdt_mux_f4  <= (others => '0');
			ramrdt_mux_f5  <= (others => '0');
			ramrdt_mux_f6  <= (others => '0');
			ramrdt_mux_f7  <= (others => '0');
			ramrdt_mux_f8  <= (others => '0');
			ramrdt_mux_f9  <= (others => '0');
			ramrdt_mux_f10 <= (others => '0');
			ramrdt_mux_f11 <= (others => '0');
			ramrdt_mux_f12 <= (others => '0');
			ramrdt_mux_f13 <= (others => '0');
			ramrdt_mux_f14 <= (others => '0');
			ramrdt_mux_f15 <= (others => '0');
			ramrdt_mux_f16 <= (others => '0');
			ramrdt_mux_f17 <= (others => '0');
			ramrdt_mux_f18 <= (others => '0');
		elsif (CLK25M'event and CLK25M = '1') then
			ramrdt_mux_f1  <= ramrdt_mux;
			ramrdt_mux_f2  <= ramrdt_mux_f1;
			ramrdt_mux_f3  <= ramrdt_mux_f2;
			ramrdt_mux_f4  <= ramrdt_mux_f3;
			ramrdt_mux_f5  <= ramrdt_mux_f4;
			ramrdt_mux_f6  <= ramrdt_mux_f5;
			ramrdt_mux_f7  <= ramrdt_mux_f6;
			ramrdt_mux_f8  <= ramrdt_mux_f7;
			ramrdt_mux_f9  <= ramrdt_mux_f8;
			ramrdt_mux_f10 <= ramrdt_mux_f9;
			ramrdt_mux_f11 <= ramrdt_mux_f10;
			ramrdt_mux_f12 <= ramrdt_mux_f11;
			ramrdt_mux_f13 <= ramrdt_mux_f12;
			ramrdt_mux_f14 <= ramrdt_mux_f13;
			ramrdt_mux_f15 <= ramrdt_mux_f14;
			ramrdt_mux_f16 <= ramrdt_mux_f15;
			ramrdt_mux_f17 <= ramrdt_mux_f16;
			ramrdt_mux_f18 <= ramrdt_mux_f17;
		end if;
	end process;


-- SC4COLORON    = 0/1 SCREEN4 color off/on
-- SC4COLORMD(0) = 0/1 GREEN-PINK / RED-BLUE
-- SC4COLORMD(1) = 0/1 color normal/reverse
-- SC4COLORMD(2) = 0/1 にじみ暗 off/on
-- SC4COLORMD(3)       Don't use

--   Even時						桃/緑		赤/青
--   v
-- x000x 黒						X"311"		X"311"
-- x001x にじみ暗緑				X"311""373"	X"311""477"
-- x010x にじみ赤				X"F55"		X"F31"
-- x011x 白						X"EFD"		X"EFD"
-- x100x にじみ暗緑				X"373""311"	X"477""311"
-- 01010 にじみ緑				X"3F5"		X"8EF"
-- 01011 にじみ暗緑				X"373""311"	X"477""311"
-- 11010 にじみ暗緑				X"311""373"	X"311""477"
-- 11011 にじみ暗緑				X"311""373"	X"311""477"
-- x110x 白						X"EFD"		X"EFD"
-- x111x 白						X"EFD"		X"EFD"
-- 43210

--   Odd時							緑/桃		青/赤
--   v
-- x000x 黒						X"311"		X"311"
-- x001x にじみ暗赤				X"311""733"	X"311""711"
-- x010x にじみ緑				X"3F5"		X"8EF"
-- x011x 白						X"EFD"		X"EFD"
-- x100x にじみ暗赤				X"733""311"	X"711""311"
-- 01010 にじみ赤				X"F55"		X"F31"
-- 01011 にじみ赤				X"733""311"	X"711""311"
-- 11010 にじみ赤				X"311""733"	X"311""711"
-- 11011 にじみ赤				X"311""733"	X"311""711"
-- x110x 白						X"EFD"		X"EFD"
-- x111x 白						X"EFD"		X"EFD"
-- 43210


	bitpat(0) <=	'1' when (ramrdt_mux_f6  = "01110" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f2  = "01110" and LCDMODE = '1') else
					'0';

	bitpat(1) <=	'1' when (ramrdt_mux_f8  = "01110" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f6  = "01110" and LCDMODE = '1') else
					'0';

	bitpat(2) <=	'1' when (ramrdt_mux_f10 = "01110" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f10 = "01110" and LCDMODE = '1') else
					'0';

	bitpat(3) <=	'1' when (ramrdt_mux_f12 = "01110" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f14 = "01110" and LCDMODE = '1') else
					'0';

	bitpat(4) <=	'1' when (ramrdt_mux_f14 = "01110" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f18 = "01110" and LCDMODE = '1') else
					'0';



	set2p <=
				X"301010" when (bitpat(3 downto 1) = "000")  else

				X"307030" when (bitpat(3 downto 1) = "001"  and LCDMODE = '1') else
				X"307030" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"30FF50" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"307030" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF5050" when (bitpat(3 downto 1) = "010")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "011")  else

				X"307030" when (bitpat(3 downto 1) = "100"  and LCDMODE = '1') else
				X"30FF50" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"307030" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"307030" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"30FF50" when (bitpat            = "01010") else

				X"307030" when (bitpat            = "01011" and LCDMODE = '1') else
				X"30FF50" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"307030" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"307030" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"307030" when (bitpat            = "11010" and LCDMODE = '1') else
				X"307030" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"30FF50" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"307030" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"307030" when (bitpat            = "11011" and LCDMODE = '1') else
				X"307030" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"30FF50" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"307030" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"E0FFD0" when (bitpat(3 downto 1) = "110")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "111")  else
				X"000000";

	set2r <=
				X"301010" when (bitpat(3 downto 1) = "000")  else

				X"407070" when (bitpat(3 downto 1) = "001"  and LCDMODE = '1') else
				X"407070" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"80E0FF" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"407070" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF3010" when (bitpat(3 downto 1) = "010")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "011")  else

				X"407070" when (bitpat(3 downto 1) = "100"  and LCDMODE = '1') else
				X"80E0FF" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"407070" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"407070" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"80E0FF" when (bitpat            = "01010") else

				X"407070" when (bitpat            = "01011" and LCDMODE = '1') else
				X"80E0FF" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"407070" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"407070" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"407070" when (bitpat            = "11010" and LCDMODE = '1') else
				X"407070" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"80E0FF" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"407070" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"407070" when (bitpat            = "11011" and LCDMODE = '1') else
				X"407070" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"80E0FF" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"407070" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"E0FFD0" when (bitpat(3 downto 1) = "110")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "111")  else
				X"000000";

	set2g <=
				X"301010" when (bitpat(3 downto 1) = "000")  else

				X"703030" when (bitpat(3 downto 1) = "001"  and LCDMODE = '1') else
				X"703030" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF5050" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"703030" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"30FF50" when (bitpat(3 downto 1) = "010")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "011")  else

				X"703030" when (bitpat(3 downto 1) = "100"  and LCDMODE = '1') else
				X"FF5050" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"703030" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"703030" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF5050" when (bitpat            = "01010") else

				X"703030" when (bitpat            = "01011" and LCDMODE = '1') else
				X"FF5050" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"703030" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"703030" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"703030" when (bitpat            = "11010" and LCDMODE = '1') else
				X"703030" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF5050" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"703030" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"703030" when (bitpat            = "11011" and LCDMODE = '1') else
				X"703030" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF5050" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"703030" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"E0FFD0" when (bitpat(3 downto 1) = "110")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "111")  else
				X"000000";

	set2b <=
				X"301010" when (bitpat(3 downto 1) = "000")  else

				X"701010" when (bitpat(3 downto 1) = "001"  and LCDMODE = '1') else
				X"701010" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF3010" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"701010" when (bitpat(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"80E0FF" when (bitpat(3 downto 1) = "010")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "011")  else

				X"701010" when (bitpat(3 downto 1) = "100"  and LCDMODE = '1') else
				X"FF3010" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"701010" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"701010" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF3010" when (bitpat            = "01010") else

				X"701010" when (bitpat            = "01011" and LCDMODE = '1') else
				X"FF3010" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"701010" when (bitpat            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"701010" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"301010" when (bitpat            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"701010" when (bitpat            = "11010" and LCDMODE = '1') else
				X"701010" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF3010" when (bitpat            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"701010" when (bitpat            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"701010" when (bitpat            = "11011" and LCDMODE = '1') else
				X"701010" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF3010" when (bitpat            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"301010" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"701010" when (bitpat            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"E0FFD0" when (bitpat(3 downto 1) = "110")  else
				X"E0FFD0" when (bitpat(3 downto 1) = "111")  else
				X"000000";


--   Even時						桃/緑		赤/青
--   v
-- x000x 黒						X"111"		X"111"
-- x001x にじみ暗緑				X"111""173"	X"111""477"
-- x010x にじみ赤				X"F55"		X"F31"
-- x011x 白						X"FFF"		X"FFF"
-- x100x にじみ暗緑				X"173""111"	X"477""111"
-- 01010 にじみ緑				X"1F5"		X"8EF"
-- 01011 にじみ暗緑				X"173""111"	X"477""111"
-- 11010 にじみ暗緑				X"111""173"	X"111""477"
-- 11011 にじみ暗緑				X"111""173"	X"111""477"
-- x110x 白						X"FFF"		X"FFF"
-- x111x 白						X"FFF"		X"FFF"
-- 43210

--   Odd時							緑/桃		青/赤
--   v
-- x000x 黒						X"111"		X"111"
-- x001x にじみ暗赤				X"111""733"	X"111""721"
-- x010x にじみ緑				X"1F5"		X"8EF"
-- x011x 白						X"FFF"		X"FFF"
-- x100x にじみ暗赤				X"733""111"	X"721""111"
-- 01010 にじみ赤				X"F55"		X"F31"
-- 01011 にじみ赤				X"733""111"	X"721""111"
-- 11010 にじみ赤				X"111""733"	X"111""721"
-- 11011 にじみ赤				X"111""733"	X"111""721"
-- x110x 白						X"FFF"		X"FFF"
-- x111x 白						X"FFF"		X"FFF"
-- 43210


	bitpt2(0) <=	'1' when (ramrdt_mux_f6  = "00100" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f2  = "00100" and LCDMODE = '1') else
					'0';

	bitpt2(1) <=	'1' when (ramrdt_mux_f8  = "00100" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f6  = "00100" and LCDMODE = '1') else
					'0';

	bitpt2(2) <=	'1' when (ramrdt_mux_f10 = "00100" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f10 = "00100" and LCDMODE = '1') else
					'0';

	bitpt2(3) <=	'1' when (ramrdt_mux_f12 = "00100" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f14 = "00100" and LCDMODE = '1') else
					'0';

	bitpt2(4) <=	'1' when (ramrdt_mux_f14 = "00100" and LCDMODE = '0') else
					'1' when (ramrdt_mux_f18 = "00100" and LCDMODE = '1') else
					'0';


	st2p2 <=
				X"101010" when (bitpt2(3 downto 1) = "000")  else

				X"107030" when (bitpt2(3 downto 1) = "001"  and LCDMODE = '1') else
				X"107030" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"10FF50" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"107030" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF5050" when (bitpt2(3 downto 1) = "010")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "011")  else

				X"107030" when (bitpt2(3 downto 1) = "100"  and LCDMODE = '1') else
				X"10FF50" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"107030" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"107030" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"10FF50" when (bitpt2            = "01010") else

				X"107030" when (bitpt2            = "01011" and LCDMODE = '1') else
				X"10FF50" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"107030" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"107030" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"107030" when (bitpt2            = "11010" and LCDMODE = '1') else
				X"107030" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"10FF50" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"107030" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"107030" when (bitpt2            = "11011" and LCDMODE = '1') else
				X"107030" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"10FF50" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"107030" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FFFFFF" when (bitpt2(3 downto 1) = "110")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "111")  else
				X"000000";

	st2r2 <=
				X"101010" when (bitpt2(3 downto 1) = "000")  else

				X"407070" when (bitpt2(3 downto 1) = "001"  and LCDMODE = '1') else
				X"407070" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"80E0FF" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"407070" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF3010" when (bitpt2(3 downto 1) = "010")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "011")  else

				X"407070" when (bitpt2(3 downto 1) = "100"  and LCDMODE = '1') else
				X"80E0FF" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"407070" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"407070" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"80E0FF" when (bitpt2            = "01010") else

				X"407070" when (bitpt2            = "01011" and LCDMODE = '1') else
				X"80E0FF" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"407070" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"407070" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"407070" when (bitpt2            = "11010" and LCDMODE = '1') else
				X"407070" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"80E0FF" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"407070" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"407070" when (bitpt2            = "11011" and LCDMODE = '1') else
				X"407070" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"80E0FF" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"407070" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FFFFFF" when (bitpt2(3 downto 1) = "110")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "111")  else
				X"000000";

	st2g2 <=
				X"101010" when (bitpt2(3 downto 1) = "000")  else

				X"703030" when (bitpt2(3 downto 1) = "001"  and LCDMODE = '1') else
				X"703030" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF5050" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"703030" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"10FF50" when (bitpt2(3 downto 1) = "010")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "011")  else

				X"703030" when (bitpt2(3 downto 1) = "100"  and LCDMODE = '1') else
				X"FF5050" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"703030" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"703030" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF5050" when (bitpt2            = "01010") else

				X"703030" when (bitpt2            = "01011" and LCDMODE = '1') else
				X"FF5050" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"703030" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"703030" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"703030" when (bitpt2            = "11010" and LCDMODE = '1') else
				X"703030" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF5050" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"703030" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"703030" when (bitpt2            = "11011" and LCDMODE = '1') else
				X"703030" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF5050" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"703030" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FFFFFF" when (bitpt2(3 downto 1) = "110")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "111")  else
				X"000000";

	st2b2 <=
				X"101010" when (bitpt2(3 downto 1) = "000")  else

				X"702010" when (bitpt2(3 downto 1) = "001"  and LCDMODE = '1') else
				X"702010" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF3010" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"702010" when (bitpt2(3 downto 1) = "001"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"80E0FF" when (bitpt2(3 downto 1) = "010")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "011")  else

				X"702010" when (bitpt2(3 downto 1) = "100"  and LCDMODE = '1') else
				X"FF3010" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"702010" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"702010" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2(3 downto 1) = "100"  and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FF3010" when (bitpt2            = "01010") else

				X"702010" when (bitpt2            = "01011" and LCDMODE = '1') else
				X"FF3010" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"702010" when (bitpt2            = "01011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"702010" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"101010" when (bitpt2            = "01011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"702010" when (bitpt2            = "11010" and LCDMODE = '1') else
				X"702010" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF3010" when (bitpt2            = "11010" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"702010" when (bitpt2            = "11010" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else

				X"702010" when (bitpt2            = "11011" and LCDMODE = '1') else
				X"702010" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '0')   else
				X"FF3010" when (bitpt2            = "11011" and SC4COLORMD(2) = '1' and hcntrd(0) = '1')   else
				X"101010" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '0')   else
				X"702010" when (bitpt2            = "11011" and SC4COLORMD(2) = '0' and hcntrd(0) = '1')   else
				X"FFFFFF" when (bitpt2(3 downto 1) = "110")  else
				X"FFFFFF" when (bitpt2(3 downto 1) = "111")  else
				X"000000";


-- "00000" -- mode1 set1 Green
-- "00001" -- mode1 set1 Buff
-- "00010" -- mode1 set2 Orange
-- "00011" -- mode1 set2 Buff
-- "00101" -- mode2 Green
-- "00111" -- mode2 Orange
-- "01000" -- mode3 set1 Green
-- "01001" -- mode3 set2 Orange
-- "01100" -- mode4 set1 Green
-- "01101" -- mode4 set1 Black
-- "01110" -- mode4 set2 Buff
-- "01111" -- mode4 set2 Black

-- "00100" -- mk2 mode4 set2 白
-- "00110" -- mk2 mode4 set2 黒

-- "10000" -- mk2   透明(黒)
-- "10001" -- mk2   青紫
-- "10010" -- mk2   橙
-- "10011" -- mk2   赤紫
-- "10100" -- mk2   青緑
-- "10101" -- mk2   空色
-- "10110" -- mk2   黄緑
-- "10111" -- mk2   灰色
-- "11000" -- mk2   黒
-- "11001" -- mk2   青
-- "11010" -- mk2   赤
-- "11011" -- mk2   マゼンタ
-- "11100" -- mk2   緑
-- "11101" -- mk2   シアン
-- "11110" -- mk2   黄
-- "11111" -- mk2   白

	vgadat <=
				X"007E00" when (ramrdt_mux_f10 = "00000") else	-- mode1 set1 Green / mode4 set1 Black
				X"00EA00" when (ramrdt_mux_f10 = "00001") else	-- mode1 set1 Buff  / mode4 set1 Green
				X"A50B00" when (ramrdt_mux_f10 = "00010") else	-- mode1 set2 Orange
				X"FF6F00" when (ramrdt_mux_f10 = "00011") else	-- mode1 set2 Buff
				X"008000" when (ramrdt_mux_f10 = "00101") else	-- mode2 Green
				X"FF7000" when (ramrdt_mux_f10 = "00111") else	-- mode2 Orange
				X"30FF60" when (ramrdt_mux_f10 = "01000") else	-- mode3 Green
				X"FF7000" when (ramrdt_mux_f10 = "01001") else	-- mode3 Orange
				X"261D1C" when (ramrdt_mux_f10 = "01011") else	-- mode1/2 Black
				X"D2BEAB" when (ramrdt_mux_f10 = "01110" and SC4COLORON = '0') else	-- mode4 set2 Buff
				X"20211A" when (ramrdt_mux_f10 = "01111" and SC4COLORON = '0') else	-- mode4 set2 Black
				X"FFFFFF" when (ramrdt_mux_f10 = "00100" and SC4COLORON = '0') else	-- mk2 mode4 set2 白
				X"101010" when (ramrdt_mux_f10 = "00110" and SC4COLORON = '0') else	-- mk2 mode4 set2 黒

				X"101010" when (ramrdt_mux_f10 = "10000") else	-- mk2 透明(黒)
				X"B000FF" when (ramrdt_mux_f10 = "10001") else	-- mk2 青紫
				X"FFB000" when (ramrdt_mux_f10 = "10010") else	-- mk2 橙
				X"FF00B0" when (ramrdt_mux_f10 = "10011") else	-- mk2 赤紫
				X"00FFB0" when (ramrdt_mux_f10 = "10100") else	-- mk2 青緑
				X"00B0FF" when (ramrdt_mux_f10 = "10101") else	-- mk2 空色
				X"B0FF00" when (ramrdt_mux_f10 = "10110") else	-- mk2 黄緑
				X"B0B0B0" when (ramrdt_mux_f10 = "10111") else	-- mk2 灰色
				X"101010" when (ramrdt_mux_f10 = "11000") else	-- mk2 黒
				X"0000FF" when (ramrdt_mux_f10 = "11001") else	-- mk2 青
				X"FF0000" when (ramrdt_mux_f10 = "11010") else	-- mk2 赤
				X"FF00FF" when (ramrdt_mux_f10 = "11011") else	-- mk2 マゼンタ
				X"00FF00" when (ramrdt_mux_f10 = "11100") else	-- mk2 緑
				X"00FFFF" when (ramrdt_mux_f10 = "11101") else	-- mk2 シアン
				X"FFFF00" when (ramrdt_mux_f10 = "11110") else	-- mk2 黄
				X"FFFFFF" when (ramrdt_mux_f10 = "11111") else	-- mk2 白

				set2p  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '0' and
							hcntrd(1) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				set2p  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '1' and
							hcntrd(2) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				set2r  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '0' and
							hcntrd(1) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else
				set2r  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '1' and
							hcntrd(2) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else
				set2g  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '0' and
							hcntrd(1) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				set2g  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '1' and
							hcntrd(2) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				set2b  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '0' and
							hcntrd(1) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else
				set2b  when ((ramrdt_mux_f10 = "01111" or ramrdt_mux_f10 = "01110") and LCDMODE = '1' and
							hcntrd(2) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else

				st2p2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '0' and
							hcntrd(1) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				st2p2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '1' and
							hcntrd(2) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				st2r2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '0' and
							hcntrd(1) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else
				st2r2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '1' and
							hcntrd(2) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else
				st2g2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '0' and
							hcntrd(1) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				st2g2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '1' and
							hcntrd(2) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '0') else
				st2b2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '0' and
							hcntrd(1) =     SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else
				st2b2  when ((ramrdt_mux_f10 = "00110" or ramrdt_mux_f10 = "00100") and LCDMODE = '1' and
							hcntrd(2) = not SC4COLORMD(0) and SC4COLORON = '1' and SC4COLORMD(1) = '1') else

				X"000000";


	vga_r_f12 <= X"00" when (r_hblk_f12 = '1' or r_vblk_f12 = '1') else vgadat(23 downto 16);
	vga_g_f12 <= X"00" when (r_hblk_f12 = '1' or r_vblk_f12 = '1') else vgadat(15 downto  8);
	vga_b_f12 <= X"00" when (r_hblk_f12 = '1' or r_vblk_f12 = '1') else vgadat( 7 downto  0);


	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			vga_r_f13  <= (others => '0');
			vga_g_f13  <= (others => '0');
			vga_b_f13  <= (others => '0');
			vga_hs_f13 <= '1';
			vga_vs_f13 <= '1';
			lcd_r_f13  <= (others => '0');
			lcd_g_f13  <= (others => '0');
			lcd_b_f13  <= (others => '0');
			lcd_hs_f13 <= '1';
			lcd_vs_f13 <= '1';
		elsif (CLK25M'event and CLK25M = '1') then
			if (LCDMODE = '0') then
				vga_r_f13  <= vga_r_f12;
				vga_g_f13  <= vga_g_f12;
				vga_b_f13  <= vga_b_f12;
				vga_hs_f13 <= vga_hs_f12;
				vga_vs_f13 <= vga_vs_f12;
				lcd_r_f13  <= (others => '0');
				lcd_g_f13  <= (others => '0');
				lcd_b_f13  <= (others => '0');
				lcd_hs_f13 <= '1';
				lcd_vs_f13 <= '1';
			else
				vga_r_f13  <= (others => '0');
				vga_g_f13  <= (others => '0');
				vga_b_f13  <= (others => '0');
				vga_hs_f13 <= '1';
				vga_vs_f13 <= '1';
				lcd_r_f13  <= vga_r_f12;
				lcd_g_f13  <= vga_g_f12;
				lcd_b_f13  <= vga_b_f12;
				lcd_hs_f13 <= vga_hs_f12;
				lcd_vs_f13 <= vga_vs_f12;
			end if;
		end if;
	end process;

	process (CLK25M,RSTN)
	begin
		if (RSTN = '0') then
			lcd_clk_f1 <= '0';
		elsif (CLK25M'event and CLK25M = '1') then
			if (LCDMODE = '0') then
				lcd_clk_f1 <= '0';
			else
				lcd_clk_f1 <= hcntrd(1);
			end if;
		end if;
	end process;

	BUSRQMASK	<= busrqmask_i;

	VGA_R		<= vga_r_f13(7 downto 4);
	VGA_G		<= vga_g_f13(7 downto 4);
	VGA_B		<= vga_b_f13(7 downto 4);
	VGA_HS		<= vga_hs_f13;
	VGA_VS		<= vga_vs_f13;

	LCD_R		<= lcd_r_f13;
	LCD_G		<= lcd_g_f13;
	LCD_B		<= lcd_b_f13;
	LCD_HSN		<= lcd_hs_f13;
	LCD_VSN		<= lcd_vs_f13;
	LCD_CLK     <= lcd_clk_f1;
	LCD_DEN     <= '0';

end RTL;
