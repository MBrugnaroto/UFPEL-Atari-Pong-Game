library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;



entity PlotVGA is
port (
	clk_27										: in std_logic;
   reset 										: in std_logic;
	Start 										: in std_logic;
	Palet1_cima, Palet1_baixo				: in std_logic;
	Palet2_cima, Palet2_baixo				: in std_logic;
	clock_ps2, ps2_clk, ps2_data			: in std_logic;
	teste 			 							: out std_logic;
	VGA_CLK, -- Dot clock to DAC
	VGA_HS, -- Active-Low Horizontal Sync
	VGA_VS, -- Active-Low Vertical Sync
	VGA_BLANK, -- Active-Low DAC blanking control
	VGA_SYNC 				: out std_logic; -- Active-Low DAC Sync on Green
	VGA_R, VGA_G, VGA_B  : out std_logic_vector(9 downto 0);
	seg1                 : out std_logic_vector(6 downto 0);
	seg2                 : out std_logic_vector(6 downto 0);
	seg3                 : out std_logic_vector(6 downto 0)
	);
	
end PlotVGA;

architecture Hardware of PlotVGA is

-------------------------
-- Parametros de video --
-------------------------
constant HTOTAL 			: integer := 1688;	
constant HSYNC 			: integer := 112;	
constant HBACK_PORCH		: integer := 248;	
constant HACTIVE 			: integer := 1280;	
constant HFRONT_PORCH 	: integer := 48;	
constant HEND 				: integer := 1280;	

constant VTOTAL 			: integer := 1066;	
constant VSYNC 			: integer := 3;		
constant VBACK_PORCH		: integer := 38;	
constant VACTIVE			: integer := 1024;	
constant VFRONT_PORCH 	: integer := 1;		
constant VEND 				: integer := 1024;

------------------------------------
-- Parametros da paleta (player1) --
------------------------------------
signal Palet1_HSTART	   : integer range 1 to 1280    := 1;
signal Palet1_HEND		: integer range 1 to 1280    := 5;
signal Palet1_VSTART 	: integer range 1 to 1024    := 426;
signal Palet1_VEND 	   : integer range 1 to 1024    := 586;

------------------------------------
-- Parametros da paleta (player2) --
------------------------------------
signal Palet2_HSTART	   : integer range 1 to 1280    := 1267;
signal Palet2_HEND		: integer range 1 to 1280    := 1271;
signal Palet2_VSTART 	: integer range 1 to 1024    := 426;
signal Palet2_VEND 	   : integer range 1 to 1024    := 586;

------------------------------------
-- Parametros da Barra (Superior) --
------------------------------------
signal Bar1_HSTART   : integer range 1 to 1280    := 1;
signal Bar1_HEND		: integer range 1 to 1280    := 1271;
signal Bar1_VSTART 	: integer range 1 to 1024    := 1;
signal Bar1_VEND 	   : integer range 1 to 1024    := 8;

------------------------------------
-- Parametros da Barra (Inferior) --
------------------------------------
signal Bar2_HSTART	: integer range 1 to 1280    := 1;
signal Bar2_HEND		: integer range 1 to 1280    := 1271;
signal Bar2_VSTART 	: integer range 1 to 1024    := 1011;
signal Bar2_VEND 	   : integer range 1 to 1024    := 1018;

------------------------
-- Parametros da Bola --
------------------------
signal Ball_HSTART	: integer range 1 to 1280    := 635;
signal Ball_HEND		: integer range 1 to 1280    := 645;
signal Ball_VSTART 	: integer range 1 to 1024    := 500;
signal Ball_VEND 	   : integer range 1 to 1024    := 510;

signal vga_hblank, vga_hsync, vga_vblank, vga_vsync : std_logic;

