--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity AY38910 is
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
end AY38910;

architecture RTL of AY38910 is

	signal reg_tonea	: std_logic_vector(11 downto 0);
	signal reg_toneb	: std_logic_vector(11 downto 0);
	signal reg_tonec	: std_logic_vector(11 downto 0);
	signal reg_noise	: std_logic_vector(4 downto 0);
	signal reg_mixer	: std_logic_vector(7 downto 0);
	signal reg_vola		: std_logic_vector(4 downto 0);
	signal reg_volb		: std_logic_vector(4 downto 0);
	signal reg_volc		: std_logic_vector(4 downto 0);
	signal reg_envelope	: std_logic_vector(15 downto 0);
	signal reg_envsharp	: std_logic_vector(3 downto 0);
	signal reg_ioa		: std_logic_vector(7 downto 0);
	signal reg_iob		: std_logic_vector(7 downto 0);

	signal port_ia		: std_logic_vector(7 downto 0);
	signal port_ib		: std_logic_vector(7 downto 0);
	signal port_ia_f1	: std_logic_vector(7 downto 0);
	signal port_ib_f1	: std_logic_vector(7 downto 0);

	signal regadd	: std_logic_vector(7 downto 0);

	signal dao_i	: std_logic_vector(7 downto 0);

	signal dai_f1	: std_logic_vector(7 downto 0);
	signal dai_f2	: std_logic_vector(7 downto 0);
	signal dai_f3	: std_logic_vector(7 downto 0);
	signal dai_f4	: std_logic_vector(7 downto 0);

	signal bc1_f1	: std_logic;
	signal bc1_f2	: std_logic;
	signal bdir_f1	: std_logic;
	signal bdir_f2	: std_logic;
	signal a9n_f1	: std_logic;
	signal a9n_f2	: std_logic;

	signal envtrg	: std_logic;

	signal latad	: std_logic;
	signal latad_f1	: std_logic;

	signal tcntlow	: std_logic_vector(6 downto 0);

	signal tcntcha	: std_logic_vector(11 downto 0);
	signal tcntchb	: std_logic_vector(11 downto 0);
	signal tcntchc	: std_logic_vector(11 downto 0);
	signal tonecha	: std_logic;
	signal tonechb	: std_logic;
	signal tonechc	: std_logic;

	signal ncnt		: std_logic_vector(4 downto 0);
	signal ngen		: std_logic_vector(16 downto 0);

	signal envcnt	: std_logic_vector(15 downto 0);
	signal attack	: std_logic;
	signal initenv	: std_logic;
	signal holdenv	: std_logic;

	signal volenv	: std_logic_vector(3 downto 0);
	signal vola		: std_logic_vector(3 downto 0);
	signal volb		: std_logic_vector(3 downto 0);
	signal volc		: std_logic_vector(3 downto 0);

	signal t_a		: std_logic;
	signal t_b		: std_logic;
	signal t_c		: std_logic;
	signal n_a		: std_logic;
	signal n_b		: std_logic;
	signal n_c		: std_logic;

	signal dsndouta	: std_logic_vector(8 downto 0);
	signal dsndoutb	: std_logic_vector(8 downto 0);
	signal dsndoutc	: std_logic_vector(8 downto 0);

	signal dsndout	: std_logic_vector(10 downto 0);
	signal dsndout2	: std_logic_vector(8 downto 0);
	signal sigma	: std_logic_vector(10 downto 0);
	signal sndout_i	: std_logic;

begin

-- BC1/BDIR (BC2 = '1')
-- 00 INACTIVE
-- 10 READ FROM PSG
-- 01 WRITE TO PSG
-- 11 LATCH ADDRESS


