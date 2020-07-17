Library IEEE;
use IEEE.std_logic_1164.all;

 entity Div_Reg is
	 port (
		 CLK: in STD_LOGIC;
		 COUT: out STD_LOGIC;
		 clk_reg: out STD_LOGIC
		 );
 end Div_Reg; 

 architecture Hardware of Div_Reg is 

 constant TIMECONST 	     : integer 							:= 	2500;
 signal   TIMECONST2      : integer 							:= 	50000;
 signal   count0			  : integer range 0 to 50000     := 0;
 signal   count1			  : integer range 0 to 10000000  := 0;
 signal   D,clk_reg_temp : STD_LOGIC 						   := '0';

 begin 	
	 process (CLK)
	 begin
	 if (CLK'event and CLK = '1') then
		 count0 <= count0 + 1;
		 count1 <= count1 + 1;
		 -- Clock de saida COUT, que ativa os movimentos
	 	 if (count0 = TIMECONST) then
		 	count0 <= 0;
		 	D      <= not D;
		 end if;
		 -- sempre que contar ate 100000 aumenta o psrand
	 	 if (count1 = TIMECONST2) then
		 	count1 		  <= 0;
			clk_reg_temp <= not clk_reg_temp;
		 end if;
	 end if;

   COUT     <= D;
   clk_reg <= clk_reg_temp;
 end process;

 end Hardware;