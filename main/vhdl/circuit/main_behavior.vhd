--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : main                                                        ==
--== Descricao  : Topo do multiplicador 4x4: interconecta o bloco de controle ==
--==              (BC) e o bloco operacional (BO).                            ==
--==============================================================================

USE work.all;

ARCHITECTURE platformIndependent OF main IS

   -----------------------------------------------------------------------------
   -- Here all used components are defined                                    --
   -----------------------------------------------------------------------------

      COMPONENT bloco_ctr
         PORT ( ab_0              : IN  std_logic;
                clk               : IN  std_logic;
                inicio            : IN  std_logic;
                logisimClockTree0 : IN  std_logic_vector( 4 DOWNTO 0 );
                reset             : IN  std_logic;
                b_hab             : OUT std_logic;
                inicio_out        : OUT std_logic;
                op_sel            : OUT std_logic );
      END COMPONENT;

      COMPONENT bloco_op
         PORT ( b_hab             : IN  std_logic;
                clk               : IN  std_logic;
                entA              : IN  std_logic_vector( 3 DOWNTO 0 );
                entB              : IN  std_logic_vector( 3 DOWNTO 0 );
                inicio            : IN  std_logic;
                logisimClockTree0 : IN  std_logic_vector( 4 DOWNTO 0 );
                op_sel            : IN  std_logic;
                reset             : IN  std_logic;
                ab_0              : OUT std_logic;
                resultado         : OUT std_logic_vector( 7 DOWNTO 0 ) );
      END COMPONENT;

--------------------------------------------------------------------------------
-- All used signals are defined here                                          --
--------------------------------------------------------------------------------
   SIGNAL s_multiplicando : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_multiplicador : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_resultado     : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_reset_btn     : std_logic;
   SIGNAL s_reset_int     : std_logic := '1';
   SIGNAL s_b_hab         : std_logic;
   SIGNAL s_inicio_out    : std_logic;
   SIGNAL s_op_sel        : std_logic;
   SIGNAL s_ab_0          : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- Here all output connections are defined                                    --
   --------------------------------------------------------------------------------
   mult <= s_resultado;

   --------------------------------------------------------------------------------
   -- Here all in-lined components are defined                                   --
   --------------------------------------------------------------------------------

   -- Botao: reset
   s_reset_btn <= logisimInputBubbles(0);

   -- Cruzamento intencional das entradas (a multiplicacao e comutativa, mas a
   -- contagem decrescente do registrador B deve acompanhar o multiplicador):
   --   entA (multiplicador) -> registrador B do BO (conta ate zero)
   --   entB (multiplicando) -> registrador A do BO (somado repetidamente em P)
   s_multiplicador <= entA;
   s_multiplicando <= entB;

   -- Reset sincronizado: assincrono no botao, liberado na borda de descida
   -- do clock. Garante que a carga dos operandos (borda de subida, no
   -- datapath) ocorra antes de a FSM amostrar ab_0 (borda de descida) --
   -- sem isso, o estado registra ab_0=1 com os operandos ainda zerados e
   -- a maquina trava. O valor inicial '1' protege tambem o power-up do FPGA.
   reset_sync : PROCESS(logisimClockTree0(4), s_reset_btn) IS
   BEGIN
      IF (s_reset_btn = '1') THEN
         s_reset_int <= '1';
      ELSIF falling_edge(logisimClockTree0(4)) THEN
         s_reset_int <= '0';
      END IF;
   END PROCESS reset_sync;

   --------------------------------------------------------------------------------
   -- Here all sub-circuits are defined                                          --
   --------------------------------------------------------------------------------

   BC : bloco_ctr
      PORT MAP ( ab_0              => s_ab_0,
                 b_hab             => s_b_hab,
                 clk               => logisimClockTree0(0),
                 inicio            => inicio,
                 inicio_out        => s_inicio_out,
                 logisimClockTree0 => logisimClockTree0,
                 op_sel            => s_op_sel,
                 reset             => s_reset_int );

   -- Reset assincrono do datapath (botao direto): libera A, B e P ja na
   -- primeira borda de subida, ANTES de a FSM amostrar ab_0 na borda de
   -- descida. Se o datapath usasse o mesmo reset sincronizado da FSM, a
   -- carga ficaria para depois da amostragem e a FSM veria ab_0=1 com
   -- operandos zerados (travamento).
   BO : bloco_op
      PORT MAP ( ab_0              => s_ab_0,
                 b_hab             => s_b_hab,
                 clk               => logisimClockTree0(0),
                 entA              => s_multiplicando,
                 entB              => s_multiplicador,
                 inicio            => s_inicio_out,
                 logisimClockTree0 => logisimClockTree0,
                 op_sel            => s_op_sel,
                 reset             => s_reset_btn,
                 resultado         => s_resultado );

END platformIndependent;
