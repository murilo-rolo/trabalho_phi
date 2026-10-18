#!/usr/bin/env bash
# Abre o Questa em modo GUI com o waveform do tb_main, roda a simulacao,
# captura a janela (ffmpeg x11grab) e salva em sim/questa/img/questa_gui_waveform.png
# Uso: ./sim/questa/gui_wave.sh   (requer X11 ativo em DISPLAY)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/env.sh"
questa_banner

export BUILD_GUI=/tmp/opencode/questa_mult_gui
MARKER=/tmp/opencode/gui_ready.marker
OUT="$SIMQ/img/questa_gui_waveform.png"
DOFILE="$BUILD_GUI/gui_wave.do"

rm -rf "$BUILD_GUI" "$MARKER"
mkdir -p "$BUILD_GUI" "$SIMQ/logs" "$SIMQ/img"
cp -r "$PROJ/main" "$BUILD_GUI/main"
cp "$PROJ/sim/tb_main.vhd" "$BUILD_GUI/tb_main.vhd"
cd "$BUILD_GUI"

vlib work >/dev/null
vmap work work >/dev/null
mapfile -t SOURCES < "$SIMQ/sources.list"
echo "=== Analise Questa (vcom -93) ==="
vcom -93 -work work "${SOURCES[@]}" tb_main.vhd

cat > "$DOFILE" <<EOF
onerror {resume}
quietly set StdArithNoWarnings 1
configure wave -namecolwidth 240
configure wave -valuecolwidth 100
add wave -radix hexadecimal /tb_main/entA
add wave -radix hexadecimal /tb_main/entB
add wave /tb_main/inicio
add wave /tb_main/reset
add wave -radix hexadecimal /tb_main/mult
add wave /tb_main/DUT/s_inicio_out
add wave /tb_main/DUT/BO/s_b_hab
add wave /tb_main/DUT/BO/s_op_sel
add wave /tb_main/DUT/s_ab_0
add wave -radix hexadecimal /tb_main/DUT/BC/s_state_q
add wave -radix hexadecimal /tb_main/DUT/BO/s_reg_p
add wave -radix hexadecimal /tb_main/DUT/BO/s_reg_b
run -all
wave zoom full
exec touch $MARKER
EOF

echo "=== Simulacao Questa GUI (vsim -gui, tb_main) ==="
vsim -gui -lib work tb_main -do "$DOFILE" > "$SIMQ/logs/gui_transcript.log" 2>&1 &
VSIM_PID=$!

echo "Aguardando a simulacao terminar na GUI (marker $MARKER)..."
READY=0
for _ in $(seq 1 120); do
  if [ -f "$MARKER" ]; then READY=1; break; fi
  if ! kill -0 "$VSIM_PID" 2>/dev/null; then break; fi
  sleep 1
done
if [ "$READY" -ne 1 ]; then
  echo "ERRO: GUI nao ficou pronta em 120s. Veja $SIMQ/logs/gui_transcript.log"
  kill "$VSIM_PID" 2>/dev/null || true
  exit 1
fi

# Acha a janela do Questa pelo WM_CLASS "vsim" (evita casar com o terminal).
WINID=""
for id in $(wmctrl -l | awk '{print $1}'); do
  if xprop -id "$id" WM_CLASS 2>/dev/null | grep -q 'vsim'; then
    WINID="$id"
    break
  fi
done
if [ -z "$WINID" ]; then
  echo "ERRO: janela do Questa nao encontrada (wmctrl -l):"
  wmctrl -l || true
  kill "$VSIM_PID" 2>/dev/null || true
  exit 1
fi
WIN=$(wmctrl -lG | grep "^$WINID ")
echo "Janela: $WIN"
wmctrl -i -a "$WINID" 2>/dev/null || wmctrl -a "$WINID"
sleep 2

read -r _ _ X Y W H _ <<< "$WIN"

# Apara a regiao de captura aos limites reais da tela (o WM às vezes
# reporta altura maior que o display) e inclui a barra de decoracao.
read -r SW SH < <(xdpyinfo | awk '/dimensions:/{gsub(/x/," ",$2); print $2}')
DECOR=28
Y=$(( Y - DECOR < 0 ? 0 : Y - DECOR ))
H=$(( H + DECOR ))
X=$(( X < 0 ? 0 : X ))
X2=$(( X + W > SW ? SW : X + W ))
Y2=$(( Y + H > SH ? SH : Y + H ))
W=$(( X2 - X )); H=$(( Y2 - Y ))
echo "Geometria: ${W}x${H}+${X}+${Y} (tela ${SW}x${SH})"
ffmpeg -loglevel error -y -f x11grab -video_size "${W}x${H}" \
  -i ":0.0+${X},${Y}" -frames:v 1 "$OUT"
echo "Screenshot: $OUT"

wmctrl -c "$WINID" 2>/dev/null || true
sleep 1
kill "$VSIM_PID" 2>/dev/null || true
pkill -f "[v]simk.*tb_main" 2>/dev/null || true
for _ in $(seq 1 10); do
  kill -0 "$VSIM_PID" 2>/dev/null || break
  sleep 1
done
kill -9 "$VSIM_PID" 2>/dev/null || true
echo "=== OK ==="
