--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : bloco_op                                                    ==
--==============================================================================

ARCHITECTURE platformIndependent OF bloco_op IS 

   -----------------------------------------------------------------------------
   -- Here all used components are defined                                    --
   -----------------------------------------------------------------------------

      COMPONENT Adder
         GENERIC ( extendedBits : INTEGER;
                   nrOfBits     : INTEGER );
         PORT ( carryIn  : IN  std_logic;
                dataA    : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                dataB    : IN  std_logic_vector( (nrOfBits - 1) DOWNTO 0 );
                carryOut : OUT std_logic;
                result   : OUT std_logic_vector( (nrOfBits - 1) DOWNTO 0 ) );
      END COMPONENT;

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

      COMPONENT AND_GATE
         GENERIC ( BubblesMask : std_logic_vector );
         PORT ( input1 : IN  std_logic;
                input2 : IN  std_logic;
                result : OUT std_logic );
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

      COMPONENT OR_GATE
         GENERIC ( BubblesMask : std_logic_vector );
         PORT ( input1 : IN  std_logic;
                input2 : IN  std_logic;
                result : OUT std_logic );
      END COMPONENT;

--------------------------------------------------------------------------------
-- All used signals are defined here                                          --
--------------------------------------------------------------------------------
   SIGNAL s_logisimBus0  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus13 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus14 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus15 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus16 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus17 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus19 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus22 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus27 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus29 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus31 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus32 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus4  : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus5  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus7  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus8  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus9  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimNet1  : std_logic;
   SIGNAL s_logisimNet10 : std_logic;
   SIGNAL s_logisimNet11 : std_logic;
   SIGNAL s_logisimNet12 : std_logic;
   SIGNAL s_logisimNet18 : std_logic;
   SIGNAL s_logisimNet2  : std_logic;
   SIGNAL s_logisimNet20 : std_logic;
   SIGNAL s_logisimNet21 : std_logic;
   SIGNAL s_logisimNet23 : std_logic;
   SIGNAL s_logisimNet24 : std_logic;
   SIGNAL s_logisimNet25 : std_logic;
   SIGNAL s_logisimNet26 : std_logic;
   SIGNAL s_logisimNet28 : std_logic;
   SIGNAL s_logisimNet3  : std_logic;
   SIGNAL s_logisimNet30 : std_logic;
   SIGNAL s_logisimNet6  : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- Here all wiring is defined                                                 --
   --------------------------------------------------------------------------------
   s_logisimBus4(0) <= s_logisimNet25;
   s_logisimBus4(1) <= s_logisimNet11;
   s_logisimBus4(2) <= s_logisimNet26;
   s_logisimBus4(3) <= s_logisimNet10;
   s_logisimNet10   <= s_logisimBus9(3);
   s_logisimNet11   <= s_logisimBus9(1);
   s_logisimNet25   <= s_logisimBus9(0);
   s_logisimNet26   <= s_logisimBus9(2);

   --------------------------------------------------------------------------------
   -- Here all input connections are defined                                     --
   --------------------------------------------------------------------------------
   s_logisimBus15(3 DOWNTO 0) <= entA;
   s_logisimBus29(3 DOWNTO 0) <= entB;
   s_logisimNet20             <= b_hab;
   s_logisimNet23             <= op_sel;
   s_logisimNet24             <= reset;
   s_logisimNet28             <= clk;
   s_logisimNet30             <= inicio;

   --------------------------------------------------------------------------------
   -- Here all output connections are defined                                    --
   --------------------------------------------------------------------------------
   ab_0      <= s_logisimNet18;
   resultado <= s_logisimBus0(7 DOWNTO 0);

   --------------------------------------------------------------------------------
   -- Here all in-lined components are defined                                   --
   --------------------------------------------------------------------------------

   -- Extensor de bits
    s_logisimBus8(0)  <=  s_logisimBus17(0);
    s_logisimBus8(1)  <=  s_logisimBus17(1);
    s_logisimBus8(2)  <=  s_logisimBus17(2);
    s_logisimBus8(3)  <=  s_logisimBus17(3);
    s_logisimBus8(4)  <=  s_logisimBus17(3);
    s_logisimBus8(5)  <=  s_logisimBus17(3);
    s_logisimBus8(6)  <=  s_logisimBus17(3);
    s_logisimBus8(7)  <=  s_logisimBus17(3);


   -- Constante
    s_logisimBus13(7 DOWNTO 0)  <=  X"FF";


   -- Extensor de bits
    s_logisimBus14(0)  <=  s_logisimBus31(0);
    s_logisimBus14(1)  <=  s_logisimBus31(1);
    s_logisimBus14(2)  <=  s_logisimBus31(2);
    s_logisimBus14(3)  <=  s_logisimBus31(3);
    s_logisimBus14(4)  <=  s_logisimBus31(3);
    s_logisimBus14(5)  <=  s_logisimBus31(3);
    s_logisimBus14(6)  <=  s_logisimBus31(3);
    s_logisimBus14(7)  <=  s_logisimBus31(3);


   -- Porta NOT
   s_logisimNet12 <=  NOT s_logisimNet20;

   -- Porta NOT
   s_logisimNet6 <=  NOT s_logisimNet23;

   -- Constante
    s_logisimBus32(3 DOWNTO 0)  <=  X"0";


   -- Constante
    s_logisimBus16(3 DOWNTO 0)  <=  X"0";


   --------------------------------------------------------------------------------
   -- Here all normal components are defined                                     --
   --------------------------------------------------------------------------------
   ARITH_1 : Adder
      GENERIC MAP ( extendedBits => 9,
                    nrOfBits     => 8 )
      PORT MAP ( carryIn  => '0',
                 carryOut => OPEN,
                 dataA    => s_logisimBus7(7 DOWNTO 0),
                 dataB    => s_logisimBus19(7 DOWNTO 0),
                 result   => s_logisimBus27(7 DOWNTO 0) );

   PLEXERS_2 : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_logisimBus0(7 DOWNTO 0),
                 muxIn_1 => s_logisimBus13(7 DOWNTO 0),
                 muxOut  => s_logisimBus19(7 DOWNTO 0),
                 sel     => s_logisimNet23 );

   PLEXERS_3 : Demultiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( demuxIn    => s_logisimBus27(7 DOWNTO 0),
                 demuxOut_0 => s_logisimBus9(7 DOWNTO 0),
                 demuxOut_1 => s_logisimBus5(7 DOWNTO 0),
                 enable     => '1',
                 sel        => s_logisimNet6 );

   PLEXERS_4 : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_logisimBus8(7 DOWNTO 0),
                 muxIn_1 => s_logisimBus14(7 DOWNTO 0),
                 muxOut  => s_logisimBus7(7 DOWNTO 0),
                 sel     => s_logisimNet23 );

   P : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 8 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_logisimNet2,
                 d           => s_logisimBus5(7 DOWNTO 0),
                 q           => s_logisimBus0(7 DOWNTO 0),
                 reset       => s_logisimNet24,
                 tick        => logisimClockTree0(2) );

   GATES_6 : AND_GATE
      GENERIC MAP ( BubblesMask => "00" )
      PORT MAP ( input1 => s_logisimNet30,
                 input2 => s_logisimNet12,
                 result => s_logisimNet2 );

   PLEXERS_7 : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 4 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_logisimBus29(3 DOWNTO 0),
                 muxIn_1 => s_logisimBus4(3 DOWNTO 0),
                 muxOut  => s_logisimBus22(3 DOWNTO 0),
                 sel     => s_logisimNet23 );

   B : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 4 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_logisimNet21,
                 d           => s_logisimBus22(3 DOWNTO 0),
                 q           => s_logisimBus31(3 DOWNTO 0),
                 reset       => s_logisimNet24,
                 tick        => logisimClockTree0(2) );

   GATES_9 : AND_GATE
      GENERIC MAP ( BubblesMask => "00" )
      PORT MAP ( input1 => s_logisimNet30,
                 input2 => s_logisimNet20,
                 result => s_logisimNet21 );

   A : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 4 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_logisimNet30,
                 d           => s_logisimBus15(3 DOWNTO 0),
                 q           => s_logisimBus17(3 DOWNTO 0),
                 reset       => s_logisimNet24,
                 tick        => logisimClockTree0(2) );

   ARITH_11 : Comparator
      GENERIC MAP ( nrOfBits       => 4,
                    twosComplement => 0 )
      PORT MAP ( aEqualsB      => s_logisimNet1,
                 aGreaterThanB => OPEN,
                 aLessThanB    => OPEN,
                 dataA         => s_logisimBus31(3 DOWNTO 0),
                 dataB         => s_logisimBus32(3 DOWNTO 0) );

   ARITH_12 : Comparator
      GENERIC MAP ( nrOfBits       => 4,
                    twosComplement => 0 )
      PORT MAP ( aEqualsB      => s_logisimNet3,
                 aGreaterThanB => OPEN,
                 aLessThanB    => OPEN,
                 dataA         => s_logisimBus17(3 DOWNTO 0),
                 dataB         => s_logisimBus16(3 DOWNTO 0) );

   GATES_13 : OR_GATE
      GENERIC MAP ( BubblesMask => "00" )
      PORT MAP ( input1 => s_logisimNet1,
                 input2 => s_logisimNet3,
                 result => s_logisimNet18 );


END platformIndependent;
