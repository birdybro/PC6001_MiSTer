--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity VOICE7752 is
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
end VOICE7752;

architecture RTL of VOICE7752 is
	signal a_f1		: std_logic_vector(1 downto 0);
	signal a_f2		: std_logic_vector(1 downto 0);
	signal csn_f1	: std_logic;
	signal csn_f2	: std_logic;
	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;
	signal wrn_f3	: std_logic;

	signal param_i	: std_logic_vector(7 downto 0);
	signal paramst	: std_logic;
	signal mode		: std_logic_vector(2 downto 0);
	signal command	: std_logic_vector(7 downto 0);
	signal voicest	: std_logic;
	signal voiceed	: std_logic;

	signal busy_i	: std_logic;
	signal err_i	: std_logic;

	signal dev1200khz	: std_logic_vector(3 downto 0);
	signal clk1200khz	: std_logic;
	signal dev10khz		: std_logic_vector(6 downto 0);
	signal clk10khz		: std_logic;

	signal com_end		: std_logic;
	signal com_int		: std_logic;
	signal com_ext		: std_logic;
	signal intenb		: std_logic;
	signal extenb		: std_logic;

	signal req_i		: std_logic;
	signal pnum			: std_logic_vector(2 downto 0);
	signal paramsetend	: std_logic;
	signal datrep		: std_logic;
	signal timecnt		: std_logic_vector(4 downto 0);
	signal datend		: std_logic;

	signal impcnt		: std_logic_vector(7 downto 0);		-- bit width temporary
	signal impulse		: std_logic;
	signal noisecnt		: std_logic_vector(14 downto 0);
	signal noisepls		: std_logic;

	signal initfrmcnt	: std_logic_vector(5 downto 0);
	signal initfrmpls	: std_logic;
	signal initerrpls	: std_logic;
	signal frmcnt		: std_logic_vector(7 downto 0);
	signal frmpls		: std_logic;
	signal errpls		: std_logic;

	signal p_time_lt	: std_logic_vector(4 downto 0);
	signal p_qmag_lt	: std_logic;
	signal p_si_lt		: std_logic;
	signal p_vuv_lt		: std_logic;
	signal p_f1_lt		: std_logic_vector(4 downto 0);
	signal p_f2_lt		: std_logic_vector(4 downto 0);
	signal p_f3_lt		: std_logic_vector(4 downto 0);
	signal p_f4_lt		: std_logic_vector(4 downto 0);
	signal p_f5_lt		: std_logic_vector(4 downto 0);
	signal p_b1_lt		: std_logic_vector(2 downto 0);
	signal p_b2_lt		: std_logic_vector(2 downto 0);
	signal p_b3_lt		: std_logic_vector(2 downto 0);
	signal p_b4_lt		: std_logic_vector(2 downto 0);
	signal p_b5_lt		: std_logic_vector(2 downto 0);
	signal p_amp_lt		: std_logic_vector(3 downto 0);
	signal p_fv_lt		: std_logic;
	signal p_p_lt		: std_logic_vector(2 downto 0);

	signal p_si			: std_logic;
	signal p_vuv		: std_logic;
	signal p_fv			: std_logic;
	signal p_f1			: std_logic_vector(6 downto 0);
	signal p_f2			: std_logic_vector(6 downto 0);
	signal p_f3			: std_logic_vector(6 downto 0);
	signal p_f4			: std_logic_vector(6 downto 0);
	signal p_f5			: std_logic_vector(6 downto 0);
	signal p_b1			: std_logic_vector(5 downto 0);
	signal p_b2			: std_logic_vector(5 downto 0);
	signal p_b3			: std_logic_vector(5 downto 0);
	signal p_b4			: std_logic_vector(5 downto 0);
	signal p_b5			: std_logic_vector(5 downto 0);
	signal p_p			: std_logic_vector(7 downto 0);	-- bit width temporary
	signal p_amp		: std_logic_vector(7 downto 0);
	signal p_f1_d1		: std_logic_vector(6 downto 0);
	signal p_f2_d1		: std_logic_vector(6 downto 0);
	signal p_f3_d1		: std_logic_vector(6 downto 0);
	signal p_f4_d1		: std_logic_vector(6 downto 0);
	signal p_f5_d1		: std_logic_vector(6 downto 0);
	signal p_b1_d1		: std_logic_vector(5 downto 0);
	signal p_b2_d1		: std_logic_vector(5 downto 0);
	signal p_b3_d1		: std_logic_vector(5 downto 0);
	signal p_b4_d1		: std_logic_vector(5 downto 0);
	signal p_b5_d1		: std_logic_vector(5 downto 0);
	signal p_p_d1		: std_logic_vector(7 downto 0);	-- bit width temporary
	signal p_amp_d1		: std_logic_vector(7 downto 0);

	signal p_amp_tbl	: std_logic_vector(7 downto 0);

	signal p_f1_c		: std_logic_vector(6 downto 0);
	signal p_f2_c		: std_logic_vector(6 downto 0);
	signal p_f3_c		: std_logic_vector(6 downto 0);
	signal p_f4_c		: std_logic_vector(6 downto 0);
	signal p_f5_c		: std_logic_vector(6 downto 0);
	signal p_b1_c		: std_logic_vector(5 downto 0);
	signal p_b2_c		: std_logic_vector(5 downto 0);
	signal p_b3_c		: std_logic_vector(5 downto 0);
	signal p_b4_c		: std_logic_vector(5 downto 0);
	signal p_b5_c		: std_logic_vector(5 downto 0);
	signal p_p_c		: std_logic_vector(7 downto 0);	-- bit width temporary
	signal p_amp_c		: std_logic_vector(7 downto 0);

	signal dv_impulse	: std_logic_vector(13 downto 0);
	signal dv_noise		: std_logic_vector(13 downto 0);

	signal dv_0			: std_logic_vector(13 downto 0);
	signal dv_5			: std_logic_vector(13 downto 0);
	signal srst			: std_logic;

	signal vstbenb		: std_logic;
	signal clk10khz_d1	: std_logic;
	signal clk10khz_d2	: std_logic;

	signal dsndout		: std_logic_vector(8 downto 0);
	signal sigma		: std_logic_vector(10 downto 0);
	signal sndout_i		: std_logic;

	component VOICEFILTER is
		port (
			DI		: in  std_logic_vector(13 downto 0);
			F1		: in  std_logic_vector(6 downto 0);
			F2		: in  std_logic_vector(6 downto 0);
			F3		: in  std_logic_vector(6 downto 0);
			F4		: in  std_logic_vector(6 downto 0);
			F5		: in  std_logic_vector(6 downto 0);
			B1		: in  std_logic_vector(5 downto 0);
			B2		: in  std_logic_vector(5 downto 0);
			B3		: in  std_logic_vector(5 downto 0);
			B4		: in  std_logic_vector(5 downto 0);
			B5		: in  std_logic_vector(5 downto 0);
			ENB		: in  std_logic;
			SRST	: in  std_logic;
			CLK		: in  std_logic;
			RSTN	: in  std_logic;
			DO		: out std_logic_vector(13 downto 0)
		);
	end component;

