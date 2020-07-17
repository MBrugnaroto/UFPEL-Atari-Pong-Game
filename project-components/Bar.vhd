library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Bar is
	port(
		clk,reset		: in STD_LOGIC;
		HPixel, VPixel : in integer range 0 to 1280;
		VStart, VEnd	: in integer range 0 to 1280;
		HStart, HEnd   : in integer range 0 to 1280;
		printBar 		: out std_logic
	);
end Bar; 

architecture Hardware of Bar is 
begin

process (clk, reset)
begin
	if reset = '1' then
		printBar <= '0';
		
	elsif clk'event and clk = '1' then
		if (((VPixel >= VStart) and (VPixel <= VEnd)) and ((HPixel >= HStart) and (HPixel <= HEnd))) then
			printBar <= '1';
		else
			printBar <= '0';
		end if;
	end if;
	
end process;

end Hardware;