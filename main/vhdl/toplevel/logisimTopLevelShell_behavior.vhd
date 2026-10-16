--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : TopLevelShell                                               ==
--==============================================================================

ARCHITECTURE platformIndependent OF logisimTopLevelShell IS 

   -----------------------------------------------------------------------------
   -- Here all used components are defined                                    --
   -----------------------------------------------------------------------------
      COMPONENT synthesizedClockGenerator
         PORT ( FPGAClock        : IN  std_logic;
                SynthesizedClock : OUT std_logic );
      END COMPONENT;

      COMPONENT logisimTickGenerator
         GENERIC ( nrOfBits    : INTEGER;
                   reloadValue : INTEGER );
         PORT ( FPGAClock : IN  std_logic;
                FPGATick  : OUT std_logic );
      END COMPONENT;

      COMPONENT LogisimClockComponent
         GENERIC ( highTicks : INTEGER;
                   lowTicks  : INTEGER;
                   nrOfBits  : INTEGER;
                   phase     : INTEGER );
         PORT ( clockTick   : IN  std_logic;
                globalClock : IN  std_logic;
                clockBus    : OUT std_logic_vector( 4 DOWNTO 0 ) );
      END COMPONENT;

      COMPONENT main
         PORT ( entA                : IN  std_logic_vector( 3 DOWNTO 0 );
                entB                : IN  std_logic_vector( 3 DOWNTO 0 );
                inicio              : IN  std_logic;
                logisimClockTree0   : IN  std_logic_vector( 4 DOWNTO 0 );
                logisimInputBubbles : IN  std_logic_vector( 0 DOWNTO 0 );
                mult                : OUT std_logic_vector( 7 DOWNTO 0 ) );
      END COMPONENT;

--------------------------------------------------------------------------------
-- All used signals are defined here                                          --
--------------------------------------------------------------------------------
   SIGNAL s_entA                : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_entB                : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_fpgaTick            : std_logic;
   SIGNAL s_inicio              : std_logic;
   SIGNAL s_logisimClockTree0   : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL s_logisimInputBubbles : std_logic_vector( 0 DOWNTO 0 );
   SIGNAL s_mult                : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_synthesizedClock    : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- All signal adaptations are performed here                                  --
   --------------------------------------------------------------------------------
   s_entA(0)                <= '0';
   s_entA(1)                <= '0';
   s_entA(2)                <= '0';
   s_entA(3)                <= '0';
   s_entB(0)                <= '0';
   s_entB(1)                <= '0';
   s_entB(2)                <= '0';
   s_entB(3)                <= '0';
   s_inicio                 <= '0';
   s_logisimInputBubbles(0) <= '0';

   --------------------------------------------------------------------------------
   -- The clock tree components are defined here                                 --
   --------------------------------------------------------------------------------
   BASE_0 : synthesizedClockGenerator
      PORT MAP ( FPGAClock        => fpgaGlobalClock,
                 SynthesizedClock => s_synthesizedClock );

   BASE_1 : logisimTickGenerator
      GENERIC MAP ( nrOfBits    => 26,
                    reloadValue => 50000000 )
      PORT MAP ( FPGAClock => s_synthesizedClock,
                 FPGATick  => s_fpgaTick );

   clk : LogisimClockComponent
      GENERIC MAP ( highTicks => 1,
                    lowTicks  => 1,
                    nrOfBits  => 1,
                    phase     => 1 )
      PORT MAP ( clockBus    => s_logisimClockTree0,
                 clockTick   => s_fpgaTick,
                 globalClock => s_synthesizedClock );

   --------------------------------------------------------------------------------
   -- The toplevel component is connected here                                   --
   --------------------------------------------------------------------------------
   CIRCUIT_0 : main
      PORT MAP ( entA                => s_entA,
                 entB                => s_entB,
                 inicio              => s_inicio,
                 logisimClockTree0   => s_logisimClockTree0,
                 logisimInputBubbles => s_logisimInputBubbles,
                 mult                => s_mult );
END platformIndependent;