begin

-- clock generate
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			dev1200khz <= (others => '0');
			clk1200khz <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (dev1200khz = 11) then
				dev1200khz <= (others => '0');
				clk1200khz <= '1';
			else
				dev1200khz <= dev1200khz + 1;
				clk1200khz <= '0';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			dev10khz <= (others => '0');
			clk10khz <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (clk1200khz = '1') then
				if (dev10khz = 119) then
					dev10khz <= (others => '0');
					clk10khz <= '1';
				else
					dev10khz <= dev10khz + 1;
					clk10khz <= '0';
				end if;
			else
				clk10khz <= '0';
			end if;
		end if;
	end process;


-- AD/CS/RD/WR latch
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			a_f1   <= "00";
			a_f2   <= "00";
			csn_f1 <= '1';
			csn_f2 <= '1';
			wrn_f1 <= '1';
			wrn_f2 <= '1';
			wrn_f3 <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
			a_f1   <= A;
			a_f2   <= a_f1;
			csn_f1 <= CSN;
			csn_f2 <= csn_f1;
			wrn_f1 <= WRN;
			wrn_f2 <= wrn_f1;
			wrn_f3 <= wrn_f2;
		end if;
	end process;

-- formant parameter write (A="00")
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			param_i <= (others => '0');
			paramst <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (a_f2 = "00" and csn_f2 = '0' and wrn_f2 = '0') then
				param_i <= DI;
			end if;
			if (a_f2 = "00" and csn_f2 = '0' and wrn_f2 = '0' and wrn_f3 = '1') then
				paramst <= '1';
			else
				paramst <= '0';
			end if;
		end if;
	end process;

