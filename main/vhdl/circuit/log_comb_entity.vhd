--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : log_comb                                                    ==
--==============================================================================


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY log_comb IS
   PORT ( ab_0              : IN  std_logic;
          inicio            : IN  std_logic;
          clockTree         : IN  std_logic_vector( 4 DOWNTO 0 );
          s_b_hab           : IN  std_logic;
          s_inicio_out      : IN  std_logic;
          b_hab             : OUT std_logic;
          inicio_out        : OUT std_logic;
          op_sel            : OUT std_logic );
END ENTITY log_comb;
