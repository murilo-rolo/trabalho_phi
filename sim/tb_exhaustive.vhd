--==============================================================================
--== Testbench : tb_exhaustive                                                ==
--== Varre os 256 pares 4x4 (entA x entB) do multiplicador sequencial         ==
--== e grava cada resultado em exaustivo_results.txt (textio).                ==
--==============================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE std.textio.all;
USE work.all;

ENTITY tb_exhaustive IS
END ENTITY tb_exhaustive;

ARCHITECTURE test OF tb_exhaustive IS

   COMPONENT main
      PORT ( entA                : IN  std_logic_vector( 3 DOWNTO 0 );
             entB                : IN  std_logic_vector( 3 DOWNTO 0 );
             inicio              : IN  std_logic;
             clockTree           : IN  std_logic_vector( 4 DOWNTO 0 );
             reset               : IN  std_logic_vector( 0 DOWNTO 0 );
             mult                : OUT std_logic_vector( 7 DOWNTO 0 ) );
   END COMPONENT;

   CONSTANT c_period  : time := 20 ns;
   CONSTANT c_wait    : integer := 200;  -- ciclos por vetor (pior caso ~2*15+6)

   SIGNAL clk               : std_logic := '0';
   SIGNAL entA              : std_logic_vector( 3 DOWNTO 0 ) := (OTHERS => '0');
   SIGNAL entB              : std_logic_vector( 3 DOWNTO 0 ) := (OTHERS => '0');
   SIGNAL inicio            : std_logic := '0';
   SIGNAL reset             : std_logic := '0';
   SIGNAL reset_vec         : std_logic_vector( 0 DOWNTO 0 );
   SIGNAL clockTree         : std_logic_vector( 4 DOWNTO 0 );
   SIGNAL mult              : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL sim_done          : boolean   := false;

BEGIN

   clk <= NOT clk AFTER c_period / 2 WHEN NOT sim_done ELSE '0';

   clockTree    <= clk & "0000";
   reset_vec(0) <= reset;

   DUT : main
      PORT MAP ( entA                => entA,
                 entB                => entB,
                 inicio              => inicio,
                 clockTree           => clockTree,
                 reset               => reset_vec,
                 mult                => mult );

   stimulus : PROCESS
      FILE     f_results : text OPEN write_mode IS "exaustivo_results.txt";
      VARIABLE l         : line;
      VARIABLE failures  : integer := 0;

      PROCEDURE run_vector ( a : IN integer; b : IN integer; expected : IN integer ) IS
         VARIABLE result : integer;
      BEGIN
         entA   <= std_logic_vector(to_unsigned(a, 4));
         entB   <= std_logic_vector(to_unsigned(b, 4));
         inicio <= '1';
         reset  <= '1';
         WAIT FOR 4 * c_period;
         reset  <= '0';
         WAIT FOR c_wait * c_period;

         result := to_integer(unsigned(mult));
         write(l, a);              write(l, string'(" "));
         write(l, b);              write(l, string'(" "));
         write(l, result);         write(l, string'(" "));
         write(l, expected);
         IF result = expected THEN
            write(l, string'(" OK"));
         ELSE
            write(l, string'(" FAIL"));
            failures := failures + 1;
         END IF;
         writeline(f_results, l);

         inicio <= '0';
         WAIT FOR 2 * c_period;
      END PROCEDURE run_vector;

   BEGIN
      REPORT "=== Inicio da simulacao exaustiva (256 pares) ===";
      write(l, string'("# a b obtido esperado status")); writeline(f_results, l);
      FOR a IN 0 TO 15 LOOP
         FOR b IN 0 TO 15 LOOP
            run_vector(a, b, a * b);
         END LOOP;
      END LOOP;
      file_close(f_results);

      REPORT "EXAUSTIVO TOTAL=256 FALHAS=" & integer'image(failures);
      ASSERT failures = 0
         REPORT "FALHOU exaustivo: " & integer'image(failures) & " de 256 pares"
         SEVERITY error;
      REPORT "=== Fim da simulacao exaustiva ===";
      sim_done <= true;
      WAIT;
   END PROCESS stimulus;

END ARCHITECTURE test;