-- mode write (A="10")
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			mode <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (a_f2 = "10" and csn_f2 = '0' and wrn_f2 = '0') then
				mode <= DI(2 downto 0);
			end if;
		end if;
	end process;

-- command write (A="11")
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			command <= (others => '1');
			voicest <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (a_f2 = "11" and csn_f2 = '0' and wrn_f2 = '0') then
				command <= DI;
			end if;
			if (a_f2 = "11" and csn_f2 = '0' and wrn_f2 = '0' and wrn_f3 = '1') then
				voicest   <= '1';
			elsif (clk10khz = '1') then
				voicest   <= '0';
			end if;
		end if;
	end process;

-- enable / reset
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			busy_i <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (com_end = '1' or voiceed = '1') then
				busy_i <= '0';
			elsif (voicest = '1') then
				busy_i <= '1';
			end if;
		end if;
	end process;

	com_end <= '1' when (clk10khz = '1' and voicest = '1' and command = X"FF") else '0';
	com_ext <= '1' when (clk10khz = '1' and voicest = '1' and command = X"FE") else '0';
	com_int <= '1' when (clk10khz = '1' and voicest = '1' and command(7 downto 1) /= "1111111") else '0';

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			intenb <= '0';
			extenb <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (com_end = '1' or voiceed = '1') then
				intenb <= '0';
			elsif (com_int = '1') then
				intenb <= '1';
			end if;
			if (com_end = '1' or voiceed = '1') then
				extenb <= '0';
			elsif (com_ext = '1') then
				extenb <= '1';
			end if;
		end if;
	end process;

-- 1st frame ganerate
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			initfrmcnt <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (com_end = '1' or voiceed = '1') then
				initfrmcnt <= (others => '0');
			elsif (clk10khz = '1') then
				if (com_ext = '1') then
					initfrmcnt <= "000001";
				elsif (initfrmcnt /= 0) then
					initfrmcnt <= initfrmcnt + 1;
				end if;
			end if;
		end if;
	end process;

	initfrmpls <=
		'1' when (mode(1 downto 0) = "00" and initfrmcnt = 50 and clk10khz = '1') else	-- 5.0 ms
		'1' when (mode(1 downto 0) = "01" and initfrmcnt = 60 and clk10khz = '1') else	-- 6.0 ms
		'1' when (mode(1 downto 0) = "10" and initfrmcnt = 40 and clk10khz = '1') else	-- 4.0 ms
		'1' when (mode(1 downto 0) = "11" and initfrmcnt = 50 and clk10khz = '1') else	-- 5.0 ms
		'0';

	initerrpls <=
		'1' when (mode(1 downto 0) = "00" and initfrmcnt = 25 and clk10khz = '1') else	-- 2.5 ms
		'1' when (mode(1 downto 0) = "01" and initfrmcnt = 30 and clk10khz = '1') else	-- 3.0 ms
		'1' when (mode(1 downto 0) = "10" and initfrmcnt = 20 and clk10khz = '1') else	-- 2.0 ms
		'1' when (mode(1 downto 0) = "11" and initfrmcnt = 25 and clk10khz = '1') else	-- 2.5 ms
		'0';


