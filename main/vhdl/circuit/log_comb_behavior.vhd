--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : log_comb                                                    ==
--== Descricao  : Logica combinacional da FSM (equacoes originais do Logisim, ==
--==              reescritas com atribuicoes concorrentes):                    ==
--==   b_hab      = !s_inicio_out & inicio | s_inicio_out & !s_b_hab & !ab_0  ==
--==   inicio_out = !ab_0 & inicio | s_inicio_out & !ab_0                     ==
--==   op_sel     = s_inicio_out & !s_b_hab & !ab_0                           ==
--==============================================================================

USE work.all;

ARCHITECTURE platformIndependent OF log_comb IS

   SIGNAL s_n_ab_0        : std_logic;
   SIGNAL s_n_inicio_out  : std_logic;
   SIGNAL s_n_b_hab       : std_logic;
   SIGNAL s_op_sel_next   : std_logic;
   SIGNAL s_b_hab_start   : std_logic;
   SIGNAL s_inicio_start  : std_logic;
   SIGNAL s_inicio_hold   : std_logic;

BEGIN

   --------------------------------------------------------------------------------
   -- Negacoes (cada entrada negada uma unica vez)                               --
   --------------------------------------------------------------------------------
   s_n_ab_0       <= NOT ab_0;
   s_n_inicio_out <= NOT s_inicio_out;
   s_n_b_hab      <= NOT s_b_hab;

   --------------------------------------------------------------------------------
   -- Equacoes da FSM                                                            --
   --------------------------------------------------------------------------------

   -- Termo comum a b_hab (2o termo) e a op_sel
   s_op_sel_next  <= s_inicio_out AND s_n_b_hab AND s_n_ab_0;

   b_hab          <= s_b_hab_start OR s_op_sel_next;
   s_b_hab_start  <= s_n_inicio_out AND inicio;

   inicio_out     <= s_inicio_start OR s_inicio_hold;
   s_inicio_start <= s_n_ab_0 AND inicio;
   s_inicio_hold  <= s_inicio_out AND s_n_ab_0;

   op_sel         <= s_op_sel_next;

END platformIndependent;
