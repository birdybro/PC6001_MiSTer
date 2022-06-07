--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SDREAD_CMDCNT is
	port (
		SD_DAT0		: in  std_logic;
		SD_WP		: in  std_logic;
		CMD_START	: in  std_logic;
		CMD_NO		: in  std_logic_vector(5 downto 0);
		SDADD		: in  std_logic_vector(31 downto 0);
		SDCNTENB	: in  std_logic;
		OUTDT		: in  std_logic_vector(7 downto 0);
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		STATEOUT	: out std_logic_vector(7 downto 0);
		INDT		: out std_logic_vector(7 downto 0);
		INDTENB		: out std_logic;
		OUTDTENB	: out std_logic;
		INDTLT		: out std_logic;
		INDTLT2		: out std_logic;
		CMD_END		: out std_logic;
		IDLEDET		: out std_logic;
		ERRDET		: out std_logic;
		SD_CMD		: out std_logic;
		SD_DAT		: out std_logic_vector(3 downto 1);
		SD_CLK		: out std_logic
	);
end SDREAD_CMDCNT;

architecture RTL of SDREAD_CMDCNT is

	component SDREAD_TMGCNT is
		port (
			SD_DAT0		: in  std_logic;
			OUTDT		: in  std_logic_vector(7 downto 0);
			OUTENB		: in  std_logic;
			OUTCS		: in  std_logic;
			SDCNTENB	: in  std_logic;
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			INDT		: out std_logic_vector(7 downto 0);
			STATELT		: out std_logic;
			OUTDTLT		: out std_logic;
			INDTLT		: out std_logic;
			INDTLT2		: out std_logic;
			SD_CMD		: out std_logic;
			SD_DAT		: out std_logic_vector(3 downto 1);
			SD_CLK		: out std_logic
		);
	end component;

	signal statecnt		: std_logic_vector(7 downto 0);

	signal outdt_i		: std_logic_vector(7 downto 0);
	signal outenb_i		: std_logic;
	signal outcs_i		: std_logic;

	signal indt_i		: std_logic_vector(7 downto 0);
	signal statelt_i	: std_logic;
	signal outdtlt_i	: std_logic;
	signal indtlt_i		: std_logic;

	signal cmd_end_i	: std_logic;
	signal idledet_i	: std_logic;
	signal errdet_i		: std_logic;
	signal indtenb_i	: std_logic;
	signal outdtenb_i	: std_logic;

	signal res_timer	: std_logic_vector(9 downto 0);

	signal cmddt		: std_logic_vector(47 downto 0);

begin

	U_SDREAD_TMGCNT : SDREAD_TMGCNT
	port map (
		SD_DAT0		=> SD_DAT0,
		OUTDT		=> outdt_i,
		OUTENB		=> outenb_i,
		OUTCS		=> outcs_i,
		SDCNTENB	=> SDCNTENB,
		CLK			=> CLK,
		RSTN		=> RSTN,
		INDT		=> indt_i,
		STATELT		=> statelt_i,
		OUTDTLT		=> outdtlt_i,
		INDTLT		=> indtlt_i,
		INDTLT2		=> INDTLT2,
		SD_CMD		=> SD_CMD,
		SD_DAT		=> SD_DAT,
		SD_CLK		=> SD_CLK
	);


