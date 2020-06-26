library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Palet is
	port(
		clk,reset		: in STD_LOGIC;
		HPixel, VPixel : in integer range 0 to 1280;
		VStart, VEnd	: in integer range 0 to 1280;
		HStart, HEnd   : in integer range 0 to 1280;
		printPalet		: out std_logic
	);
end Palet; 

architecture Hardware of Palet is 
begin

process (clk, reset)
begin
	if reset = '1' then
		printPalet <= '0';
		
	elsif clk'event and clk = '1' then
		if (((VPixel >= VStart) and (VPixel <= VEnd)) and ((HPixel >= HStart) and (HPixel <= HEnd))) then
			printPalet <= '1';
		else
			printPalet <= '0';
		end if;
	end if;
	
end process;

end Hardware;