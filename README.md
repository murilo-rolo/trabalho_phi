<div align="center">

# Multiplicador Sequencial 4×4 bits

**Trabalho 2 — projeto `trabalho_phi`**

Circuito digital sequencial que calcula `mult[7:0] = entA × entB`, com arquitetura
clássica **FSM + datapath**, modelado no Logisim e exportado para **VHDL**,
sintetizado no **Quartus Prime** para a família **Cyclone V**.

![VHDL](https://img.shields.io/badge/VHDL-IEEE%201076-543978?style=flat-square)
![Quartus](https://img.shields.io/badge/Quartus%20Prime-25.1%20Lite-1F7ABF?style=flat-square)
![FPGA](https://img.shields.io/badge/Cyclone%20V-5CSXFC6D6F31C8ES-00A0A0?style=flat-square)

</div>

---

## Sobre o projeto

Este repositório contém um **multiplicador sequencial de 4×4 bits** que produz um
produto de 8 bits. O circuito foi montado no **Logisim** e exportado para VHDL
(os arquivos carregam a marcação `logisim*` gerada automaticamente). O VHDL foi
então compilado no **Quartus Prime 25.1 Standard/Lite** para um dispositivo
**Cyclone V `5CSXFC6D6F31C8ES`**.

O projeto segue a divisão clássica de um sistema digital sequencial:

- **`bloco_ctr` (BC)** — unidade de **controle** (máquina de estados finitos).
- **`bloco_op` (BO)** — **datapath** (registradores, somador, multiplexadores).

## Arquitetura

```text
                        +-----------------------------------------------+
        entA[3:0] ----->|                                               |
        entB[3:0] ----->|                  bloco_op (BO)               |
         inicio ------->|  registrador A[3:0]   registrador B[3:0]      |
          reset ------->|  registrador P[7:0]   somador 8 bits          |
                        |  mux / demux          comparadores (A=0, B=0)  |
                        +--------------------------+--------------------+
                              ^        |  b_hab      | op_sel  mult[7:0]
                              |        v             v         |
                    +---------+--------------------------+      |
                    |            bloco_ctr (BC)          |      |
                    |  FSM (log_comb) + registrador de   |      |
                    |  estado (3 bits)                   |      |
                    +------------------------------------+      |
                                     ^  ab_0 (A=0 ou B=0)       |
                                     +--------------------------+
```

### Blocos

| Módulo      | Papel        | Conteúdo                                                                                             |
| ----------- | ------------ | ---------------------------------------------------------------------------------------------------- |
| `main`      | Topo         | Instancia `bloco_ctr` e `bloco_op`, interliga `ab_0`, `b_hab`, `inicio_out`, `op_sel` e o clock.      |
| `bloco_ctr` | Controle     | Registrador de estado de 3 bits + `log_comb` (FSM combinacional) que gera `b_hab`, `inicio_out`, `op_sel`. |
| `bloco_op`  | Datapath     | Registradores A (4 bits), B (4 bits) e P (8 bits), somador de 8 bits, mux/demux e comparadores.       |

### Interface (`entity main`)

| Porta                     | Dir. | Largura | Descrição                                              |
| ------------------------- | :--: | :-----: | ------------------------------------------------------ |
| `entA[3:0]`               | IN   | 4       | Multiplicando.                                         |
| `entB[3:0]`               | IN   | 4       | Multiplicador.                                         |
| `inicio`                  | IN   | 1       | Sinal de partida da multiplicação.                     |
| `logisimInputBubbles[0]`  | IN   | 1       | Reset do sistema (botão).                              |
| `logisimClockTree0[4:0]`  | IN   | 5       | Árvore de clock gerada automaticamente pelo Logisim.   |
| `mult[7:0]`               | OUT  | 8       | Produto `entA × entB`.                                 |

### Máquina de estados

O registrador de estado armazena `{ab_0, b_hab, inicio_out}`. A lógica
combinacional `log_comb` calcula o próximo estado e os sinais de controle:

```text
inicio_out' = ¬ab_0 · (inicio + inicio_out)
b_hab'      = inicio·¬inicio_out + inicio_out·¬b_hab·¬ab_0
op_sel      = inicio_out · ¬b_hab · ¬ab_0
```

- `ab_0` é gerado no datapath: é `1` quando **A = 0** ou **B = 0**, sinalizando o fim.
- `inicio_out` indica que a multiplicação está em andamento.
- `b_hab` habilita a carga/atualização do registrador B.
- `op_sel` seleciona a operação do somador/multiplexadores no datapath.

### Funcionamento

1. Em repouso, aguarda `inicio`.
2. Com `inicio = 1`, os operandos são carregados em A e B.
3. O datapath acumula o produto em **P (8 bits)** e atualiza o multiplicador,
   usando o **somador de 8 bits** (com extensão de sinal dos operandos de 4 bits)
   e os comparadores para detectar o término.
4. Quando **A = 0** ou **B = 0**, `ab_0 = 1` encerra a FSM e o resultado fica
   disponível em `mult`.

## Estrutura do repositório

```text
.
├── Trabalho2.qpf                       # Projeto Quartus (revisão "Multiplicador")
├── Multiplicador.qsf                   # Atribuições do projeto (device, arquivos, pinos)
├── golden_top.v                        # Exemplo de pinout/IO standard (template Altera)
├── filelist.txt                        # Lista de arquivos do fluxo
├── main/
│   ├── vhdl/
│   │   ├── circuit/                    # main, bloco_ctr, bloco_op, log_comb  (o design)
│   │   ├── gates/                      # AND, AND_3, OR
│   │   ├── arith/                      # Adder, Comparator
│   │   ├── plexers/                    # Multiplexer_bus_2, Demultiplexer_bus_2
│   │   ├── memory/                     # REGISTER_FLIP_FLOP
│   │   ├── base/                       # Geradores de clock do Logisim
│   │   └── toplevel/                   # logisimTopLevelShell
│   └── scripts/
│       └── AlteraDownload.tcl          # Script de download/programação
├── simulation/                         # Artefatos de simulação (gerados)
├── output_files/                       # Saída do build (.sof, relatórios) — gerado
└── db/, incremental_db/                # Bancos intermediários do Quartus — gerado
```

## Como compilar e programar

**Pré-requisitos:** Quartus Prime (Lite) 25.1 ou compatível, com suporte à
família Cyclone V.

1. Abra o projeto `Trabalho2.qpf` (revisão **Multiplicador**) no Quartus Prime.
2. Execute **Processing → Start Compilation**.
3. O bitstream é gerado em `output_files/Multiplicador.sof`.
4. Com um **USB-Blaster** conectado, abra **Programmer** e programe o `.sof`.

## Resultados de síntese

Resumo reportado pelo Fitter (`output_files/Multiplicador.fit.summary`):

| Recurso                    | Uso        | Disponível  | Uso % |
| -------------------------- | ---------- | ----------- | :---: |
| ALMs (lógica)              | 13         | 41.910      | < 1 % |
| Registradores              | 19         | —           | —     |
| Pinos                      | 23         | 499         | 5 %   |
| Blocos de memória          | 0          | 5.662.720   | 0 %   |
| Blocos DSP                 | 0          | 112         | 0 %   |
| PLLs                       | 0          | 15          | 0 %   |

- **Fitter:** Successful
- **Analysis & Synthesis:** Successful
- **Família:** Cyclone V
- **Dispositivo:** `5CSXFC6D6F31C8ES`

## Limitações e próximos passos

- **Pinos não atribuídos:** nenhuma porta do topo (`entA`, `entB`, `inicio`,
  `mult`, `reset`) possui `set_location_assignment`. O `.qsf` contém apenas o
  pinout do template `golden_top.v`, que **não** faz parte deste design. É preciso
  mapear as portas para chaves (`SW`) e LEDs da placa.
- **Sem restrições de clock (`.sdc`):** o Timing Analyzer reporta *slack*
  negativo no domínio gerado pelo Logisim (`logisimClockTree0[4]`). Recomenda-se
  criar um arquivo `.sdc` com `create_clock` adequado.
- **Código gerado automaticamente:** os nomes `s_logisim*` são produzidos pelo
  exportador do Logisim; convém revisar/reimplementar para maior legibilidade.
- **Verificação funcional:** incluir uma *testbench* para validar a FSM e o
  datapath em simulação (ModelSim/Questa ou GHDL).

## Tecnologias

- **Logisim(-Evolution)** — captura esquemática e exportação para VHDL
- **VHDL** (IEEE 1076) — descrição do hardware
- **Quartus Prime 25.1 Lite** — síntese, *fitting* e *place & route*
- **Cyclone V** `5CSXFC6D6F31C8ES` — FPGA alvo

## Créditos

Projeto acadêmico. O arquivo `golden_top.v` é de autoria da Altera/Intel e é
distribuído como exemplo de pinout. O VHDL em `main/` foi gerado pelo Logisim
a partir do esquemático.
