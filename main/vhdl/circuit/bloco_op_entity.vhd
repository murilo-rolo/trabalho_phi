--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : bloco_op                                                    ==
--==============================================================================


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY bloco_op IS
   PORT ( b_hab             : IN  std_logic;
          clk               : IN  std_logic;
          entA              : IN  std_logic_vector( 3 DOWNTO 0 );
          entB              : IN  std_logic_vector( 3 DOWNTO 0 );
          inicio            : IN  std_logic;
          clockTree         : IN  std_logic_vector( 4 DOWNTO 0 );
          op_sel            : IN  std_logic;
          reset             : IN  std_logic;
          ab_0              : OUT std_logic;
          resultado         : OUT std_logic_vector( 7 DOWNTO 0 ) );
END ENTITY bloco_op;
