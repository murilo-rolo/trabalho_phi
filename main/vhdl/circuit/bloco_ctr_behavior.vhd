--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : bloco_ctr                                                   ==
--== Descricao  :Registrador de estado da FSM. O registrador usa a borda de   ==
--==             descida (invertClock=1) para amostrar ab_0 meio periodo      ==
--==             depois da carga do datapath (borda de subida): assim a FSM   ==
--==             ve o valor de ab_0 ja atualizado com os operandos carregados. ==
--==============================================================================

USE work.all;

ARCHITECTURE platformIndependent OF bloco_ctr IS

   -----------------------------------------------------------------------------
   -- Here all used components are defined                                    --
   -----------------------------------------------------------------------------

      COMPONENT REGISTER_FLIP_FLOP
         GENERIC ( invertClock : INTEGER;
                   nrOfBits    : INTEGER );
         PORT ( clock       : IN  std_logic;
                clockEnable : IN  std_logic;
                d           : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                reset       : IN  std_logic;
                tick        : IN  std_logic;
                q           : OUT std_logic_vector( (nrOfBits - 1) DOWNTO 0 ) );
      END COMPONENT;

      COMPONENT log_comb
         PORT ( ab_0              : IN  std_logic;
                inicio            : IN  std_logic;
                clockTree         : IN  std_logic_vector( 4 DOWNTO 0 );
                s_b_hab           : IN  std_logic;
                s_inicio_out      : IN  std_logic;
                b_hab             : OUT std_logic;
                inicio_out        : OUT std_logic;
                op_sel            : OUT std_logic );
      END COMPONENT;

--------------------------------------------------------------------------------
-- All used signals are defined here                                          --
--------------------------------------------------------------------------------
   -- Estado atual: (2) ab_0 registrado, (1) b_hab, (0) inicio_out
   SIGNAL s_state_q : std_logic_vector( 2 DOWNTO 0 );
   -- Proximo estado / saidas combinacionais da FSM
   SIGNAL s_state_d : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_op_sel  : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- Here all output connections are defined                                    --
   --------------------------------------------------------------------------------
   b_hab      <= s_state_d(1);
   inicio_out <= s_state_d(0);
   op_sel     <= s_op_sel;

   --------------------------------------------------------------------------------
   -- Here all normal components are defined                                     --
   --------------------------------------------------------------------------------
   MEMORY_1 : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 1,
                    nrOfBits    => 3 )
      PORT MAP ( clock       => clockTree(4),
                 clockEnable => '1',
                 d           => s_state_d,
                 q           => s_state_q,
                 reset       => reset,
                 tick        => '1' );


   --------------------------------------------------------------------------------
   -- Here all sub-circuits are defined                                          --
   --------------------------------------------------------------------------------

   FSM : log_comb
      PORT MAP ( ab_0              => s_state_q(2),
                 b_hab             => s_state_d(1),
                 inicio            => inicio,
                 inicio_out        => s_state_d(0),
                 clockTree         => clockTree,
                 op_sel            => s_op_sel,
                 s_b_hab           => s_state_q(1),
                 s_inicio_out      => s_state_q(0) );

   -- Bit de ab_0 registrado: sempre atualizado junto com o resto do estado
   s_state_d(2) <= ab_0;

END platformIndependent;
