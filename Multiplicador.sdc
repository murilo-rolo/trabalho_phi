# Multiplicador 4x4 - restricoes de tempo
# Clock real do circuito: logisimClockTree0(4) (registradores e FSM)
# Frequencia de projeto: 50 MHz (periodo 20 ns)

create_clock -name clk_main -period 20.000 [get_ports {logisimClockTree0[4]}]

# Entradas assincronas em relacao ao clock: nao ha caminho sincrono
# de tempo critico para elas (operandos estaveis antes do pulso de reset;
# inicio mantido alto durante toda a operacao)
set_false_path -from [get_ports {entA[*]}]
set_false_path -from [get_ports {entB[*]}]
set_false_path -from [get_ports {inicio}]
set_false_path -from [get_ports {logisimInputBubbles[0]}]

# Saidas (mult) sao estaveis apos o fim da operacao: sem requisito de
# tempo de saida relativamente ao clock
set_false_path -to [get_ports {mult[*]}]