-- frame generate (without 1st frame)
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			frmcnt <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (com_end = '1' or voiceed = '1') then
				frmcnt <= (others => '0');
			elsif (clk10khz = '1') then
				if (initfrmpls = '1' or frmpls = '1') then
					frmcnt <= "00000001";
				elsif (frmcnt /= 0) then
					frmcnt <= frmcnt + 1;
				end if;
			end if;
		end if;
	end process;

	frmpls <=	'1' when (mode = "000" and frmcnt = 100 and clk10khz = '1') else	-- 10.0 ms
				'1' when (mode = "001" and frmcnt = 120 and clk10khz = '1') else	-- 12.0 ms
				'1' when (mode = "010" and frmcnt =  80 and clk10khz = '1') else	--  8.0 ms
				'1' when (mode = "011" and frmcnt = 100 and clk10khz = '1') else	-- 10.0 ms
				'1' when (mode = "100" and frmcnt = 200 and clk10khz = '1') else	-- 20.0 ms
				'1' when (mode = "101" and frmcnt = 240 and clk10khz = '1') else	-- 24.0 ms
				'1' when (mode = "110" and frmcnt = 160 and clk10khz = '1') else	-- 16.0 ms
				'1' when (mode = "111" and frmcnt = 200 and clk10khz = '1') else	-- 20.0 ms
				'0';

	errpls <=	'1' when (mode = "000" and frmcnt =  75 and clk10khz = '1') else	--  7.5 ms
				'1' when (mode = "001" and frmcnt =  90 and clk10khz = '1') else	--  9.0 ms
				'1' when (mode = "010" and frmcnt =  60 and clk10khz = '1') else	--  6.0 ms
				'1' when (mode = "011" and frmcnt =  75 and clk10khz = '1') else	--  7.5 ms
				'1' when (mode = "100" and frmcnt = 150 and clk10khz = '1') else	-- 15.0 ms
				'1' when (mode = "101" and frmcnt = 180 and clk10khz = '1') else	-- 18.0 ms
				'1' when (mode = "110" and frmcnt = 120 and clk10khz = '1') else	-- 12.0 ms
				'1' when (mode = "111" and frmcnt = 150 and clk10khz = '1') else	-- 15.0 ms
				'0';


