--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity CTRLREG is
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
end CTRLREG;

architecture RTL of CTRLREG is

	signal reg_lcdadd		: std_logic_vector(5 downto 0);	-- 0x8401(5:0)
	signal reg_lcddat		: std_logic_vector(7 downto 0);	-- 0x8402(7:0)
	signal reg_lcdst		: std_logic;					-- 0x8403(0)
	signal reg_lcdend		: std_logic;					-- 0x8403(0)
	signal reg_lcddone		: std_logic;					-- 0x8404(0)

	signal reg_ctrlselcpu	: std_logic;					-- 0x8410(0)
	signal reg_ctrlsel		: std_logic;					-- 0x8410(1)
	signal reg_ctrlrstcpu	: std_logic;					-- 0x8411(0)

	signal reg_mem16k		: std_logic;					-- 0x8412(0)
	signal reg_sc4coloron	: std_logic;					-- 0x8413(4)
	signal reg_sc4colormd	: std_logic_vector(3 downto 0);	-- 0x8413(3:0)
	signal reg_dbgtrg		: std_logic_vector(7 downto 0);	-- 0x8414(7:0)
	signal reg_keydat		: std_logic_vector(7 downto 0);	-- 0x8416(7:0)
	signal reg_keyenb		: std_logic;					-- 0x8417(0)
	signal reg_uartenb		: std_logic;					-- 0x8418(0)
	signal reg_uartlen		: std_logic_vector(19 downto 0);-- 0x8419 - 0x841B
	signal reg_exkanjienb	: std_logic;					-- 0x841C(0)

	signal reg_firmver		: std_logic_vector(15 downto 0);-- 0x8442 - 0x8443

	signal ctrlsel_i		: std_logic;
	signal ctrlrstn_i		: std_logic;
	signal ctrlrst_f1		: std_logic;
	signal ctrlrstcnt		: std_logic_vector(11 downto 0);

	signal reg_lcdst_f1		: std_logic;
	signal lcdcnt			: std_logic_vector(9 downto 0);
	signal lcddtsel			: std_logic_vector(3 downto 0);

	signal lcdcs_i			: std_logic;
	signal lcdsdi_i			: std_logic;
	signal lcdscl_i			: std_logic;

	signal datao_i			: std_logic_vector(7 downto 0);

	signal rdn_f1			: std_logic;
	signal rdn_f2			: std_logic;
	signal rdn_f3			: std_logic;
	signal wrn_f1			: std_logic;
	signal wrn_f2			: std_logic;
	signal wrn_f3			: std_logic;
	signal add_f1			: std_logic_vector(9 downto 0);
	signal add_f2			: std_logic_vector(9 downto 0);
	signal datai_f1			: std_logic_vector(7 downto 0);
	signal datai_f2			: std_logic_vector(7 downto 0);
	signal rdp				: std_logic;
	signal wrp				: std_logic;
	signal add_exp			: std_logic_vector(15 downto 0);

	signal funckey_f1		: std_logic_vector(23 downto 0);
	signal funckey_f2		: std_logic_vector(23 downto 0);
	signal funckey_f3		: std_logic_vector(23 downto 0);

begin

