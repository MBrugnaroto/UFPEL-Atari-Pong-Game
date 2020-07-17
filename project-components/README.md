## Funcionamento das estruturas e dos componentes
### Bola
Na estrutura *movimenta_bolinha* é desenvolvido o movimento da bola. A
bola é formada por 50 pixels, 5 na horizontal e 10 a vertical. A direção da bola é
determinada pelo ponto de contato com uma das paletas ou das barras (superior e inferior).
Ela pode tomar 3 direções diferentes: horizontal, diagonal principal e diagonal secundária.
Direções:
* Para que a bola seja rebatida horizontalmente, ela precisa atingir um dos 80
pixels centrais da paleta.
* Para seguir na diagonal principal, a bola precisa atingir os pixels 160 e 121 das
paletas, player 1 e 2 respectivamente.
* Na diagonal secundária, ela precisa atingir os pixels entre 1 e 39 das paletas, player 1 e 2 respectivamente.

### Paleta
As duas estruturas, *movimenta_paleta1* e *movimenta_paleta2*, realizam o
movimento vertical das paletas. A paleta preenche um total de 160 pixels na vertical e 4 pixels na horizontal. Como
os jogadores controlam as paletas pelo teclado, cada tecla está associada a um código
binário.

**Controle:**
* A primeira paleta (da esquerda) é controlada pelas teclas “w” e “s”. Seus
códigos em binário são, respectivamente: "00011011" e "00011101".
* A segunda paleta (da direita) é controlada pelas setas (para cima e para
baixo) e seus códigos em binário são, respectivamente: "01110010" e
"01110101".
Toda vez que as teclas são pressionada é incrementado 1 pixel na vertical
(dependendo da direção recebida pelo teclado).

### Leitura dos pixels
A  estrutura *HCounter* realiza a leitura dos pixels da tela. Como a leitura é
feita da esquerda para direita e de cima para baixo, temos duas variáveis que realizam a
contagem: a primeira informa qual o pixel na horizontal e a segunda informa qual o pixel na
vertical.

### “Pintura” dos pixels
O process *VideoOut* é responsável por atribuir as cores que cada
componente vai ter (paleta, bolinha e barra). Essas cores possuem um código binário que é
atribuído ao sinal VGA (VGA_R, VGA_G, VGA_B), que transmite as informações para o
monitor.

### Componentes:
1. **Ball.vhd:** essa componente verifica se a bolinha pode ser desenhada na tela. Se isso
for verdade, um sinal é enviado ao process *VideoOut* desenhando-a na tela, no inicio e a cada movimento da bola.
2. **Palet.vhd:** assim como o *Ball.vhd*, essa componente simplesmente verifica se os
palets podem ser desenhados na tela no inicio do jogo ou a cada troca de informação vindas do teclado. 
Se puderem, um sinal será enviado ao process *VideoOut* que é encarregado de colorir e desenhar os palets.
3. **Bar.vhd:** da mesma forma que os componentes anteriores, verifica em quais
posições as barras superiores e inferiores podem ser desenhadas no inicio do jogo.
4. **Div_Ball.vhd** e **Div_Palet.vhd:** essas duas componentes são os divisores de frequência
da bolinha e das paletas, respectivamente. É a esta frequência que esses objetos
respeitam e se movimentam a resposta do teclado (Div_Palet.vhd) ou velocidade da troca de posição (Div_Ball).
5. **Debounce.vhd:** o debounce faz a função de atualizar a entrada do teclado realizando
uma sincronização a partir de um contador.
6. **ps2_keyboard.vhd:** essa componente recebe a tecla que está sendo pressionada no
momento e envia o código em binário para o arquivo principal. Também, verifica
se o teclado está em *idle*, ou seja, se não nenhuma tecla está sendo pressionada no
momento. Se estiver em *idle*, a paleta para de se mexer.
