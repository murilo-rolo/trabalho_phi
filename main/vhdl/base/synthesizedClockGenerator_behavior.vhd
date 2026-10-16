--==============================================================================
--== Projeto    : trabalho_phi                                                ==
--== Componente : synthesizedClockGenerator                                   ==
--==============================================================================

ARCHITECTURE platformIndependent OF synthesizedClockGenerator IS 

BEGIN

   --------------------------------------------------------------------------------
   -- Here the update logic is defined. Loop back the global clock.              --
   --------------------------------------------------------------------------------
    SynthesizedClock  <=  FPGAClock;
END platformIndependent;
