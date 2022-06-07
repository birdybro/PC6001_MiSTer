--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SEG7SUB is
	port (
		DATA		: in  std_logic_vector(7 downto 0);
		HEX_D		: out std_logic_vector(6 downto 0);
		HEX_DP		: out std_logic
	);
end SEG7SUB;

architecture RTL of SEG7SUB is

	signal hexout	: std_logic_vector(7 downto 0);

begin

--
--  --       a
-- |  |    f   b
--  --       g
-- |  |    e   c
--  -- .     d   dp
--

	hexout <=
			--	".ABCDEFG"
				"00000000" when (DATA = X"20") else		-- SPC
				"00000001" when (DATA = X"2D") else		-- -
				"10000000" when (DATA = X"2E") else		-- .
				"01111110" when (DATA = X"30") else		-- 0
				"00110000" when (DATA = X"31") else		-- 1
				"01101101" when (DATA = X"32") else		-- 2
				"01111001" when (DATA = X"33") else		-- 3
				"00110011" when (DATA = X"34") else		-- 4
				"01011011" when (DATA = X"35") else		-- 5
				"01011111" when (DATA = X"36") else		-- 6
				"01110000" when (DATA = X"37") else		-- 7
				"01111111" when (DATA = X"38") else		-- 8
				"01111011" when (DATA = X"39") else		-- 9
				"00001001" when (DATA = X"3D") else		-- =
				"01111101" when (DATA = X"40") else		-- @
				"01110111" when (DATA = X"41") else		-- A
				"00011111" when (DATA = X"42") else		-- B
				"01001110" when (DATA = X"43") else		-- C
				"00111101" when (DATA = X"44") else		-- D
				"01001111" when (DATA = X"45") else		-- E
				"01000111" when (DATA = X"46") else		-- F
				"01011110" when (DATA = X"47") else		-- G
				"00110111" when (DATA = X"48") else		-- H
				"00010000" when (DATA = X"49") else		-- I
				"00111100" when (DATA = X"4A") else		-- J
				"10010110" when (DATA = X"4B") else		-- K
				"00001110" when (DATA = X"4C") else		-- L
				"11110110" when (DATA = X"4D") else		-- M
				"00010101" when (DATA = X"4E") else		-- N
				"00011101" when (DATA = X"4F") else		-- 0
				"01100111" when (DATA = X"50") else		-- P
				"01110011" when (DATA = X"51") else		-- Q
				"00000101" when (DATA = X"52") else		-- R
				"11011011" when (DATA = X"53") else		-- S
				"00001111" when (DATA = X"54") else		-- T
				"00111110" when (DATA = X"55") else		-- U
				"00100111" when (DATA = X"56") else		-- V
				"10111111" when (DATA = X"57") else		-- W
				"10110110" when (DATA = X"58") else		-- X
				"00111011" when (DATA = X"59") else		-- Y
				"11101101" when (DATA = X"5A") else		-- Z
				"00001000" when (DATA = X"5F") else		-- _
				"01000000" when (DATA = X"7E") else		-- ~
				"11001001";

	HEX_D  <= not (hexout(0) & hexout(1) & hexout(2) & hexout(3) & hexout(4) & hexout(5) & hexout(6) );
	HEX_DP <= not hexout(7);

end RTL;
