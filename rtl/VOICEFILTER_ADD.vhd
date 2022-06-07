--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity VOICEFILTER_ADD is
	port (
		A			: in  std_logic_vector(13 downto 0);
		B			: in  std_logic_vector(13 downto 0);
		C			: in  std_logic_vector(13 downto 0);
		DO			: out std_logic_vector(13 downto 0)
	);
end VOICEFILTER_ADD;

architecture RTL of VOICEFILTER_ADD is

begin

	process(A,B,C)
		variable sum1	: std_logic_vector(13 downto 0);
		variable sum2	: std_logic_vector(13 downto 0);
		variable y1		: std_logic_vector(13 downto 0);
		variable y2		: std_logic_vector(13 downto 0);
	begin

		sum1 := A + B;

		if    (A(13) = '0' and B(13) = '0') then
			if (sum1(13) = '0') then
				y1 := sum1;
			else
				y1 := "01" & X"FFF";
			end if;
		elsif (A(13) = '1' and B(13) = '1') then
			if (sum1(13) = '1') then
				y1 := sum1;
			else
				y1 := "10" & X"000";
			end if;
		else
			y1 := sum1;
		end if;

		sum2 := y1 + C;

		if    (y1(13) = '0' and C(13) = '0') then
			if (sum2(13) = '0') then
				y2 := sum2;
			else
				y2 := "01" & X"FFF";
			end if;
		elsif (y1(13) = '1' and C(13) = '1') then
			if (sum2(13) = '1') then
				y2 := sum2;
			else
				y2 := "10" & X"000";
			end if;
		else
			y2 := sum2;
		end if;

		DO <= y2;

	end process;

end RTL;
