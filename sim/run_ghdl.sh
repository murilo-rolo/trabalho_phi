#!/usr/bin/env bash
# Analisa, elabora e roda o testbench tb_main com GHDL.
# Uso: ./sim/run_ghdl.sh
# Nota: copia as fontes para /tmp porque o caminho do projeto tem acento
#       ("Area de trabalho"), que o GHDL nao aceita no workdir .cf.
set -e
PROJ="$(cd "$(dirname "$0")/.." && pwd)"
BUILD=/tmp/opencode/mult_ghdl
rm -rf "$BUILD"
mkdir -p "$BUILD"
cp -r "$PROJ/main" "$BUILD/main"
cp "$PROJ/sim/tb_main.vhd" "$BUILD/tb_main.vhd"
cd "$BUILD"

WORKDIR=work
mkdir -p "$WORKDIR"

GHDL_FLAGS="--std=93 --workdir=$WORKDIR -fsynopsys"

# Ordem: entities antes das architectures, folhas primeiro
SOURCES=(
  main/vhdl/gates/AND_GATE_entity.vhd
  main/vhdl/gates/AND_GATE_behavior.vhd
  main/vhdl/gates/AND_GATE_3_INPUTS_entity.vhd
  main/vhdl/gates/AND_GATE_3_INPUTS_behavior.vhd
  main/vhdl/gates/OR_GATE_entity.vhd
  main/vhdl/gates/OR_GATE_behavior.vhd
  main/vhdl/arith/Adder_entity.vhd
  main/vhdl/arith/Adder_behavior.vhd
  main/vhdl/arith/Comparator_entity.vhd
  main/vhdl/arith/Comparator_behavior.vhd
  main/vhdl/plexers/Multiplexer_bus_2_entity.vhd
  main/vhdl/plexers/Multiplexer_bus_2_behavior.vhd
  main/vhdl/plexers/Demultiplexer_bus_2_entity.vhd
  main/vhdl/plexers/Demultiplexer_bus_2_behavior.vhd
  main/vhdl/memory/REGISTER_FLIP_FLOP_entity.vhd
  main/vhdl/memory/REGISTER_FLIP_FLOP_behavior.vhd
  main/vhdl/circuit/log_comb_entity.vhd
  main/vhdl/circuit/log_comb_behavior.vhd
  main/vhdl/circuit/bloco_ctr_entity.vhd
  main/vhdl/circuit/bloco_ctr_behavior.vhd
  main/vhdl/circuit/bloco_op_entity.vhd
  main/vhdl/circuit/bloco_op_behavior.vhd
  main/vhdl/circuit/main_entity.vhd
  main/vhdl/circuit/main_behavior.vhd
  tb_main.vhd
)

echo "=== Analise GHDL ==="
for f in "${SOURCES[@]}"; do
  ghdl -a $GHDL_FLAGS "$f"
done

echo "=== Elaboracao GHDL ==="
ghdl -e $GHDL_FLAGS tb_main

echo "=== Simulacao GHDL ==="
# --assert-level=failure: deixa erros de assert continuarem para ver todos os vetores
OUT=$(ghdl -r $GHDL_FLAGS tb_main --assert-level=failure --stop-time=200us 2>&1) || true
echo "$OUT"

if echo "$OUT" | grep -q FALHOU; then
  echo "=== RESULTADO: FALHOU ==="
  exit 1
fi
echo "=== RESULTADO: TODOS VETORES PASSARAM ==="
