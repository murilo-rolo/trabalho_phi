#!/usr/bin/env bash
# Compila o design + tb_main com o Questa (modo batch) e simula.
# Uso: ./sim/questa/run_questa.sh
# Gera: sim/questa/logs/tb_main_transcript.log, dump.wlf, tb_main.vcd
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"
questa_banner

rm -rf "$BUILD"
mkdir -p "$BUILD" "$SIMQ/logs"
cp -r "$PROJ/main" "$BUILD/main"
cp "$PROJ/sim/tb_main.vhd" "$BUILD/tb_main.vhd"
cd "$BUILD"

WORKDIR=work
vlib "$WORKDIR" >/dev/null
vmap work "$WORKDIR" >/dev/null

# Ordem: entities antes das architectures, folhas primeiro (ver sources.list)
mapfile -t SOURCES < "$SIMQ/sources.list"

echo "=== Analise Questa (vcom -93) ==="
vcom -93 -work work "${SOURCES[@]}" tb_main.vhd

echo "=== Simulacao Questa (vsim -c, tb_main) ==="
vsim -c -lib work tb_main -wlf "$BUILD/dump.wlf" \
  -do "log -r /*; run -all; quit -f" \
  2>&1 | tee "$SIMQ/logs/tb_main_transcript.log"

echo "=== Conversao WLF -> VCD ==="
wlf2vcd dump.wlf > "$SIMQ/logs/tb_main.vcd"
cp dump.wlf "$SIMQ/logs/tb_main.wlf"

LOG="$SIMQ/logs/tb_main_transcript.log"
NPASS=$(grep -c "PASSOU" "$LOG" || true)
if grep -q "FALHOU" "$LOG" || grep -qE "^(\*\* )?Error" "$LOG"; then
  echo "=== RESULTADO: FALHOU ==="
  exit 1
fi
if [ "$NPASS" -ne 5 ]; then
  echo "=== RESULTADO: FALHOU (esperava 5 vetores PASSOU, achou $NPASS) ==="
  exit 1
fi
echo "=== RESULTADO: TODOS VETORES PASSARAM (5/5) ==="
echo "Logs: $SIMQ/logs/tb_main_transcript.log  |  VCD: $SIMQ/logs/tb_main.vcd"