-- CPU I/F
-- data latch
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			rdn_f1   <= '1';
			rdn_f2   <= '1';
			rdn_f3   <= '1';
			wrn_f1   <= '1';
			wrn_f2   <= '1';
			wrn_f3   <= '1';
			add_f1   <= (others => '0');
			add_f2   <= (others => '0');
			datai_f1 <= (others => '0');
			datai_f2 <= (others => '0');
		elsif (CLK50M'event and CLK50M = '1') then
			rdn_f1   <= RDN;
			rdn_f2   <= rdn_f1;
			rdn_f3   <= rdn_f2;
			wrn_f1   <= WRN;
			wrn_f2   <= wrn_f1;
			wrn_f3   <= wrn_f2;
			add_f1   <= ADD;
			add_f2   <= add_f1;
			datai_f1 <= DATAI;
			datai_f2 <= datai_f1;
		end if;
	end process;

	rdp <= '1' when (rdn_f2 = '0' and rdn_f3 = '1') else '0';
	wrp <= '1' when (wrn_f2 = '0' and wrn_f3 = '1') else '0';

	add_exp <= "100001" & add_f2;

-- register
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_lcdadd     <= (others => '0');
			reg_lcddat     <= (others => '0');
			reg_lcdst      <= '0';
			reg_lcddone    <= '0';
			reg_ctrlselcpu <= '0';
			reg_ctrlsel    <= '0';
			reg_ctrlrstcpu <= '0';
			reg_mem16k     <= '0';
			reg_sc4coloron <= '1';
			reg_sc4colormd <= "0000";
			reg_dbgtrg     <= (others => '0');
			reg_firmver    <= (others => '0');
			reg_keydat     <= (others => '0');
			reg_keyenb     <= '0';
			reg_uartenb    <= '0';
			reg_uartlen    <= (others => '0');
			reg_exkanjienb <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (wrp = '1') then
				case add_exp is
					when X"8401" =>	reg_lcdadd               <= datai_f2(5 downto 0);
					when X"8402" =>	reg_lcddat               <= datai_f2;
					when X"8403" =>	reg_lcdst                <= datai_f2(0);
					when X"8404" =>	reg_lcddone              <= datai_f2(0);
					when X"8410" =>	reg_ctrlselcpu           <= datai_f2(0);
									reg_ctrlsel              <= datai_f2(1);
					when X"8411" =>	reg_ctrlrstcpu           <= datai_f2(0);
					when X"8412" => reg_mem16k               <= datai_f2(0);
					when X"8413" => reg_sc4coloron           <= datai_f2(4);
									reg_sc4colormd           <= datai_f2(3 downto 0);
					when X"8414" => reg_dbgtrg               <= datai_f2(7 downto 0);
					when X"8416" => reg_keydat               <= datai_f2(7 downto 0);
					when X"8417" => reg_keyenb               <= datai_f2(0);
					when X"8418" => reg_uartenb              <= datai_f2(0);
					when X"8419" => reg_uartlen( 7 downto  0)<= datai_f2;
					when X"841A" => reg_uartlen(15 downto  8)<= datai_f2;
					when X"841B" => reg_uartlen(19 downto 16)<= datai_f2(3 downto 0);
					when X"841C" => reg_exkanjienb           <= datai_f2(0);
					when X"8442" => reg_firmver( 7 downto 0) <= datai_f2;
					when X"8443" => reg_firmver(15 downto 8) <= datai_f2;
					when others  => null;
				end case;
			else
				reg_lcdst <= '0';
			end if;
		end if;
	end process;

-- register read
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			datao_i <= (others => '0');
		elsif (CLK50M'event and CLK50M = '1') then
			if (rdp = '1') then
				case add_exp is
					when X"8400" => datao_i <= "0000000" & LCDMODE;
					when X"8401" => datao_i <= "00" & reg_lcdadd;
					when X"8402" => datao_i <= reg_lcddat;
					when X"8403" => datao_i <= "0000000" & reg_lcdend;
					when X"8404" => datao_i <= "0000000" & reg_lcddone;
					when X"8410" => datao_i <= "000" & ctrlsel_i & "00" & reg_ctrlsel & reg_ctrlselcpu;
					when X"8411" => datao_i <= "0000000" & reg_ctrlrstcpu;
					when X"8412" => datao_i <= "0000000" & reg_mem16k;
					when X"8413" => datao_i <= "000" & reg_sc4coloron & reg_sc4colormd;
					when X"8414" => datao_i <= reg_dbgtrg;
					when X"8415" => datao_i <= "000000" & P66MODE & MK2MODE;
					when X"8416" => datao_i <= reg_keydat;
					when X"8417" => datao_i <= "0000000" & reg_keyenb;
					when X"8418" => datao_i <= "0000000" & reg_uartenb;
					when X"8419" => datao_i <= reg_uartlen( 7 downto  0);
					when X"841A" => datao_i <= reg_uartlen(15 downto  8);
					when X"841B" => datao_i <= "0000" & reg_uartlen(19 downto 16);
					when X"841C" => datao_i <= "0000000" & reg_exkanjienb;
					when X"8420" => datao_i <= funckey_f2( 7 downto  0);
					when X"8421" => datao_i <= funckey_f2(15 downto  8);
					when X"8422" => datao_i <= funckey_f2(23 downto 16);
					when X"8440" => datao_i <= FPGAVER( 7 downto  0);
					when X"8441" => datao_i <= FPGAVER(15 downto  8);
					when X"8442" => datao_i <= reg_firmver( 7 downto  0);
					when X"8443" => datao_i <= reg_firmver(15 downto  8);

					when others      => datao_i <= X"FF";
				end case;
			end if;
		end if;
	end process;


	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			funckey_f1 <= (others => '0');
			funckey_f2 <= (others => '0');
			funckey_f3 <= (others => '0');
		elsif (CLK50M'event and CLK50M = '1') then
			funckey_f1 <= FUNCKEY;
			funckey_f2 <= funckey_f1;
			funckey_f3 <= funckey_f2;
		end if;
	end process;


	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			ctrlsel_i <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_ctrlselcpu = '1') then
				ctrlsel_i <= reg_ctrlsel;
			elsif (funckey_f2(8) = '1' and funckey_f3(8) = '0') then
				ctrlsel_i <= not ctrlsel_i;
			end if;
		end if;
	end process;


	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			ctrlrst_f1 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_ctrlrstcpu = '1') then
				ctrlrst_f1 <= '1';
			elsif (funckey_f2(11) = '1' and funckey_f3(11) = '0') then
				ctrlrst_f1 <= '1';
			else
				ctrlrst_f1 <= '0';
			end if;
		end if;
	end process;

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			ctrlrstcnt <= X"FFF";
			ctrlrstn_i <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (ctrlrst_f1 = '1') then
				ctrlrstcnt <= X"000";
				ctrlrstn_i <= '0';
			elsif (ctrlrstcnt = X"FFF") then
				ctrlrstn_i <= '1';
			else
				ctrlrstcnt <= ctrlrstcnt + 1;
				ctrlrstn_i <= '0';
			end if;
		end if;
	end process;


	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_lcdst_f1 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			reg_lcdst_f1 <= reg_lcdst;
		end if;
	end process;

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			lcdcnt <= (others => '1');
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_lcdst_f1 = '0' and reg_lcdst = '1') then
				lcdcnt <= (others => '0');
			elsif (lcdcnt(9 downto 8) /= "11") then
				lcdcnt <= lcdcnt + 1;
			end if;
		end if;
	end process;

	lcddtsel <= lcdcnt(8 downto 5);

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_lcdend <= '1';
			lcdcs_i    <= '1';
			lcdsdi_i   <= '1';
			lcdscl_i   <= '1';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_lcdst_f1 = '0' and reg_lcdst = '1') then
				reg_lcdend <= '1';
				lcdcs_i    <= '1';
				lcdsdi_i   <= '1';
				lcdscl_i   <= '1';
			else

				if (lcdcnt(9 downto 8) = "11") then
					reg_lcdend <= '0';
				end if;

				lcdcs_i    <= lcdcnt(9);

				if (lcdcnt(9) = '0') then
					lcdscl_i <= lcdcnt(4);
				else
					lcdscl_i <= '1';
				end if;

				if (lcdcnt(9) = '0') then
					case lcddtsel is
						when "0000" => lcdsdi_i <= reg_lcdadd(5);
						when "0001" => lcdsdi_i <= reg_lcdadd(4);
						when "0010" => lcdsdi_i <= reg_lcdadd(3);
						when "0011" => lcdsdi_i <= reg_lcdadd(2);
						when "0100" => lcdsdi_i <= reg_lcdadd(1);
						when "0101" => lcdsdi_i <= reg_lcdadd(0);
						when "0110" => lcdsdi_i <= '1';		-- write(1)/read(0)
						when "0111" => lcdsdi_i <= '0';
						when "1000" => lcdsdi_i <= reg_lcddat(7);
						when "1001" => lcdsdi_i <= reg_lcddat(6);
						when "1010" => lcdsdi_i <= reg_lcddat(5);
						when "1011" => lcdsdi_i <= reg_lcddat(4);
						when "1100" => lcdsdi_i <= reg_lcddat(3);
						when "1101" => lcdsdi_i <= reg_lcddat(2);
						when "1110" => lcdsdi_i <= reg_lcddat(1);
						when "1111" => lcdsdi_i <= reg_lcddat(0);
						when others => lcdsdi_i <= '1';
					end case;
				else
					lcdsdi_i <= '1';
				end if;

			end if;
		end if;
	end process;


	DATAO      <= datao_i;

	LCDCS      <= lcdcs_i;
	LCDSDI     <= lcdsdi_i;
	LCDSCL     <= lcdscl_i;
	LCDDONE    <= reg_lcddone;

	CTRLSEL    <= ctrlsel_i;
	CTRLRSTN   <= ctrlrstn_i;

	MEM16K     <= reg_mem16k;
	SC4COLORON <= reg_sc4coloron;
	SC4COLORMD <= reg_sc4colormd;

	CTRLKEYDAT <= reg_keydat;
	CTRLKEYENB <= reg_keyenb;

	UARTENB    <= reg_uartenb;
	UARTLEN    <= reg_uartlen;
	EXKANJIENB <= reg_exkanjienb;

	FIRMVER   <= reg_firmver;
	DBGTRG     <= reg_dbgtrg;

end RTL;
