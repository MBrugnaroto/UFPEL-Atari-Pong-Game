# Jogo Pong em VHDL
Projeto desenvolvido na cadeira de Sistemas Digitais Avançados. Como proposto, foi desenvolvido o clássico
jogo da Atari, o Pong. 

O projeto foi realizado na linguagem de descrição de hardware VHDL, através do software Quartus. A sua prototipação foi feita em um dispositivo programával do tipo FPGA da Intel Corporation (device EP2C35F672C6), utilizando a biblioteca da família Cyclone II. 

## Métodologia do jogo
O jogo é composto de 2 jogadores, onde cada jogador movimenta sua
paleta no sentido vertical. O objetivo é rebater a bola com a paleta, de modo que o segundo
jogador não consiga rebate-la de volta. Caso o jogador não consiga rebater, seu adversário recebe 1 ponto.
Jogador que atingir 7 pontos, ganha o jogo.

## Funcionamento
Para que o jogo seja executado, primeiramente deve ser feito a pinagem no FPGA das seguintes funções:
* Start
* Reset
* Visualização dos pontos:
  * Essa visualização foi feita no display de 7-segmentos disponível no FPGA.
 
 **OBS:** no diretório *project-componets* possui mais uma breve explicação dos componentes para melhor entendimento
 das pinagens e do seu funcionamento. Além do mais, na raiz do projeto, possui um relátorio final do projeto.

## Controles:
Os controles de *start* e *reset* são definidos pelo usuário.

**Player 1:** seta para cima e seta para baixo.<br>
**Player 2:** teclar W para subir e S para descer. 