-- input latch
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			bc1_f1  <= '0';
			bc1_f2  <= '0';
			bdir_f1 <= '0';
			bdir_f2 <= '0';
			a9n_f1  <= '1';
			a9n_f2  <= '1';
			dai_f1  <= (others => '0');
			dai_f2  <= (others => '0');
			dai_f3  <= (others => '0');
			dai_f4  <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			bc1_f1  <= BC1;
			bc1_f2  <= bc1_f1;
			bdir_f1 <= BDIR;
			bdir_f2 <= bdir_f1;
			a9n_f1  <= A9N;
			a9n_f2  <= a9n_f1;
			dai_f1  <= DAI;
			dai_f2  <= dai_f1;
			dai_f3  <= dai_f2;
			dai_f4  <= dai_f3;
		end if;
	end process;

	latad <= '1' when (a9n_f2 = '0' and bc1_f2 = '1' and bdir_f2 = '1') else '0';

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			latad_f1 <= '0';
		elsif (CLK'event and CLK = '1') then
			latad_f1 <= latad;
		end if;
	end process;

-- register address
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			regadd <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (latad = '1' and latad_f1 = '0') then
				regadd <= dai_f4;
			end if;
		end if;
	end process;

-- write register
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			reg_tonea    <= (others => '0');
			reg_toneb    <= (others => '0');
			reg_tonec    <= (others => '0');
			reg_noise    <= (others => '0');
			reg_mixer    <= X"38";
			reg_vola     <= (others => '0');
			reg_volb     <= (others => '0');
			reg_volc     <= (others => '0');
			reg_envelope <= (others => '0');
			reg_envsharp <= (others => '0');
			reg_ioa      <= (others => '1');
			reg_iob      <= (others => '1');
			envtrg       <= '0';
		elsif (CLK'event and CLK = '1') then
			if (a9n_f2 = '0' and bc1_f2 = '0' and bdir_f2 = '1') then
				case regadd is
					when X"00" => reg_tonea( 7 downto 0)    <= dai_f4;
					when X"01" => reg_tonea(11 downto 8)    <= dai_f4(3 downto 0);
					when X"02" => reg_toneb( 7 downto 0)    <= dai_f4;
					when X"03" => reg_toneb(11 downto 8)    <= dai_f4(3 downto 0);
					when X"04" => reg_tonec( 7 downto 0)    <= dai_f4;
					when X"05" => reg_tonec(11 downto 8)    <= dai_f4(3 downto 0);
					when X"06" => reg_noise                 <= dai_f4(4 downto 0);
					when X"07" => reg_mixer                 <= dai_f4;
					when X"08" => reg_vola                  <= dai_f4(4 downto 0);
					when X"09" => reg_volb                  <= dai_f4(4 downto 0);
					when X"0A" => reg_volc                  <= dai_f4(4 downto 0);
					when X"0B" => reg_envelope( 7 downto 0) <= dai_f4;
					when X"0C" => reg_envelope(15 downto 8) <= dai_f4;
					when X"0D" => reg_envsharp              <= dai_f4(3 downto 0);
					when X"0E" => reg_ioa                   <= dai_f4;
					when X"0F" => reg_iob                   <= dai_f4;
					when others => null;
				end case;
			end if;
			if (a9n_f2 = '0' and bc1_f2 = '0' and bdir_f2 = '1' and regadd = X"0D") then
				envtrg <= '1';
			else
				envtrg <= '0';
			end if;
		end if;
	end process;

-- read register
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dao_i <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (a9n_f2 = '0' and bc1_f2 = '1' and bdir_f2 = '0') then
				case regadd is
					when X"00" => dao_i <=          reg_tonea( 7 downto 0);
					when X"01" => dao_i <= "0000" & reg_tonea(11 downto 8);
					when X"02" => dao_i <=          reg_toneb( 7 downto 0);
					when X"03" => dao_i <= "0000" & reg_toneb(11 downto 8);
					when X"04" => dao_i <=          reg_tonec( 7 downto 0);
					when X"05" => dao_i <= "0000" & reg_tonec(11 downto 8);
					when X"06" => dao_i <= "000"  & reg_noise;
					when X"07" => dao_i <=          reg_mixer;
					when X"08" => dao_i <= "000"  & reg_vola;
					when X"09" => dao_i <= "000"  & reg_volb;
					when X"0A" => dao_i <= "000"  & reg_volc;
					when X"0B" => dao_i <=          reg_envelope( 7 downto 0);
					when X"0C" => dao_i <=          reg_envelope(15 downto 8);
					when X"0D" => dao_i <= "0000" & reg_envsharp;
					when X"0E" => dao_i <=          port_ia_f1;
					when X"0F" => dao_i <=          port_ib_f1;
					when others => dao_i <= regadd;
				end case;
			end if;
		end if;
	end process;


-- tone/noise counter low (4MHz)
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			tcntlow <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			tcntlow <= tcntlow + 1;
		end if;
	end process;

-- tone counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			tcntcha <= (others => '0');
			tcntchb <= (others => '0');
			tcntchc <= (others => '0');
			tonecha <= '0';
			tonechb <= '0';
			tonechc <= '0';
		elsif (CLK'event and CLK = '1') then
			if (tcntlow(5 downto 0) = "111111") then

				if (tcntcha = 0) then
					if (reg_tonea = 0) then
						tcntcha <= (others => '0');
					else
						tcntcha <= reg_tonea - 1;
					end if;
					tonecha <= not tonecha;
				else
					tcntcha <= tcntcha - 1;
				end if;

				if (tcntchb = 0) then
					if (reg_toneb = 0) then
						tcntchb <= (others => '0');
					else
						tcntchb <= reg_toneb - 1;
					end if;
					tonechb <= not tonechb;
				else
					tcntchb <= tcntchb - 1;
				end if;

				if (tcntchc = 0) then
					if (reg_tonec = 0) then
						tcntchc <= (others => '0');
					else
						tcntchc <= reg_tonec - 1;
					end if;
					tonechc <= not tonechc;
				else
					tcntchc <= tcntchc - 1;
				end if;

			end if;
		end if;
	end process;

-- noise counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			ncnt <= (others => '0');
			ngen <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (tcntlow = "1111111") then
				if (ncnt = 0) then
					if (reg_tonea = 0) then
						ncnt <= (others => '0');
					else
						ncnt <= reg_noise - 1;
					end if;
					ngen <= ngen(15 downto 0) & (ngen(16) xor ngen(13) xor '1');
				else
					ncnt <= ncnt - 1;
				end if;
			end if;
		end if;
	end process;


-- envelope generator
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			volenv  <= (others => '0');
			envcnt  <= (others => '0');
			attack  <= '0';
			initenv <= '0';
			holdenv <= '0';
		elsif (CLK'event and CLK = '1') then
			if (envtrg = '1') then
				initenv <= '1';
				holdenv <= '0';
				volenv  <= (others => '0');
			elsif (tcntlow = "1111111") then
				if (initenv = '1') then
					initenv <= '0';
					holdenv <= '0';
					if (reg_envelope = 0) then
						envcnt <= (others => '0');
					else
						envcnt <= reg_envelope - 1;
					end if;
					if (reg_envsharp(2) = '0') then
						volenv  <= "1111";
						attack  <= '0';
					else
						volenv  <= "0000";
						attack  <= '1';
					end if;

				elsif (envcnt = 0) then
					if (reg_envelope = 0) then
						envcnt <= (others => '0');
					else
						envcnt <= reg_envelope - 1;
					end if;

					if (holdenv = '0') then
						if ( (attack = '0' and volenv = "0000") or (attack = '1' and volenv = "1111") ) then

							if (reg_envsharp(3) = '0') then
								volenv <= "0000";
								holdenv <= '1';
							else
								if ( (reg_envsharp(1) xor reg_envsharp(0)) = '0') then
									volenv <= not volenv;
								else
									attack <= not attack;
								end if;
								if (reg_envsharp(0) = '1') then
									holdenv <= '1';
								end if;
							end if;

						elsif (attack = '0') then
							volenv <= volenv - 1;
						else
							volenv <= volenv + 1;
						end if;

					end if;

				else
					envcnt <= envcnt - 1;
				end if;
			end if;
		end if;
	end process;

	vola    <= volenv when (reg_vola(4) = '1') else reg_vola(3 downto 0);
	volb    <= volenv when (reg_volb(4) = '1') else reg_volb(3 downto 0);
	volc    <= volenv when (reg_volc(4) = '1') else reg_volc(3 downto 0);

-- channal mix
	t_a <=	'1' when (reg_mixer(0) = '1') else				-- always '1'
			'1' when (reg_tonea = 0 and reg_noise = 0) else	-- always '1'
			'1' when (tonecha = '1') else					-- tone-A outgoing
			'0';

	t_b <=	'1' when (reg_mixer(1) = '1') else				-- always '1'
			'1' when (reg_toneb = 0 and reg_noise = 0) else	-- always '1'
			'1' when (tonechb = '1') else					-- tone-B outgoing
			'0';

	t_c <=	'1' when (reg_mixer(2) = '1') else				-- always '1'
			'1' when (reg_tonec = 0 and reg_noise = 0) else	-- always '1'
			'1' when (tonechc = '1') else					-- tone-C outgoing
			'0';

	n_a <=	'1' when (reg_mixer(3) = '1') else				-- always '1'
			'1' when (ngen(0) = '1') else					-- noise outgoing
			'0';

	n_b <=	'1' when (reg_mixer(4) = '1') else				-- always '1'
			'1' when (ngen(0) = '1') else					-- noise outgoing
			'0';

	n_c <=	'1' when (reg_mixer(5) = '1') else				-- always '1'
			'1' when (ngen(0) = '1') else					-- noise outgoing
			'0';

-- mixer
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dsndouta <= (others => '0');
			dsndoutb <= (others => '0');
			dsndoutc <= (others => '0');
		elsif (CLK'event and CLK = '1') then

			if (t_a = '1' and n_a = '1') then
				case vola is
					when X"0" =>   dsndouta <= conv_std_logic_vector(  0*2,9);
					when X"1" =>   dsndouta <= conv_std_logic_vector(  2*2,9);
					when X"2" =>   dsndouta <= conv_std_logic_vector(  3*2,9);
					when X"3" =>   dsndouta <= conv_std_logic_vector(  4*2,9);
					when X"4" =>   dsndouta <= conv_std_logic_vector(  6*2,9);
					when X"5" =>   dsndouta <= conv_std_logic_vector(  8*2,9);
					when X"6" =>   dsndouta <= conv_std_logic_vector( 11*2,9);
					when X"7" =>   dsndouta <= conv_std_logic_vector( 16*2,9);
					when X"8" =>   dsndouta <= conv_std_logic_vector( 23*2,9);
					when X"9" =>   dsndouta <= conv_std_logic_vector( 32*2,9);
					when X"A" =>   dsndouta <= conv_std_logic_vector( 45*2,9);
					when X"B" =>   dsndouta <= conv_std_logic_vector( 64*2,9);
					when X"C" =>   dsndouta <= conv_std_logic_vector( 90*2,9);
					when X"D" =>   dsndouta <= conv_std_logic_vector(128*2,9);
					when X"E" =>   dsndouta <= conv_std_logic_vector(180*2,9);
					when X"F" =>   dsndouta <= conv_std_logic_vector(255*2,9);
					when others => dsndouta <= conv_std_logic_vector(  0*2,9);
				end case;
			elsif (t_a = '1' or n_a = '1') then
				case vola is
					when X"0" =>   dsndouta <= conv_std_logic_vector(  0,9);
					when X"1" =>   dsndouta <= conv_std_logic_vector(  2,9);
					when X"2" =>   dsndouta <= conv_std_logic_vector(  3,9);
					when X"3" =>   dsndouta <= conv_std_logic_vector(  4,9);
					when X"4" =>   dsndouta <= conv_std_logic_vector(  6,9);
					when X"5" =>   dsndouta <= conv_std_logic_vector(  8,9);
					when X"6" =>   dsndouta <= conv_std_logic_vector( 11,9);
					when X"7" =>   dsndouta <= conv_std_logic_vector( 16,9);
					when X"8" =>   dsndouta <= conv_std_logic_vector( 23,9);
					when X"9" =>   dsndouta <= conv_std_logic_vector( 32,9);
					when X"A" =>   dsndouta <= conv_std_logic_vector( 45,9);
					when X"B" =>   dsndouta <= conv_std_logic_vector( 64,9);
					when X"C" =>   dsndouta <= conv_std_logic_vector( 90,9);
					when X"D" =>   dsndouta <= conv_std_logic_vector(128,9);
					when X"E" =>   dsndouta <= conv_std_logic_vector(180,9);
					when X"F" =>   dsndouta <= conv_std_logic_vector(255,9);
					when others => dsndouta <= conv_std_logic_vector(  0,9);
				end case;
			else
				dsndouta <= (others => '0');
			end if;

			if (t_b = '1' and n_b = '1') then
				case volb is
					when X"0" =>   dsndoutb <= conv_std_logic_vector(  0*2,9);
					when X"1" =>   dsndoutb <= conv_std_logic_vector(  2*2,9);
					when X"2" =>   dsndoutb <= conv_std_logic_vector(  3*2,9);
					when X"3" =>   dsndoutb <= conv_std_logic_vector(  4*2,9);
					when X"4" =>   dsndoutb <= conv_std_logic_vector(  6*2,9);
					when X"5" =>   dsndoutb <= conv_std_logic_vector(  8*2,9);
					when X"6" =>   dsndoutb <= conv_std_logic_vector( 11*2,9);
					when X"7" =>   dsndoutb <= conv_std_logic_vector( 16*2,9);
					when X"8" =>   dsndoutb <= conv_std_logic_vector( 23*2,9);
					when X"9" =>   dsndoutb <= conv_std_logic_vector( 32*2,9);
					when X"A" =>   dsndoutb <= conv_std_logic_vector( 45*2,9);
					when X"B" =>   dsndoutb <= conv_std_logic_vector( 64*2,9);
					when X"C" =>   dsndoutb <= conv_std_logic_vector( 90*2,9);
					when X"D" =>   dsndoutb <= conv_std_logic_vector(128*2,9);
					when X"E" =>   dsndoutb <= conv_std_logic_vector(180*2,9);
					when X"F" =>   dsndoutb <= conv_std_logic_vector(255*2,9);
					when others => dsndoutb <= conv_std_logic_vector(  0*2,9);
				end case;
			elsif (t_b = '1' or n_b = '1') then
				case volb is
					when X"0" =>   dsndoutb <= conv_std_logic_vector(  0,9);
					when X"1" =>   dsndoutb <= conv_std_logic_vector(  2,9);
					when X"2" =>   dsndoutb <= conv_std_logic_vector(  3,9);
					when X"3" =>   dsndoutb <= conv_std_logic_vector(  4,9);
					when X"4" =>   dsndoutb <= conv_std_logic_vector(  6,9);
					when X"5" =>   dsndoutb <= conv_std_logic_vector(  8,9);
					when X"6" =>   dsndoutb <= conv_std_logic_vector( 11,9);
					when X"7" =>   dsndoutb <= conv_std_logic_vector( 16,9);
					when X"8" =>   dsndoutb <= conv_std_logic_vector( 23,9);
					when X"9" =>   dsndoutb <= conv_std_logic_vector( 32,9);
					when X"A" =>   dsndoutb <= conv_std_logic_vector( 45,9);
					when X"B" =>   dsndoutb <= conv_std_logic_vector( 64,9);
					when X"C" =>   dsndoutb <= conv_std_logic_vector( 90,9);
					when X"D" =>   dsndoutb <= conv_std_logic_vector(128,9);
					when X"E" =>   dsndoutb <= conv_std_logic_vector(180,9);
					when X"F" =>   dsndoutb <= conv_std_logic_vector(255,9);
					when others => dsndoutb <= conv_std_logic_vector(  0,9);
				end case;
			else
				dsndoutb <= (others => '0');
			end if;

			if (t_c = '1' and n_c = '1') then
				case volc is
					when X"0" =>   dsndoutc <= conv_std_logic_vector(  0*2,9);
					when X"1" =>   dsndoutc <= conv_std_logic_vector(  2*2,9);
					when X"2" =>   dsndoutc <= conv_std_logic_vector(  3*2,9);
					when X"3" =>   dsndoutc <= conv_std_logic_vector(  4*2,9);
					when X"4" =>   dsndoutc <= conv_std_logic_vector(  6*2,9);
					when X"5" =>   dsndoutc <= conv_std_logic_vector(  8*2,9);
					when X"6" =>   dsndoutc <= conv_std_logic_vector( 11*2,9);
					when X"7" =>   dsndoutc <= conv_std_logic_vector( 16*2,9);
					when X"8" =>   dsndoutc <= conv_std_logic_vector( 23*2,9);
					when X"9" =>   dsndoutc <= conv_std_logic_vector( 32*2,9);
					when X"A" =>   dsndoutc <= conv_std_logic_vector( 45*2,9);
					when X"B" =>   dsndoutc <= conv_std_logic_vector( 64*2,9);
					when X"C" =>   dsndoutc <= conv_std_logic_vector( 90*2,9);
					when X"D" =>   dsndoutc <= conv_std_logic_vector(128*2,9);
					when X"E" =>   dsndoutc <= conv_std_logic_vector(180*2,9);
					when X"F" =>   dsndoutc <= conv_std_logic_vector(255*2,9);
					when others => dsndoutc <= conv_std_logic_vector(  0*2,9);
				end case;
			elsif (t_c = '1' or n_c = '1') then
				case volc is
					when X"0" =>   dsndoutc <= conv_std_logic_vector(  0,9);
					when X"1" =>   dsndoutc <= conv_std_logic_vector(  2,9);
					when X"2" =>   dsndoutc <= conv_std_logic_vector(  3,9);
					when X"3" =>   dsndoutc <= conv_std_logic_vector(  4,9);
					when X"4" =>   dsndoutc <= conv_std_logic_vector(  6,9);
					when X"5" =>   dsndoutc <= conv_std_logic_vector(  8,9);
					when X"6" =>   dsndoutc <= conv_std_logic_vector( 11,9);
					when X"7" =>   dsndoutc <= conv_std_logic_vector( 16,9);
					when X"8" =>   dsndoutc <= conv_std_logic_vector( 23,9);
					when X"9" =>   dsndoutc <= conv_std_logic_vector( 32,9);
					when X"A" =>   dsndoutc <= conv_std_logic_vector( 45,9);
					when X"B" =>   dsndoutc <= conv_std_logic_vector( 64,9);
					when X"C" =>   dsndoutc <= conv_std_logic_vector( 90,9);
					when X"D" =>   dsndoutc <= conv_std_logic_vector(128,9);
					when X"E" =>   dsndoutc <= conv_std_logic_vector(180,9);
					when X"F" =>   dsndoutc <= conv_std_logic_vector(255,9);
					when others => dsndoutc <= conv_std_logic_vector(  0,9);
				end case;
			else
				dsndoutc <= (others => '0');
			end if;

		end if;
	end process;

-- sound mix
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			dsndout  <= (others => '0');
			dsndout2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			dsndout  <=	("00" & dsndouta) + ("00" & dsndoutb) + ("00" & dsndoutc);
			if (dsndout(10) = '0') then
				dsndout2 <=	dsndout(9 downto 1);
			else
				dsndout2 <=	(others => '1');
			end if;
		end if;
	end process;


-- 1bit D/A
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sigma <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			sigma <= (sigma(10) & sigma(10) & '0' & X"00") + sigma + ("00" & dsndout2);
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			sndout_i <= '0';
		elsif (CLK'event and CLK = '1') then
			sndout_i <= sigma(10);
		end if;
	end process;


-- I/O port
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			port_ia    <= (others => '1');
			port_ib    <= (others => '1');
			port_ia_f1 <= (others => '1');
			port_ib_f1 <= (others => '1');
		elsif (CLK'event and CLK = '1') then
			port_ia    <= IA;
			port_ib    <= IB;
			port_ia_f1 <= port_ia;
			port_ib_f1 <= port_ib;
		end if;
	end process;


	ENBAN  <= not reg_mixer(6);
	ENBBN  <= not reg_mixer(7);

	OA     <= reg_ioa;
	OB     <= reg_iob;


	SNDOUT <= sndout_i;
	DAO    <= dao_i;

	DSND   <= dsndout2;


end RTL;
