--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : bloco_op                                                    ==
--==============================================================================

ARCHITECTURE platformIndependent OF bloco_op IS 

   -----------------------------------------------------------------------------
   -- Here all used components are defined                                    --
   -----------------------------------------------------------------------------

      COMPONENT OR_GATE
         GENERIC ( BubblesMask : std_logic_vector );
         PORT ( input1 : IN  std_logic;
                input2 : IN  std_logic;
                result : OUT std_logic );
      END COMPONENT;

      COMPONENT AND_GATE
         GENERIC ( BubblesMask : std_logic_vector );
         PORT ( input1 : IN  std_logic;
                input2 : IN  std_logic;
                result : OUT std_logic );
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
   SIGNAL s_logisimBus0  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus1  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus10 : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus12 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus13 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus14 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus15 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus18 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus20 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus23 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus26 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus27 : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus5  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus6  : std_logic_vector( 3 DOWNTO 0 );
   SIGNAL s_logisimBus7  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimBus9  : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_logisimNet11 : std_logic;
   SIGNAL s_logisimNet16 : std_logic;
   SIGNAL s_logisimNet17 : std_logic;
   SIGNAL s_logisimNet19 : std_logic;
   SIGNAL s_logisimNet2  : std_logic;
   SIGNAL s_logisimNet21 : std_logic;
   SIGNAL s_logisimNet22 : std_logic;
   SIGNAL s_logisimNet24 : std_logic;
   SIGNAL s_logisimNet25 : std_logic;
   SIGNAL s_logisimNet3  : std_logic;
   SIGNAL s_logisimNet4  : std_logic;
   SIGNAL s_logisimNet8  : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- Here all input connections are defined                                     --
   --------------------------------------------------------------------------------
   s_logisimBus10(3 DOWNTO 0) <= entA;
   s_logisimBus6(3 DOWNTO 0)  <= entB;
   s_logisimNet17             <= b_hab;
   s_logisimNet21             <= op_sel;
   s_logisimNet22             <= reset;
   s_logisimNet24             <= clk;
   s_logisimNet25             <= inicio;

   --------------------------------------------------------------------------------
   -- Here all output connections are defined                                    --
   --------------------------------------------------------------------------------
   ab_0      <= s_logisimNet16;
   resultado <= s_logisimBus1(7 DOWNTO 0);

   --------------------------------------------------------------------------------
   -- Here all in-lined components are defined                                   --
   --------------------------------------------------------------------------------

   -- Constante
    s_logisimBus15(7 DOWNTO 0)  <=  X"00";


   -- Constante
    s_logisimBus27(7 DOWNTO 0)  <=  X"00";


   -- Constante
    s_logisimBus12(7 DOWNTO 0)  <=  X"FF";


   -- Porta NOT
   s_logisimNet11 <=  NOT s_logisimNet17;

   -- Porta NOT
   s_logisimNet8 <=  NOT s_logisimNet21;

   -- Extensor de bits
    s_logisimBus0(0)  <=  s_logisimBus10(0);
    s_logisimBus0(1)  <=  s_logisimBus10(1);
    s_logisimBus0(2)  <=  s_logisimBus10(2);
    s_logisimBus0(3)  <=  s_logisimBus10(3);
    s_logisimBus0(4)  <=  s_logisimBus10(3);
    s_logisimBus0(5)  <=  s_logisimBus10(3);
    s_logisimBus0(6)  <=  s_logisimBus10(3);
    s_logisimBus0(7)  <=  s_logisimBus10(3);


   -- Extensor de bits
    s_logisimBus13(0)  <=  s_logisimBus6(0);
    s_logisimBus13(1)  <=  s_logisimBus6(1);
    s_logisimBus13(2)  <=  s_logisimBus6(2);
    s_logisimBus13(3)  <=  s_logisimBus6(3);
    s_logisimBus13(4)  <=  s_logisimBus6(3);
    s_logisimBus13(5)  <=  s_logisimBus6(3);
    s_logisimBus13(6)  <=  s_logisimBus6(3);
    s_logisimBus13(7)  <=  s_logisimBus6(3);


   --------------------------------------------------------------------------------
   -- Here all normal components are defined                                     --
   --------------------------------------------------------------------------------
   GATES_1 : OR_GATE
      GENERIC MAP ( BubblesMask => "00" )
      PORT MAP ( input1 => s_logisimNet2,
                 input2 => s_logisimNet3,
                 result => s_logisimNet16 );

   GATES_2 : AND_GATE
      GENERIC MAP ( BubblesMask => "00" )
      PORT MAP ( input1 => s_logisimNet25,
                 input2 => s_logisimNet17,
                 result => s_logisimNet19 );

   GATES_3 : AND_GATE
      GENERIC MAP ( BubblesMask => "00" )
      PORT MAP ( input1 => s_logisimNet25,
                 input2 => s_logisimNet11,
                 result => s_logisimNet4 );

   PLEXERS_4 : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_logisimBus14(7 DOWNTO 0),
                 muxIn_1 => s_logisimBus26(7 DOWNTO 0),
                 muxOut  => s_logisimBus9(7 DOWNTO 0),
                 sel     => s_logisimNet21 );

   PLEXERS_5 : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_logisimBus1(7 DOWNTO 0),
                 muxIn_1 => s_logisimBus12(7 DOWNTO 0),
                 muxOut  => s_logisimBus18(7 DOWNTO 0),
                 sel     => s_logisimNet21 );

   PLEXERS_6 : Demultiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( demuxIn    => s_logisimBus23(7 DOWNTO 0),
                 demuxOut_0 => s_logisimBus5(7 DOWNTO 0),
                 demuxOut_1 => s_logisimBus7(7 DOWNTO 0),
                 enable     => '1',
                 sel        => s_logisimNet8 );

   PLEXERS_7 : Multiplexer_bus_2
      GENERIC MAP ( nrOfBits => 8 )
      PORT MAP ( enable  => '1',
                 muxIn_0 => s_logisimBus13(7 DOWNTO 0),
                 muxIn_1 => s_logisimBus5(7 DOWNTO 0),
                 muxOut  => s_logisimBus20(7 DOWNTO 0),
                 sel     => s_logisimNet21 );

   ARITH_8 : Comparator
      GENERIC MAP ( nrOfBits       => 8,
                    twosComplement => 0 )
      PORT MAP ( aEqualsB      => s_logisimNet3,
                 aGreaterThanB => OPEN,
                 aLessThanB    => OPEN,
                 dataA         => s_logisimBus14(7 DOWNTO 0),
                 dataB         => s_logisimBus15(7 DOWNTO 0) );

   ARITH_9 : Comparator
      GENERIC MAP ( nrOfBits       => 8,
                    twosComplement => 0 )
      PORT MAP ( aEqualsB      => s_logisimNet2,
                 aGreaterThanB => OPEN,
                 aLessThanB    => OPEN,
                 dataA         => s_logisimBus26(7 DOWNTO 0),
                 dataB         => s_logisimBus27(7 DOWNTO 0) );

   ARITH_10 : Adder
      GENERIC MAP ( extendedBits => 9,
                    nrOfBits     => 8 )
      PORT MAP ( carryIn  => '0',
                 carryOut => OPEN,
                 dataA    => s_logisimBus9(7 DOWNTO 0),
                 dataB    => s_logisimBus18(7 DOWNTO 0),
                 result   => s_logisimBus23(7 DOWNTO 0) );

   A : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 8 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_logisimNet25,
                 d           => s_logisimBus0(7 DOWNTO 0),
                 q           => s_logisimBus14(7 DOWNTO 0),
                 reset       => s_logisimNet22,
                 tick        => logisimClockTree0(2) );

   B : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 8 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_logisimNet19,
                 d           => s_logisimBus20(7 DOWNTO 0),
                 q           => s_logisimBus26(7 DOWNTO 0),
                 reset       => s_logisimNet22,
                 tick        => logisimClockTree0(2) );

   P : REGISTER_FLIP_FLOP
      GENERIC MAP ( invertClock => 0,
                    nrOfBits    => 8 )
      PORT MAP ( clock       => logisimClockTree0(4),
                 clockEnable => s_logisimNet4,
                 d           => s_logisimBus7(7 DOWNTO 0),
                 q           => s_logisimBus1(7 DOWNTO 0),
                 reset       => s_logisimNet22,
                 tick        => logisimClockTree0(2) );


END platformIndependent;