-- get parameter
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			req_i <= '0';
			pnum  <= "111";
		elsif (CLK14M'event and CLK14M = '1') then
			if (com_end = '1' or voiceed = '1') then
				req_i <= '0';
				pnum  <= "111";
			elsif (com_ext = '1') then						-- 1st param-1 get
				req_i <= '1';
				pnum  <= "000";
			elsif (initfrmpls = '1' or frmpls = '1') then	-- param-1 get (without 1st)
				req_i <= '1';
				if (datrep = '1') then
					pnum  <= "110";							-- TIMES > 1
				else
					pnum  <= "000";							-- TIMES = 1
				end if;
			elsif (clk1200khz = '1' and req_i = '0') then
				if (pnum = "110" or pnum = "111") then
					req_i <= '0';
					pnum  <= "111";
				else										-- param-2~7 get
					req_i <= '1';
					pnum  <= pnum + 1;
				end if;
			elsif (paramst = '1') then						-- error
				req_i <= '0';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			p_time_lt <= (others => '0');
			p_qmag_lt <= '0';
			p_si_lt   <= '0';
			p_vuv_lt  <= '0';
			p_f1_lt   <= (others => '0');
			p_f2_lt   <= (others => '0');
			p_f3_lt   <= (others => '0');
			p_f4_lt   <= (others => '0');
			p_f5_lt   <= (others => '0');
			p_b1_lt   <= (others => '0');
			p_b2_lt   <= (others => '0');
			p_b3_lt   <= (others => '0');
			p_b4_lt   <= (others => '0');
			p_b5_lt   <= (others => '0');
			p_amp_lt  <= (others => '0');
			p_fv_lt   <= '0';
			p_p_lt    <= (others => '0');
			datrep    <= '0';
			timecnt   <= (others => '0');
			datend    <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (com_end = '1' or voiceed = '1') then
				datrep    <= '0';
				timecnt   <= (others => '0');
				datend    <= '0';
			elsif (req_i = '1' and paramst = '1') then
				case pnum is
					when "000" =>								-- param-1
						p_time_lt <= param_i(7 downto 3);
						p_qmag_lt <= param_i(2);
						p_si_lt   <= param_i(1);
						p_vuv_lt  <= param_i(0);
						datrep    <= '0';
						datend    <= '0';
					when "001" =>								-- param-2
						p_f1_lt   <= param_i(7 downto 3);
						p_b1_lt   <= param_i(2 downto 0);
						datrep    <= '0';
						datend    <= '0';
					when "010" =>								-- param-3
						p_f2_lt   <= param_i(7 downto 3);
						p_b2_lt   <= param_i(2 downto 0);
						datrep    <= '0';
						datend    <= '0';
					when "011" =>								-- param-4
						p_f3_lt   <= param_i(7 downto 3);
						p_b3_lt   <= param_i(2 downto 0);
						datrep    <= '0';
						datend    <= '0';
					when "100" =>								-- param-5
						p_f4_lt   <= param_i(7 downto 3);
						p_b4_lt   <= param_i(2 downto 0);
						datrep    <= '0';
						datend    <= '0';
					when "101" =>								-- param-6
						p_f5_lt   <= param_i(7 downto 3);
						p_b5_lt   <= param_i(2 downto 0);
						datrep    <= '0';
						datend    <= '0';
					when "110" =>								-- param-7
						p_amp_lt  <= param_i(7 downto 4);
						p_fv_lt   <= param_i(3);
						p_p_lt    <= param_i(2 downto 0);
						if (p_time_lt = 0) then					-- TIMES = 0 (end param)
							datrep  <= '0';
							timecnt <= (others => '0');
							datend  <= '1';
						elsif (p_time_lt = 1) then				-- TIMES = 1
							datrep  <= '0';
							timecnt <= (others => '0');
							datend  <= '0';
						else									-- TIMES > 1
							datend  <= '0';
							if (datrep = '0') then
								datrep  <= '1';
								timecnt <= p_time_lt;
							else
								p_f1_lt   <= (others => '0');
								p_f2_lt   <= (others => '0');
								p_f3_lt   <= (others => '0');
								p_f4_lt   <= (others => '0');
								p_f5_lt   <= (others => '0');
								p_b1_lt   <= (others => '0');
								p_b2_lt   <= (others => '0');
								p_b3_lt   <= (others => '0');
								p_b4_lt   <= (others => '0');
								p_b5_lt   <= (others => '0');
								if (timecnt = 2) then
									datrep  <= '0';
									timecnt <= (others => '0');
								else
									datrep  <= '1';
									timecnt <= timecnt - 1;
								end if;
							end if;
						end if;
					when others =>
						null;
				end case;
			end if;
		end if;
	end process;


-- voice end
	voiceed <=
		'1' when (err_i = '1') else
		'1' when (extenb = '1' and (initfrmpls = '1' or frmpls = '1') and datend = '1') else
		'1' when (intenb = '1') else	-- dummy
		'0';


-- error detect
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			paramsetend <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (voicest = '1') then
				paramsetend <= '0';
			elsif (com_ext = '1' or initfrmpls = '1' or frmpls = '1') then
				paramsetend <= '0';
			elsif (paramst = '1' and pnum = "110") then
				paramsetend <= '1';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			err_i <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (voicest = '1') then
				err_i <= '0';
			elsif (req_i = '0' and paramst = '1') then
				err_i <= '1';
			elsif (initerrpls = '1' and paramsetend = '0') then
				err_i <= '1';
			elsif (errpls = '1' and paramsetend = '0') then
				err_i <= '1';
			end if;
		end if;
	end process;


-- calculate parameter
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			p_si     <= '0';
			p_vuv    <= '0';
			p_fv     <= '0';
			p_f1     <= (others => '0');
			p_f2     <= (others => '0');
			p_f3     <= (others => '0');
			p_f4     <= (others => '0');
			p_f5     <= (others => '0');
			p_b1     <= (others => '0');
			p_b2     <= (others => '0');
			p_b3     <= (others => '0');
			p_b4     <= (others => '0');
			p_b5     <= (others => '0');
			p_p      <= (others => '0');
			p_amp    <= (others => '0');
			p_f1_d1  <= (others => '0');
			p_f2_d1  <= (others => '0');
			p_f3_d1  <= (others => '0');
			p_f4_d1  <= (others => '0');
			p_f5_d1  <= (others => '0');
			p_b1_d1  <= (others => '0');
			p_b2_d1  <= (others => '0');
			p_b3_d1  <= (others => '0');
			p_b4_d1  <= (others => '0');
			p_b5_d1  <= (others => '0');
			p_p_d1   <= (others => '0');
			p_amp_d1 <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (extenb = '0' or intenb = '1') then
				p_si     <= '0';
				p_vuv    <= '0';
				p_fv     <= '0';
				p_f1     <= "1111110";
				p_f2     <= "1000000";
				p_f3     <= "1111001";
				p_f4     <= "1101111";
				p_f5     <= "1100000";
				p_b1     <= "001001";
				p_b2     <= "000100";
				p_b3     <= "001001";
				p_b4     <= "001001";
				p_b5     <= "001011";
				p_p      <= "00011110";
				p_amp    <= "00000000";
				p_f1_d1  <= "1111110";
				p_f2_d1  <= "1000000";
				p_f3_d1  <= "1111001";
				p_f4_d1  <= "1101111";
				p_f5_d1  <= "1100000";
				p_b1_d1  <= "001001";
				p_b2_d1  <= "000100";
				p_b3_d1  <= "001001";
				p_b4_d1  <= "001001";
				p_b5_d1  <= "001011";
				p_p_d1   <= "00011110";
				p_amp_d1 <= "00000000";
			elsif (initfrmpls = '1' or frmpls = '1') then
				p_si  <= p_si_lt;
				p_vuv <= p_vuv_lt;
				p_fv  <= p_fv_lt;

				if (p_qmag_lt = '0') then
					p_f1 <= p_f1 + (p_f1_lt(4) & p_f1_lt(4) & p_f1_lt);
					p_f2 <= p_f2 + (p_f2_lt(4) & p_f2_lt(4) & p_f2_lt);
					p_f3 <= p_f3 + (p_f3_lt(4) & p_f3_lt(4) & p_f3_lt);
					p_f4 <= p_f4 + (p_f4_lt(4) & p_f4_lt(4) & p_f4_lt);
					p_f5 <= p_f5 + (p_f5_lt(4) & p_f5_lt(4) & p_f5_lt);
					p_b1 <= p_b1 + (p_b1_lt(2) & p_b1_lt(2) & p_b1_lt(2) & p_b1_lt);
					p_b2 <= p_b2 + (p_b2_lt(2) & p_b2_lt(2) & p_b2_lt(2) & p_b2_lt);
					p_b3 <= p_b3 + (p_b3_lt(2) & p_b3_lt(2) & p_b3_lt(2) & p_b3_lt);
					p_b4 <= p_b4 + (p_b4_lt(2) & p_b4_lt(2) & p_b4_lt(2) & p_b4_lt);
					p_b5 <= p_b5 + (p_b5_lt(2) & p_b5_lt(2) & p_b5_lt(2) & p_b5_lt);
				else
					p_f1 <= p_f1 + (p_f1_lt(4) & p_f1_lt & "0");
					p_f2 <= p_f2 + (p_f2_lt(4) & p_f2_lt & "0");
					p_f3 <= p_f3 + (p_f3_lt(4) & p_f3_lt & "0");
					p_f4 <= p_f4 + (p_f4_lt(4) & p_f4_lt & "0");
					p_f5 <= p_f5 + (p_f5_lt(4) & p_f5_lt & "0");
					p_b1 <= p_b1 + (p_b1_lt(2) & p_b1_lt(2) & p_b1_lt & "0");
					p_b2 <= p_b2 + (p_b2_lt(2) & p_b2_lt(2) & p_b2_lt & "0");
					p_b3 <= p_b3 + (p_b3_lt(2) & p_b3_lt(2) & p_b3_lt & "0");
					p_b4 <= p_b4 + (p_b4_lt(2) & p_b4_lt(2) & p_b4_lt & "0");
					p_b5 <= p_b5 + (p_b5_lt(2) & p_b5_lt(2) & p_b5_lt & "0");
				end if;
				p_p   <= p_p  + (p_p_lt(2) & p_p_lt(2) & p_p_lt(2) & p_p_lt(2) & p_p_lt(2) & p_p_lt);
				p_amp <= p_amp_tbl;

				p_f1_d1  <= p_f1;
				p_f2_d1  <= p_f2;
				p_f3_d1  <= p_f3;
				p_f4_d1  <= p_f4;
				p_f5_d1  <= p_f5;
				p_b1_d1  <= p_b1;
				p_b2_d1  <= p_b2;
				p_b3_d1  <= p_b3;
				p_b4_d1  <= p_b4;
				p_b5_d1  <= p_b5;
				p_p_d1   <= p_p;
				p_amp_d1 <= p_amp;

			end if;
		end if;
	end process;

-- AMP table
	process (p_amp_lt)
	begin
		case p_amp_lt is
			when X"0" => p_amp_tbl <= X"00";
			when X"1" => p_amp_tbl <= X"01";
			when X"2" => p_amp_tbl <= X"01";
			when X"3" => p_amp_tbl <= X"02";
			when X"4" => p_amp_tbl <= X"03";
			when X"5" => p_amp_tbl <= X"04";
			when X"6" => p_amp_tbl <= X"05";
			when X"7" => p_amp_tbl <= X"07";
			when X"8" => p_amp_tbl <= X"09";
			when X"9" => p_amp_tbl <= X"0D";
			when X"A" => p_amp_tbl <= X"11";
			when X"B" => p_amp_tbl <= X"17";
			when X"C" => p_amp_tbl <= X"1F";
			when X"D" => p_amp_tbl <= X"2A";
			when X"E" => p_amp_tbl <= X"38";
			when X"F" => p_amp_tbl <= X"4B";
			when others => p_amp_tbl <= X"00";
		end case;
	end process;


-- middle caluculate

-- dummy
	p_f1_c  <= p_f1;
	p_f2_c  <= p_f2;
	p_f3_c  <= p_f3;
	p_f4_c  <= p_f4;
	p_f5_c  <= p_f5;
	p_b1_c  <= p_b1;
	p_b2_c  <= p_b2;
	p_b3_c  <= p_b3;
	p_b4_c  <= p_b4;
	p_b5_c  <= p_b5;
	p_p_c   <= p_p;
	p_amp_c <= p_amp;

-- genarate impulse
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			impcnt  <= "00000001";
			impulse <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (clk10khz = '1') then
				if (impcnt >= p_p_c) then
					impcnt <= "00000001";
					impulse <= '1';
				else
					impcnt <= impcnt + 1;
					impulse <= '0';
				end if;
			end if;
		end if;
	end process;

-- genarate noise
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			noisecnt <= (others => '1');
			noisepls <= '1';
		elsif (CLK14M'event and CLK14M = '1') then
			if (clk10khz = '1') then
										-- dummy
				noisecnt <= noisecnt(13 downto 1) & (noisecnt(14) xor noisecnt(0)) & noisecnt(14);
				noisepls <= noisecnt(14);
			end if;
		end if;
	end process;

-- sound source select (dummy)
	dv_impulse <= ("0000" & p_amp_c & "00") when (impulse  = '1') else (others => '0');
	dv_noise   <= ("000000" & p_amp_c)      when (noisepls = '1') else (others => '0');

	dv_0 <=	dv_noise              when (p_vuv = '0' and p_fv = '0') else
			dv_impulse            when (p_vuv = '1' and p_fv = '0') else
			dv_impulse + dv_noise when (p_vuv = '1' and p_fv = '1') else
			(others => '0');

	srst <= '0' when (intenb = '1' or extenb <= '1') else '1';

	U_VOICEFILTER : VOICEFILTER
	port map (
		DI		=> dv_0,
		F1		=> p_f1_c,
		F2		=> p_f2_c,
		F3		=> p_f3_c,
		F4		=> p_f4_c,
		F5		=> p_f5_c,
		B1		=> p_b1_c,
		B2		=> p_b2_c,
		B3		=> p_b3_c,
		B4		=> p_b4_c,
		B5		=> p_b5_c,
		ENB		=> clk10khz,
		SRST	=> srst,
		CLK		=> CLK14M,
		RSTN	=> RSTN,
		DO		=> dv_5
	);


-- output enable genarate
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			vstbenb <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			if (com_end = '1' or voiceed = '1') then
				vstbenb <= '0';
			elsif (initfrmpls = '1') then
				vstbenb <= '1';
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			clk10khz_d1 <= '0';
			clk10khz_d2 <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			clk10khz_d1 <= clk10khz;
			clk10khz_d2 <= clk10khz_d1;
		end if;
	end process;

-- 1bit D/A
	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			dsndout <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			if (vstbenb = '1') then
				dsndout <= dv_5(13 downto 5) + "100000000";
			else
				dsndout <= "100000000";
			end if;
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			sigma <= (others => '0');
		elsif (CLK14M'event and CLK14M = '1') then
			sigma <= (sigma(10) & sigma(10) & '0' & X"00") + sigma + ("00" & dsndout);
		end if;
	end process;

	process (CLK14M,RSTN)
	begin
		if (RSTN = '0') then
			sndout_i <= '0';
		elsif (CLK14M'event and CLK14M = '1') then
			sndout_i <= sigma(10);
		end if;
	end process;

	DO     <= busy_i & req_i & extenb & err_i & "0000" when (CSN = '0' and RDN = '0') else X"FF";
	SNDOUT <= sndout_i;
	BUSY   <= busy_i;
	REQ    <= req_i;
	VSTB   <= vstbenb and clk10khz_d2;
	DVO    <= dv_5;

end RTL;
