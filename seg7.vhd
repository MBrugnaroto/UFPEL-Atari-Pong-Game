library ieee;
use ieee.std_logic_1164.all;

entity seg7 is
port(

	entrada: integer range 0 to 8;
	saida1: out std_logic_vector (6 downto 0)
	);
end seg7;

architecture arqseg of seg7 is
begin
	
	with entrada SELECT
	
	saida1 <=
			"0000001" when 0,
			"1001111" when 1,
			"0010010" when 2,
			"0000110" when 3,
			"1001100" when 4,
			"0100100" when 5,
			"0100000" when 6,
			"0001101" when 7,
			"1111110" when others;
	
end arqseg;