component ps2_keyboard -- Utilizado para dar movimento para a paleta 
  GENERIC(
    clk_freq              : INTEGER := 50_000_000; 
    debounce_counter_size : INTEGER := 8);         
  PORT(
    clk          : IN  STD_LOGIC;                     --Clock do sistema
    ps2_clk      : IN  STD_LOGIC;                     --Sinal de clock vindo do PS/2 teclado 
    ps2_data     : IN  STD_LOGIC;                     --Sinal de dado vindo do PS/2 teclado
	 ps2_code_new : OUT STD_LOGIC;	
	 ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --Código recebido do PS/2
end component;

component altclk
		PORT (
			inclk0		: IN STD_LOGIC  := '0';
			c0				: OUT STD_LOGIC 
);
end component;

component seg7
port(

	entrada: integer range 0 to 8;
	saida1: out std_logic_vector (6 downto 0)
	);
end component;

component Palet
	port(
		clk,reset      : in STD_LOGIC;
		HPixel, VPixel : in integer range 0 to 1280;  
		VStart, VEnd	: in integer range 0 to 1280;
		HStart, HEnd	: in integer range 0 to 1280;
		printPalet		: out STD_LOGIC
	);
end component;

component bar
	port(
		clk,reset      : in STD_LOGIC;
		HPixel, VPixel : in integer range 0 to 1280;
		VStart, VEnd	: in integer range 0 to 1280;
		HStart, HEnd	: in integer range 0 to 1280;
		printBar 		: out STD_LOGIC
	);
end component;

component ball
	port(
		clk,reset      : in STD_LOGIC;
		HPixel, VPixel : in integer range 0 to 1280;
		VStart, VEnd	: in integer range 0 to 1280;
		HStart, HEnd	: in integer range 0 to 1280;
		printBall 		: out STD_LOGIC
	);
end component;

component Div_Ball
		 port (
				 CLK: in STD_LOGIC;
				 COUT: out STD_LOGIC;
				 clk_ball: out STD_LOGIC
			 );
end component;

component Div_Palet
		 port (
				 CLK: in STD_LOGIC;
				 COUT: out STD_LOGIC;
				 clk_Palet: out STD_LOGIC
			 );
end component;  

component div_reg		
	port (
	   CLK: in STD_LOGIC;
	   COUT: out STD_LOGIC;
		clk_reg: out STD_LOGIC
		);
end component;		
		
-- Horizontal position (0-1667)
	signal HCount : integer range 0 to 1688 := 0;
-- Vertical position (0-1065)
	signal VCount : integer range 0 to 1066 := 0;
	
	signal Hpixel, Vpixel : integer range 0 to 1280 :=0;
	signal countclk 		 : std_logic;
	signal movclk  		 : std_logic;
	signal clk_ball		 : std_logic;
	signal clk_palet1		 : std_logic;
	signal clk_palet2		 : std_logic;
	signal clk_reg        : std_logic;
	signal bate 			 : integer range 0 to 9    :=0;
	signal Paleta1			 : std_logic;
	signal Paleta2			 : std_logic;
	signal Barra1			 : std_logic;
	signal Barra2 			 : std_logic;
	signal Bola 			 : std_logic;
	signal Movimento		 : std_logic;
	signal ps2_code	    : std_logic_vector (7 downto 0);
	signal ps2_code2	    : std_logic_vector (7 downto 0);
	signal ps2_code_reg	 : std_logic_vector (7 downto 0);
	signal ps2	          : std_logic_vector (7 downto 0);
	signal contador 		 : integer range 0 to 100000000 :=0;
	signal ps2_code_new	 : std_logic;
	signal ps2_code_new1	 : std_logic;
	signal count_gol1	    : integer range 0 to 7 := 0;
	signal count_gol2	    : integer range 0 to 7 := 0;
	signal lado 			 : std_logic;
begin

KEYBOARD1 	: ps2_keyboard			port map (countclk, ps2_clk, ps2_data, ps2_code_new, ps2_code);
KEYBOARD2 	: ps2_keyboard			port map (countclk, ps2_clk, ps2_data, ps2_code_new1, ps2_code2);
MOV_BALL1 	: div_ball 				port map (countclk, movclk, clk_ball);
MOV_PALET1	: div_palet 			port map (countclk, movclk, clk_palet1);
MOV_PALET2	: div_palet 			port map (countclk, movclk, clk_palet2);
VIDEO    	: altclk 				port map (clk_27,countclk);
PALET1   	: palet 					port map (countclk, reset, Hpixel, Vpixel, palet1_VSTART, palet1_VEND, palet1_HSTART, palet1_HEND, Paleta1);
PALET2   	: palet 					port map (countclk, reset, Hpixel, Vpixel, palet2_VSTART, palet2_VEND, palet2_HSTART, palet2_HEND, Paleta2);
BAR1     	: bar 					port map (countclk, reset, Hpixel, Vpixel, bar1_VSTART, bar1_VEND, bar1_HSTART, bar1_HEND, Barra1);
BAR2     	: bar 					port map (countclk, reset, Hpixel, Vpixel, bar2_VSTART, bar2_VEND, bar2_HSTART, bar2_HEND, Barra2);
BALL1    	: ball 					port map (countclk, reset, Hpixel, Vpixel, ball_VSTART, ball_VEND, ball_HSTART, ball_HEND, Bola);
DIVREG      : div_reg            port map (countclk, movclk, clk_reg);
GOL1        : seg7               port map (count_gol1, seg1);
GOL2        : seg7               port map (count_gol2, seg2);
DIV         : seg7               port map (8, seg3);

------------------------
-- Movimento da Bola --
------------------------
movimenta_bola: process(clk_ball, palet1_VSTART, palet1_VEND, palet2_VSTART, palet2_VEND)
begin
		
		if (clk_ball'event and clk_ball='1' and Start = '1') then
				if (count_gol1 = 7 or count_gol2 = 7) then
					count_gol1 <= 0;
					count_gol2 <= 0;
				end if;
				
				if (bate = 0) then
					ball_HSTART<= ball_HSTART-1;
					ball_HEND  <= ball_HEND-1;
					
					if ((ball_HSTART = palet1_HEND) and ((ball_VSTART >= palet1_VSTART+40) and (ball_VSTART <= palet1_VEND-40))) then
						bate <= 1;
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART >= palet1_VSTART) and (ball_VSTART <= palet1_VSTART+40))) then
						bate <= 2;
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART <= palet1_VEND) and (ball_VSTART >= palet1_VEND-40))) then
						bate <= 3;
					elsif ((ball_HSTART = palet1_HSTART) and ((ball_VSTART > palet1_VEND) or (ball_VSTART < palet1_VEND))) then
						bate <= 6;
						count_gol1 <= count_gol1 + 1;
					end if;

				elsif (bate = 1) then
					ball_HSTART<= ball_HSTART+1;
					ball_HEND  <= ball_HEND+1;
					
					if ((ball_HEND = palet2_HSTART) and ((ball_VSTART >= palet2_VSTART+40) and (ball_VSTART <= palet2_VEND-40))) then
						bate <= 0;
					elsif ((ball_HEND = palet2_HEND) and ((ball_VSTART >= palet2_VSTART) and (ball_VSTART <= palet2_VSTART+40))) then
						bate <= 4;
					elsif ((ball_HEND = palet2_HEND) and ((ball_VSTART <= palet2_VEND) and (ball_VSTART >= palet2_VEND-40))) then
						bate <= 5;
					elsif ((ball_HSTART = palet2_HEND) and ((ball_VSTART > palet2_VEND) or (ball_VSTART < palet2_VEND))) then
						bate <= 6;
						count_gol2 <= count_gol2 + 1;
					end if;
				
				elsif (bate = 2) then
					ball_HSTART<= ball_HSTART+1;
					ball_HEND  <= ball_HEND+1;
					ball_VSTART<= ball_VSTART-1;
					baLL_VEND  <= balL_VEND-1;
					
					if (bar1_VEND = ball_VSTART) then
						bate <= 3;
					
					elsif ((ball_HEND = palet2_HSTART) and ((ball_VSTART >= palet2_VSTART+40) and (ball_VSTART <= palet2_VEND-40))) then
						bate <= 0;
					elsif ((ball_HEND = palet2_HEND) and ((ball_VSTART >= palet2_VSTART) and (ball_VSTART <= palet2_VSTART+40))) then
						bate <= 4;
					elsif ((ball_HEND = palet2_HEND) and ((ball_VSTART <= palet2_VEND) and (ball_VSTART >= palet2_VEND-40))) then
						bate <= 5;
					elsif ((ball_HSTART = palet2_HEND) and ((ball_VSTART > palet2_VEND) or (ball_VSTART < palet2_VEND))) then
						bate <= 6;
						count_gol2 <= count_gol2 + 1;
					end if;

				elsif (bate = 3) then
					ball_HSTART<= ball_HSTART+1;
					ball_HEND  <= ball_HEND+1;
					ball_VSTART<= ball_VSTART+1;
					baLL_VEND  <= balL_VEND+1;
					
					if (bar2_VSTART = ball_VEND) then
						bate <= 2;
					
					elsif ((ball_HEND = palet2_HSTART) and ((ball_VSTART >= palet2_VSTART+40) and (ball_VSTART <= palet2_VEND-40))) then
						bate <= 0;
					elsif ((ball_HEND = palet2_HEND) and ((ball_VSTART >= palet2_VSTART) and (ball_VSTART <= palet2_VSTART+40))) then
						bate <= 4;
					elsif ((ball_HEND = palet2_HEND) and ((ball_VSTART <= palet2_VEND) and (ball_VSTART >= palet2_VEND-40))) then
						bate <= 5;
					elsif ((ball_HSTART = palet2_HEND) and ((ball_VSTART > palet2_VEND) or (ball_VSTART < palet2_VEND))) then
						bate <= 6;
						count_gol2 <= count_gol2 + 1;
					end if;
				
				elsif (bate = 4) then
					ball_HSTART<= ball_HSTART-1;
					ball_HEND  <= ball_HEND-1;
					ball_VSTART<= ball_VSTART-1;
					baLL_VEND  <= balL_VEND-1;
					
					if (bar1_VEND = ball_VSTART) then
						bate <= 5;
						
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART >= palet1_VSTART+40) and (ball_VSTART <= palet1_VEND-40))) then
						bate <= 1;
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART >= palet1_VSTART) and (ball_VSTART <= palet1_VSTART+40))) then
						bate <= 2;
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART <= palet1_VEND) and (ball_VSTART >= palet1_VEND-40))) then
						bate <= 3;
					elsif ((ball_HSTART = palet1_HSTART) and ((ball_VSTART > palet1_VEND) or (ball_VSTART < palet1_VEND))) then
						bate <= 6;
						count_gol1 <= count_gol1 + 1;
					end if;
					
				elsif (bate = 5) then
					ball_HSTART<= ball_HSTART-1;
					ball_HEND  <= ball_HEND-1;
					ball_VSTART<= ball_VSTART+1;
					baLL_VEND  <= balL_VEND+1;
					
					if (bar2_VSTART = ball_VEND) then
						bate <= 4;	
					
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART >= palet1_VSTART+40) and (ball_VSTART <= palet1_VEND-40))) then
						bate <= 1;
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART >= palet1_VSTART) and (ball_VSTART <= palet1_VSTART+40))) then
						bate <= 2;
					elsif ((ball_HSTART = palet1_HEND) and ((ball_VSTART <= palet1_VEND) and (ball_VSTART >= palet1_VEND-40))) then
						bate <= 3;
					elsif ((ball_HSTART = palet1_HSTART) and ((ball_VSTART > palet1_VEND) or (ball_VSTART < palet1_VEND))) then
						bate <= 6;
						count_gol1 <= count_gol1 + 1;
					end if;
				
				elsif (bate = 6) then
				   ball_HSTART	<= 635;
					ball_HEND  	<= 645;
					ball_VSTART	<= 500;
					baLL_VEND  	<= 510;
					
					if lado = '0' then
						bate <= 1;
						lado <= '1';
					else
						bate <= 0;
						lado <= '0';
					end if;
				end if;
		end if;
