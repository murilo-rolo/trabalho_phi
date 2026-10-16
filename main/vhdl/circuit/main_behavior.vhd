--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : main                                                        ==
--==============================================================================

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
   SIGNAL s_logisimBus3 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus8 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus9 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimNet0 : std_logic;
   SIGNAL s_logisimNet1 : std_logic;
   SIGNAL s_logisimNet2 : std_logic;
   SIGNAL s_logisimNet4 : std_logic;
   SIGNAL s_logisimNet5 : std_logic;
   SIGNAL s_logisimNet6 : std_logic;
   SIGNAL s_logisimNet7 : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- All clock generator connections are defined here                           --
   --------------------------------------------------------------------------------
   s_logisimNet0 <= logisimClockTree0(0);

   --------------------------------------------------------------------------------
   -- Here all input connections are defined                                     --
   --------------------------------------------------------------------------------
   s_logisimBus3(3 DOWNTO 0) <= entB;
   s_logisimBus9(3 DOWNTO 0) <= entA;
   s_logisimNet2             <= inicio;

   --------------------------------------------------------------------------------
   -- Here all output connections are defined                                    --
   --------------------------------------------------------------------------------
   mult <= s_logisimBus8(7 DOWNTO 0);

   --------------------------------------------------------------------------------
   -- Here all in-lined components are defined                                   --
   --------------------------------------------------------------------------------

   -- Botão: reset
   s_logisimNet1 <= logisimInputBubbles(0);

   --------------------------------------------------------------------------------
   -- Here all sub-circuits are defined                                          --
   --------------------------------------------------------------------------------

   BC : bloco_ctr
      PORT MAP ( ab_0              => s_logisimNet5,
                 b_hab             => s_logisimNet4,
                 clk               => s_logisimNet0,
                 inicio            => s_logisimNet2,
                 inicio_out        => s_logisimNet6,
                 logisimClockTree0 => logisimClockTree0,
                 op_sel            => s_logisimNet7,
                 reset             => s_logisimNet1 );

   BO : bloco_op
      PORT MAP ( ab_0              => s_logisimNet5,
                 b_hab             => s_logisimNet4,
                 clk               => s_logisimNet0,
                 entA              => s_logisimBus3(3 DOWNTO 0),
                 entB              => s_logisimBus9(3 DOWNTO 0),
                 inicio            => s_logisimNet6,
                 logisimClockTree0 => logisimClockTree0,
                 op_sel            => s_logisimNet7,
                 reset             => s_logisimNet1,
                 resultado         => s_logisimBus8(7 DOWNTO 0) );

END platformIndependent;
