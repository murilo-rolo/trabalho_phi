--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : bloco_op                                                    ==
--== Descricao  : Datapath do multiplicador por soma repetida.                 ==
--==   Registrador A (4 bits): multiplicando, carregado em inicio              ==
--==   Registrador B (4 bits): multiplicador, conta decrescente ate 0          ==
--==   Registrador P (8 bits): acumulador do produto                           ==
--==   op_sel=0: P <- A + P (soma); op_sel=1: B <- B - 1 (contagem)           ==
--==============================================================================

USE work.all;

ARCHITECTURE platformIndependent OF bloco_op IS

   -----------------------------------------------------------------------------
   -- Here all used components are defined                                    --
   -----------------------------------------------------------------------------

      COMPONENT Multiplexer_bus_2
         GENERIC ( nrOfBits : INTEGER );
         PORT ( enable  : IN  std_logic;
                muxIn_0 : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                muxIn_1 : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                sel     : IN  std_logic;
                muxOut  : OUT std_logic_vector( (nrOfBits - 1) DOWNTO 0 ) );
      END COMPONENT;

      COMPONENT Demultiplexer_bus_2
         GENERIC ( nrOfBits : INTEGER );
         PORT ( demuxIn    : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                enable     : IN  std_logic;
                sel        : IN  std_logic;
                demuxOut_0 : OUT std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                demuxOut_1 : OUT std_logic_vector( (nrOfBits - 1) DOWNTO 0 ) );
      END COMPONENT;

      COMPONENT Comparator
         GENERIC ( nrOfBits       : INTEGER;
                   twosComplement : INTEGER );
         PORT ( dataA         : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                dataB         : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                aEqualsB      : OUT std_logic;
                aGreaterThanB : OUT std_logic;
                aLessThanB    : OUT std_logic );
      END COMPONENT;

      COMPONENT Adder
         GENERIC ( extendedBits : INTEGER;
                   nrOfBits     : INTEGER );
         PORT ( carryIn  : IN  std_logic;
                dataA    : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                dataB    : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                carryOut : OUT std_logic;
                result   : OUT std_logic_vector( (nrOfBits - 1) DOWNTO 0 ) );
      END COMPONENT;

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

--------------------------------------------------------------------------------
-- All used signals are defined here                                          --
--------------------------------------------------------------------------------
   -- Registradores
   SIGNAL s_reg_a     : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_reg_b     : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_reg_p     : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_reg_b_d   : std_logic_vector( 3 DOWNTO 0 );

   -- Caminho do somador (8 bits)
   SIGNAL s_reg_a_ext : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_reg_b_ext : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_add_data_a : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_add_data_b : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_sum        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_sum_to_b   : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_sum_to_p   : std_logic_vector( 7 DOWNTO 0 );

   -- Controle
   SIGNAL s_b_hab    : std_logic;
   SIGNAL s_op_sel   : std_logic;
   SIGNAL s_n_b_hab  : std_logic;
   SIGNAL s_n_op_sel : std_logic;
   SIGNAL s_a_zero   : std_logic;
   SIGNAL s_b_zero   : std_logic;
   SIGNAL s_ab_0     : std_logic;
   SIGNAL s_en_b     : std_logic;
   SIGNAL s_en_p     : std_logic;

   -- Constantes
   SIGNAL c_zeros_4 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL c_ones_8  : std_logic_vector( 7 DOWNTO 0 );

BEGIN

   --------------------------------------------------------------------------------
   -- Here all output connections are defined                                    --
   --------------------------------------------------------------------------------
   ab_0      <= s_ab_0;
   resultado <= s_reg_p;

   --------------------------------------------------------------------------------
   -- Constants and inline logic                                                 --
   --------------------------------------------------------------------------------
   c_zeros_4 <= "0000";
   c_ones_8  <= X"FF";

   s_b_hab    <= b_hab;
   s_op_sel   <= op_sel;
   s_n_b_hab  <= NOT s_b_hab;
   s_n_op_sel <= NOT s_op_sel;

   -- ab_0 = (A = 0) or (B = 0): produto zerado, FSM entra em repouso
   s_ab_0     <= s_a_zero OR s_b_zero;

   -- Enables dos registradores (derivados da FSM)
   s_en_b     <= inicio AND s_b_hab;
   s_en_p     <= inicio AND s_n_b_hab;

   -- Extensao de A e B (4 bits, sem sinal) para o somador de 8 bits
   s_reg_a_ext <= std_logic_vector(resize(unsigned(s_reg_a), 8));
   s_reg_b_ext <= std_logic_vector(resize(unsigned(s_reg_b), 8));

   --------------------------------------------------------------------------------
   -- Here all normal components are defined                                     --
   --------------------------------------------------------------------------------

   -- Selecao dos operandos do somador:
   --   op_sel=0 (soma): A + P ;  op_sel=1 (contagem): B + 0xFF (= B - 1)
   MUX_ADD_A : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_reg_a_ext,
                 muxIn_1 => s_reg_b_ext,
                 muxOut  => s_add_data_a,
                 sel     => s_op_sel );

   MUX_ADD_B : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_reg_p,
                 muxIn_1 => c_ones_8,
                 muxOut  => s_add_data_b,
                 sel     => s_op_sel );

   -- op_sel=0: soma vai para P; op_sel=1: soma (B - 1) vai para B
   DEMUX_SUM : Demultiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( demuxIn    => s_sum,
                 demuxOut_0 => s_sum_to_b,
                 demuxOut_1 => s_sum_to_p,
                 enable     => '1',
                 sel        => s_n_op_sel );

   -- Fonte de D do registrador B:
   --   op_sel=0: carrega o multiplicador da entrada; op_sel=1: carrega B - 1
   MUX_B_D : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 4 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => entB,
                 muxIn_1 => s_sum_to_b(3 DOWNTO 0),
                 muxOut  => s_reg_b_d,
                 sel     => s_op_sel );

   CMP_A_ZERO : Comparator
      GENERIC MAP ( nrOfBits       => 4,
                    twosComplement => 0 )
      PORT MAP ( aEqualsB      => s_a_zero,
                 aGreaterThanB => OPEN,
                 aLessThanB    => OPEN,
                 dataA         => s_reg_a,
                 dataB         => c_zeros_4 );

   CMP_B_ZERO : Comparator
      GENERIC MAP ( nrOfBits       => 4,
                    twosComplement => 0 )
      PORT MAP ( aEqualsB      => s_b_zero,
                 aGreaterThanB => OPEN,
                 aLessThanB    => OPEN,
                 dataA         => s_reg_b,
                 dataB         => c_zeros_4 );

   ADDER_1 : Adder
      GENERIC MAP ( extendedBits => 9,
                    nrOfBits     => 8 )
      PORT MAP ( carryIn  => '0',
                 carryOut => OPEN,
                 dataA    => s_add_data_a,
                 dataB    => s_add_data_b,
                 result   => s_sum );

   -- Multiplicando (4 bits): carregado enquanto a FSM indica inicio da conta
   REG_A : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 4 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => inicio,
                 d           => entA,
                 q           => s_reg_a,
                 reset       => reset,
                 tick        => '1' );

   -- Multiplicador (4 bits): conta decrescente ate zero
   REG_B : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 4 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_en_b,
                 d           => s_reg_b_d,
                 q           => s_reg_b,
                 reset       => reset,
                 tick        => '1' );

   -- Acumulador (8 bits): recebe A + P a cada passo de soma
   REG_P : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 8 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_en_p,
                 d           => s_sum_to_p,
                 q           => s_reg_p,
                 reset       => reset,
                 tick        => '1' );

END platformIndependent;
