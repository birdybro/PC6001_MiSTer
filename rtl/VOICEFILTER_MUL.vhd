--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity VOICEFILTER_MUL is
	port (
		DI			: in  std_logic_vector(13 downto 0);
		F			: in  std_logic_vector(9 downto 0);
		START		: in  std_logic;
		CLK			: in  std_logic;
		RSTN		: in  std_logic;
		DO			: out std_logic_vector(13 downto 0)
	);
end VOICEFILTER_MUL;

architecture RTL of VOICEFILTER_MUL is
	signal di_p		: std_logic_vector(13 downto 0);
	signal di_m		: std_logic_vector(13 downto 0);

	signal plscnt	: std_logic_vector(4 downto 0);

	signal mul_s	: std_logic_vector(10 downto 0);
	signal mul_q	: std_logic_vector(23 downto 0);

begin

-- control counter
	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			plscnt <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (START = '1') then
				plscnt <= "00001";
			elsif (plscnt /= "00000") then
				plscnt <= plscnt + 1;
			end if;
		end if;
	end process;

	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			di_p <= (others => '0');
			di_m <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (START = '1') then
				di_p <= DI;
				di_m <= (not DI) + 1;
			end if;
		end if;
	end process;


	process (CLK,RSTN)
	begin
		if (RSTN = '0') then
			mul_q <= (others => '0');
			mul_s <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (START = '1') then
				mul_q <= (others => '0');
				mul_s <= F & "0";
			elsif (2 <= plscnt and plscnt < 22) then
				if (plscnt(0) = '0') then
					if    (mul_s(1 downto 0) = "01") then
						mul_q <= mul_q + (di_p & "0000000000");
					elsif (mul_s(1 downto 0) = "10") then
						mul_q <= mul_q + (di_m & "0000000000");
					end if;
				else
					mul_q <= mul_q(23) & mul_q(23 downto 1);
					mul_s <= "0" & mul_s(10 downto 1);
				end if;
			end if;
		end if;
	end process;

	DO <= mul_q(22 downto 9);

end RTL;
