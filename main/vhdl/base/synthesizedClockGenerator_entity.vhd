--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : synthesizedClockGenerator                                   ==
--==============================================================================


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY synthesizedClockGenerator IS
   PORT ( FPGAClock        : IN  std_logic;
          SynthesizedClock : OUT std_logic );
END ENTITY synthesizedClockGenerator;