end process;
--------------------------
-- Movimento da Paleta1 --
--------------------------
movimenta_paleta1: process(clk_palet1)

begin
		if (clk_palet1'event and clk_palet1='1') then
				if (ps2_code = "00011011"and ps2_code_new = '0') then
					if not (Palet1_VEND = bar2_VSTART) then 
						Palet1_VSTART <= Palet1_VSTART+1;
						Palet1_VEND   <= Palet1_VEND+1;
					end if;
						
				elsif (ps2_code = "00011101"and ps2_code_new = '0') then
					if not (Palet1_VSTART = bar1_VEND) then 
						Palet1_VSTART <= Palet1_VSTART-1;
						Palet1_VEND   <= Palet1_VEND-1;
							
					end if;
				end if;
		end if;
			
end process;

--------------------------
-- Movimento da Paleta2 --
--------------------------
movimenta_paleta2: process(clk_palet2)
begin
		if (clk_palet2'event and clk_palet2='1') then
				if (ps2_code2 = "01110010" and ps2_code_new1 = '0') then
						if not (Palet2_VEND = bar2_VSTART) then 
							Palet2_VSTART <= Palet2_VSTART+1;
							Palet2_VEND   <= Palet2_VEND+1;
						end if;
				elsif (ps2_code2 = "01110101"and ps2_code_new1 = '0') then
						if not (Palet2_VSTART = bar1_VEND) then 
							Palet2_VSTART <= Palet2_VSTART-1;
							Palet2_VEND   <= Palet2_VEND-1;
						end if;
				end if;
		end if;
end process;
--------------------------------
-- Leitura dos Pixels da tela --
--------------------------------
HCounter: process (countclk, reset)
begin
	if reset = '1' then
		Hcount <= 0;
		VCount <= 0;
		vga_hsync <= '1';
		vga_vsync <= '1';
	elsif countclk'event and countclk = '1' then
		if Hcount < HTOTAL-1 then
			Hcount <= Hcount+1;
		ELSE
			Hcount <= 0;
			if VCount < Vtotal-1 then
				VCount <= VCount+1;
			else
				VCount <= 0;
			end if;
		end if;
		
		if (Hcount >= HSYNC + HBACK_PORCH) then
			Hpixel<=Hpixel+1;
		else
			Hpixel<=0;
		end if;
		
		if (VCount >= VSYNC + VBACK_PORCH) then
			VPixel <= VCount-(VSYNC+VBACK_PORCH);
		else
			Vpixel<=0;
		end if;
		
		if Hcount = HTOTAL - 1 then
			vga_hsync <= '1';
		elsif Hcount = HSYNC - 1 then
			vga_hsync <= '0';
		end if;
		
		if VCount = VTOTAL - 1 then
			vga_vsync <= '1';
		elsif VCount = VSYNC - 1 then
			vga_vsync <= '0';
		end if;
	end if;
end process;
------------------------------------------
-- Pintura do Pixels na tela dos objetos--
------------------------------------------
VideoOut: process (countclk, reset)
begin
	if reset = '1' then
		VGA_R <= "1111111111";
		VGA_G <= "1111111111";
		VGA_B <= "1111111111";
	elsif countclk'event and countclk = '1' then
		
		if Paleta1 = '1' then
			VGA_R <= "1111111111";
			VGA_G <= "1111111111";
			VGA_B <= "1111111111";
		
			elsif Paleta2 = '1' then
				VGA_R <= "1111111111";
				VGA_G <= "1111111111";
				VGA_B <= "1111111111";
			
			elsif Barra1 = '1' then
				VGA_R <= "1111111111";
				VGA_G <= "1111111111";
				VGA_B <= "1111111111";
			
			elsif Barra2 = '1' then
				VGA_R <= "1111111111";
				VGA_G <= "1111111111";
				VGA_B <= "1111111111";
				
			elsif Bola = '1' then
				VGA_R <= "1111111111";
				VGA_G <= "1111111111";
				VGA_B <= "1111111111";

			else
				VGA_R <= "0000000000";
				VGA_G <= "0000000000";
				VGA_B <= "0000000000";
		end if;
	end if;
end process VideoOut;

------------------------------------------
-- Registrador--
------------------------------------------

--process (clk_reg)
--begin
--	
--	if (ps2_code_reg = ps2_code) then
--		
--		if (contador = 100000) then
--			
--			mux_out <= '1';
--			contador <= 0;
--		else 
--			mux_out <= '0';
--			contador <= contador + 1;
--		end if;
--	else 
--		
--	end if;		
--end process;
--
--with mux_out select ps2_code <=
--
--	ps2_code when '0',
--	teste when '1',
--	"00000000" when others;

VGA_CLK <= countclk;
VGA_HS <= not vga_hsync;
VGA_VS <= vga_vsync;
VGA_SYNC <= '0';
VGA_BLANK <= not (vga_hsync or vga_vsync);

end Hardware;