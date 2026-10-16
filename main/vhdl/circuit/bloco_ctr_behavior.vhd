--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : bloco_ctr                                                   ==
--==============================================================================

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
                logisimClockTree0 : IN  std_logic_vector( 4 DOWNTO 0 );
                s_b_hab           : IN  std_logic;
                s_inicio_out      : IN  std_logic;
                b_hab             : OUT std_logic;
                inicio_out        : OUT std_logic;
                op_sel            : OUT std_logic );
      END COMPONENT;

--------------------------------------------------------------------------------
-- All used signals are defined here                                          --
--------------------------------------------------------------------------------
   SIGNAL s_logisimBus0  : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_logisimBus1  : std_logic_vector( 2 DOWNTO 0 );
   SIGNAL s_logisimNet10 : std_logic;
   SIGNAL s_logisimNet11 : std_logic;
   SIGNAL s_logisimNet12 : std_logic;
   SIGNAL s_logisimNet2  : std_logic;
   SIGNAL s_logisimNet3  : std_logic;
   SIGNAL s_logisimNet4  : std_logic;
   SIGNAL s_logisimNet5  : std_logic;
   SIGNAL s_logisimNet6  : std_logic;
   SIGNAL s_logisimNet7  : std_logic;
   SIGNAL s_logisimNet8  : std_logic;
   SIGNAL s_logisimNet9  : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- Here all input connections are defined                                     --
   --------------------------------------------------------------------------------
   s_logisimBus1(2) <= ab_0;
   s_logisimNet3    <= clk;
   s_logisimNet4    <= inicio;
   s_logisimNet5    <= reset;

   --------------------------------------------------------------------------------
   -- Here all output connections are defined                                    --
   --------------------------------------------------------------------------------
   b_hab      <= s_logisimBus1(1);
   inicio_out <= s_logisimBus1(0);
   op_sel     <= s_logisimNet7;

   --------------------------------------------------------------------------------
   -- Here all in-lined components are defined                                   --
   --------------------------------------------------------------------------------

   -- Constante
    s_logisimNet8  <=  '1';


   --------------------------------------------------------------------------------
   -- Here all normal components are defined                                     --
   --------------------------------------------------------------------------------
   MEMORY_1 : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 3 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_logisimNet8,
                 d           => s_logisimBus1(2 DOWNTO 0),
                 q           => s_logisimBus0(2 DOWNTO 0),
                 reset       => s_logisimNet5,
                 tick        => logisimClockTree0(2) );


   --------------------------------------------------------------------------------
   -- Here all sub-circuits are defined                                          --
   --------------------------------------------------------------------------------

   FSM : log_comb
      PORT MAP ( ab_0              => s_logisimBus0(2),
                 b_hab             => s_logisimBus1(1),
                 inicio            => s_logisimNet4,
                 inicio_out        => s_logisimBus1(0),
                 logisimClockTree0 => logisimClockTree0,
                 op_sel            => s_logisimNet7,
                 s_b_hab           => s_logisimBus0(1),
                 s_inicio_out      => s_logisimBus0(0) );

END platformIndependent;
