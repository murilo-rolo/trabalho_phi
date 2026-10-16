--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : main                                                        ==
--==============================================================================


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY main IS
   PORT ( entA                : IN  std_logic_vector( 3 DOWNTO 0 );
          entB                : IN  std_logic_vector( 3 DOWNTO 0 );
          inicio              : IN  std_logic;
          logisimClockTree0   : IN  std_logic_vector( 4 DOWNTO 0 );
          logisimInputBubbles : IN  std_logic_vector( 0 DOWNTO 0 );
          mult                : OUT std_logic_vector( 7 DOWNTO 0 ) );
END ENTITY main;