-- state counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			statecnt   <= X"00";
			outcs_i    <= '0';
			outenb_i   <= '0';
			outdt_i    <= X"FF";
			cmd_end_i  <= '0';
			res_timer  <= (others => '0');
			errdet_i   <= '0';
			idledet_i  <= '0';
			indtenb_i  <= '0';
			outdtenb_i <= '0';
		elsif (CLK'event and CLK = '1') then

			if (SDCNTENB = '0') then
				statecnt   <= X"00";
				outcs_i    <= '0';
				outenb_i   <= '0';
				outdt_i    <= X"FF";
				cmd_end_i  <= '0';
				res_timer  <= (others => '0');
				errdet_i   <= '0';
				idledet_i  <= '0';
				indtenb_i  <= '0';
				outdtenb_i <= '0';
			elsif (statelt_i = '1') then

				case statecnt is
					when X"00"  =>			-- command accept
						outcs_i    <= '0';
						outenb_i   <= '0';
						outdt_i    <= X"FF";
						cmd_end_i  <= '0';
						res_timer  <= (others => '0');
						errdet_i   <= '0';
						idledet_i  <= '0';
						indtenb_i  <= '0';
						outdtenb_i <= '0';

						if (CMD_START = '1') then
							if (CMD_NO = "000000") then
								statecnt  <= X"10";		-- 1ms wait
							else
								statecnt  <= X"01";		-- send command
							end if;
						end if;

					when X"01"  =>			-- 1 clock wait without clock
						outcs_i   <= '1';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						statecnt  <= X"02";

					when X"02"  =>			-- command #1 send
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= cmddt(47 downto 40);
						statecnt  <= X"03";

					when X"03"  =>			-- command #2 send
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= cmddt(39 downto 32);
						statecnt  <= X"04";
					when X"04"  =>			-- command #3 send
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= cmddt(31 downto 24);
						statecnt  <= X"05";
					when X"05"  =>			-- command #4 send
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= cmddt(23 downto 16);
						statecnt  <= X"06";
					when X"06"  =>			-- command #5 send
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= cmddt(15 downto 8);
						statecnt  <= X"07";
					when X"07"  =>			-- command #6 send
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= cmddt(7 downto 0);
						statecnt  <= X"08";

					when X"08"  =>			-- wait response
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						if (res_timer = 1023) then		-- time out
							res_timer <= (others => '0');
							statecnt  <= X"FF";
						elsif (indt_i = X"FF") then			-- before response
							res_timer <= res_timer + 1;
						elsif (indt_i = X"00") then			-- normal response
							res_timer <= (others => '0');
							if (CMD_NO = "000000") then
								statecnt  <= X"FF";
							elsif (CMD_NO = "010001") then
								statecnt  <= X"18";
							elsif (CMD_NO = "011000") then
								statecnt  <= X"20";
							else
								statecnt  <= X"09";
							end if;
						elsif (indt_i = X"01") then			-- normal response (Idle)
							res_timer <= (others => '0');
							idledet_i <= '1';
							if (CMD_NO = "000000") then
								statecnt  <= X"09";
							elsif (CMD_NO = "000001") then
								statecnt  <= X"09";
							else
								statecnt  <= X"FF";
							end if;
						else								-- error detect
							res_timer <= (others => '0');
							statecnt  <= X"FF";
						end if;

					when X"09"	=>			-- 1 clock wait without clock
						outcs_i   <= '1';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						statecnt  <= X"0A";
						indtenb_i <= '0';

					when X"0A"	=>			-- 1 clock wait without clock
						outcs_i   <= '0';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						statecnt  <= X"0B";

					when X"0B"	=>			-- 1 clock wait with clock
						outcs_i   <= '0';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						statecnt  <= X"0C";

					when X"0C"	=>			-- 1 clock wait without clock and command end
						outcs_i   <= '0';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						cmd_end_i <= '1';
						res_timer <= (others => '0');
						statecnt  <= X"00";
						errdet_i  <= '0';


					when X"10"	=>			-- 1ms wait without clock
						outcs_i   <= '0';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						cmd_end_i <= '0';
						errdet_i  <= '0';
						idledet_i <= '0';
						if (res_timer = 100) then
							statecnt  <= X"11";
							res_timer <= (others => '0');
						else
							res_timer <= res_timer + 1;
						end if;

					when X"11"	=>			-- 10 byte dummy output
						outcs_i   <= '0';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						cmd_end_i <= '0';
						errdet_i  <= '0';
						idledet_i <= '0';
						if (res_timer = 10) then
							statecnt  <= X"12";
							res_timer <= (others => '0');
						else
							res_timer <= res_timer + 1;
						end if;

					when X"12"	=>			-- 1 clock wait without clock
						outcs_i   <= '0';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						statecnt  <= X"01";


					when X"18"  =>			-- wait read data
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						if (res_timer = 1023) then		-- time out
							res_timer <= (others => '0');
							statecnt  <= X"FF";
						elsif (indt_i = X"FF") then			-- before response
							res_timer <= res_timer + 1;
						elsif (indt_i = X"FE") then			-- read start block
							res_timer <= (others => '0');
							statecnt  <= X"19";
							indtenb_i <= '1';
						else								-- error detect
							res_timer <= (others => '0');
							statecnt  <= X"FF";
						end if;

					when X"19"	=>		-- read data
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						if (res_timer = 511) then		-- data read finish
							res_timer <= res_timer + 1;
							statecnt  <= X"1A";
							indtenb_i <= '0';
						else
							res_timer <= res_timer + 1;
							indtenb_i <= '1';
						end if;

					when X"1A"	=>		-- read crc
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						if (res_timer = 513) then		-- data read finish
							res_timer <= (others => '0');
							statecnt  <= X"09";
						else
							res_timer <= res_timer + 1;
						end if;


					when X"20"	=>			-- 1 clock wait with clock
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						statecnt  <= X"21";

					when X"21"	=>			-- 1 clock wait with clock
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						statecnt  <= X"22";

					when X"22"	=>			-- write data output (header)
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FE";
						outdtenb_i <= '0';
						res_timer <= (others => '0');
						statecnt  <= X"23";

					when X"23"	=>			-- write data output
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= OUTDT;		-- dummy data
						outdtenb_i <= '1';
						if (res_timer = 511) then
							res_timer <= res_timer + 1;
							statecnt  <= X"24";
						else
							res_timer <= res_timer + 1;
						end if;

					when X"24"	=>			-- write data output (crc)
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"00";
						outdtenb_i <= '0';
						if (res_timer = 513) then
							res_timer <= (others => '0');
							statecnt  <= X"25";
						else
							res_timer <= res_timer + 1;
						end if;

					when X"25"  =>			-- wait data response
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						if (res_timer = 1023) then					-- time out
							res_timer <= (others => '0');
							statecnt  <= X"FF";
						elsif (indt_i = X"FF") then					-- before response
							res_timer <= res_timer + 1;
						elsif (indt_i(4 downto 0) = "00101") then	-- read normal end
							res_timer <= (others => '0');
							statecnt  <= X"26";
							indtenb_i <= '1';
						else										-- error detect
							res_timer <= (others => '0');
							statecnt  <= X"FF";
						end if;

					when X"26"  =>			-- wait data response
						outcs_i   <= '1';
						outenb_i  <= '1';
						outdt_i   <= X"FF";
						if (indt_i = X"FF") then		-- not busy
							statecnt  <= X"09";
						end if;


					when X"FF"	=>			-- error detect
						statecnt  <= X"00";
						outcs_i   <= '0';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						cmd_end_i <= '1';
						res_timer <= (others => '0');
						errdet_i  <= '1';

					when others =>
						statecnt  <= X"00";
						outcs_i   <= '0';
						outenb_i  <= '0';
						outdt_i   <= X"FF";
						cmd_end_i <= '1';
						res_timer <= (others => '0');
						errdet_i  <= '0';

				end case;

			end if;
		end if;
	end process;


	process (CMD_NO,SDADD,SD_WP)
	begin
		case CMD_NO is
			when "000000" => cmddt <= X"400000000095";
			when "000001" => cmddt <= X"410000000000";
			when "010000" => cmddt <= X"500000020000";
			when "010001" => cmddt <= X"51" & SDADD & X"00";
			when "011000" =>
				if (SD_WP = '0') then
							cmddt <= X"58" & SDADD & X"00";
				else
							cmddt <= X"500000020000";	-- dummy command
				end if;
			when others   => cmddt <= X"FFFFFFFFFFFF";
		end case;
	end process;

	STATEOUT <= statecnt;
	INDT     <= indt_i;
	INDTENB  <= indtenb_i;
	OUTDTENB <= outdtenb_i;
	INDTLT   <= indtlt_i;
	CMD_END  <= cmd_end_i;
	ERRDET   <= errdet_i;
	IDLEDET  <= idledet_i;

end RTL;
