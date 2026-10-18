#!/usr/bin/env bash
# Compila o design + tb_exhaustive com o Questa e simula os 256 pares 4x4.
# Uso: ./sim/questa/run_exhaustive.sh
# Gera: sim/questa/logs/exhaustive_transcript.log, exhaustive.vcd,
#       sim/questa/logs/exaustivo_results.txt
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"
questa_banner

export BUILD_EXH=/tmp/opencode/questa_mult_exh
rm -rf "$BUILD_EXH"
mkdir -p "$BUILD_EXH" "$SIMQ/logs"
cp -r "$PROJ/main" "$BUILD_EXH/main"
cp "$PROJ/sim/tb_exhaustive.vhd" "$BUILD_EXH/tb_exhaustive.vhd"
cd "$BUILD_EXH"

WORKDIR=work
vlib "$WORKDIR" >/dev/null
vmap work "$WORKDIR" >/dev/null

mapfile -t SOURCES < "$SIMQ/sources.list"

echo "=== Analise Questa (vcom -93) ==="
vcom -93 -work work "${SOURCES[@]}" tb_exhaustive.vhd

echo "=== Simulacao Questa (vsim -c, tb_exhaustive, 256 pares) ==="
vsim -c -lib work tb_exhaustive -wlf "$BUILD_EXH/dump.wlf" \
  -do "log -r /*; run -all; quit -f" \
  2>&1 | tee "$SIMQ/logs/exhaustive_transcript.log"

echo "=== Conversao WLF -> VCD ==="
wlf2vcd dump.wlf > "$SIMQ/logs/exhaustive.vcd"
cp dump.wlf "$SIMQ/logs/exhaustive.wlf"
cp exaustivo_results.txt "$SIMQ/logs/exaustivo_results.txt"

LOG="$SIMQ/logs/exhaustive_transcript.log"
NOK=$(grep -c " OK$" "$SIMQ/logs/exaustivo_results.txt" || true)
NFAIL=$(grep -c " FAIL$" "$SIMQ/logs/exaustivo_results.txt" || true)
if [ "$NFAIL" -ne 0 ] || [ "$NOK" -ne 256 ] || grep -q "FALHOU" "$LOG"; then
  echo "=== RESULTADO: FALHOU (OK=$NOK FAIL=$NFAIL) ==="
  exit 1
fi
echo "=== RESULTADO: EXAUSTIVO PASSOU (256/256) ==="
echo "Logs: $SIMQ/logs/exhaustive_transcript.log  |  Resultados: $SIMQ/logs/exaustivo_results.txt"
