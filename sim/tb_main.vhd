--==============================================================================
--== Testbench : tb_main                                                      ==
--== Verifica o multiplicador 4x4 (top-level main) com 5 vetores              ==
--== entA = multiplicador (conta decrescente), entB = multiplicando           ==
--==============================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.all;

ENTITY tb_main IS
END ENTITY tb_main;

ARCHITECTURE test OF tb_main IS

   COMPONENT main
      PORT ( entA                : IN  std_logic_vector( 3 DOWNTO 0 );
             entB                : IN  std_logic_vector( 3 DOWNTO 0 );
             inicio              : IN  std_logic;
             clockTree           : IN  std_logic_vector( 4 DOWNTO 0 );
             reset               : IN  std_logic_vector( 0 DOWNTO 0 );
             mult                : OUT std_logic_vector( 7 DOWNTO 0 ) );
   END COMPONENT;

   CONSTANT c_period : time := 20 ns;

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

   -- bit 4: clock (unico sinal necessario apos a correcao de tick/borda);
   -- demais bits desligados, como no cenario real de fiação na placa
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

      PROCEDURE run_vector ( a         : IN integer;
                             b         : IN integer;
                             expected  : IN integer;
                             name      : IN string ) IS
         VARIABLE result : integer;
      BEGIN
         -- Protocolo de partida do circuito: inicio deve estar ALTO antes de
         -- liberar o reset (a FSM registra ab_0 na primeira borda; se inicio
         -- estiver baixo, o estado trava com ab_0=1 e nunca parte).
         entA   <= std_logic_vector(to_unsigned(a, 4));
         entB   <= std_logic_vector(to_unsigned(b, 4));
         inicio <= '1';
         reset  <= '1';
         WAIT FOR 4 * c_period;
         reset  <= '0';

         -- espera folgada: cobre o pior caso mesmo com o bug de extensao
         -- com sinal (operandos >= 8 viram ~250 iteracoes; ~2x250+6 ciclos)
         WAIT FOR 600 * c_period;

         result := to_integer(unsigned(mult));
         ASSERT result = expected
            REPORT "FALHOU " & name & integer'image(a) & " x " &
                   integer'image(b) & " = " & integer'image(result) &
                   " (esperado " & integer'image(expected) & ")"
            SEVERITY error;
         IF result = expected THEN
            REPORT "PASSOU " & name & integer'image(a) & " x " &
                   integer'image(b) & " = " & integer'image(result);
         END IF;

         inicio <= '0';
         WAIT FOR 2 * c_period;
      END PROCEDURE run_vector;

   BEGIN
      REPORT "=== Inicio da simulacao ===";
      run_vector( 3,  5,  15, "3x5  -> " );
      run_vector( 9,  9,  81, "9x9  -> " );
      run_vector(15, 15, 225, "15x15-> " );
      run_vector( 0,  7,   0, "0x7  -> " );
      run_vector( 1,  1,   1, "1x1  -> " );
      REPORT "=== Fim da simulacao ===";
      sim_done <= true;
      WAIT;
   END PROCESS stimulus;

END ARCHITECTURE test;
