#!/usr/bin/env python3
"""Renderiza PNGs de verificação a partir das simulações Questa.

Entradas (sim/questa/logs/):
  - tb_main.vcd            : waveform do tb_main (5 vetores)
  - tb_main_transcript.log : transcript do Questa (tb_main)
  - exaustivo_results.txt  : 256 pares do tb_exhaustive
Saídas (sim/questa/img/):
  - wave_3x5.png, wave_15x15.png, wave_full_run.png
  - resultados_tb_main.png, mapa_256_exaustivo.png
Uso: python3 sim/questa/render_wave.py
"""
import bisect
import os
import re
import sys

from PIL import Image, ImageDraw, ImageFont

SIMQ = os.path.dirname(os.path.abspath(__file__))
LOGS = os.path.join(SIMQ, "logs")
IMG = os.path.join(SIMQ, "img")

FMONO = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
FMONOB = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"
FSANSB = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

BG = "#ffffff"
FG = "#1a1a1a"
BUS_FILL = "#e8eef5"
BUS_EDGE = "#274c77"
SPECIAL = "#d93025"
GRID = "#d0d0d0"
ROW_ALT = "#f7f9fb"
OK_BG = "#d7f5d7"
OK_FG = "#14661c"
FAIL_BG = "#f8d7da"
FAIL_FG = "#9b1c24"


class Signal:
    __slots__ = ("scope", "name", "bit", "ident", "changes")

    def __init__(self, scope, name, bit, ident):
        self.scope = scope
        self.name = name
        self.bit = bit
        self.ident = ident
        self.changes = []  # [(time_ns, value)]


def parse_vcd(path):
    signals = []
    by_ident = {}
    scope_stack = []
    in_defs = True
    cur_time = 0
    with open(path, "r", errors="replace") as fh:
        for raw in fh:
            line = raw.strip()
            if not line:
                continue
            if in_defs:
                if line.startswith("$scope"):
                    parts = line.split()
                    scope_stack.append(parts[2])
                elif line.startswith("$upscope"):
                    if scope_stack:
                        scope_stack.pop()
                elif line.startswith("$var"):
                    parts = line.split()
                    ident = parts[3]
                    name = parts[4]
                    bit = None
                    rest = parts[5:]
                    if rest and rest[0].startswith("["):
                        bit = int(rest[0].lstrip("[").rstrip("]"))
                    sig = Signal("/".join(scope_stack), name, bit, ident)
                    signals.append(sig)
                    by_ident[ident] = sig
                elif line.startswith("$enddefinitions"):
                    in_defs = False
                continue
            if line.startswith("#"):
                cur_time = int(line[1:])
            elif line[0] in "01xXzZuUwWlLhH-":
                by_ident[line[1:]].changes.append((cur_time, line[0]))
            elif line[0] in "bB":
                val, ident = line[1:].split(None, 1)
                by_ident[ident.strip()].changes.append((cur_time, val))
    return signals


def value_at(changes, t):
    if not changes:
        return "x"
    if t < changes[0][0]:
        return "x"
    idx = bisect.bisect_right([c[0] for c in changes], t) - 1
    return changes[idx][1]


def build_bus(signals, scope, name):
    bits = {}
    for s in signals:
        if s.scope == scope and s.name == name and s.bit is not None:
            bits[s.bit] = s.changes
    if not bits:
        return None
    lo, hi = min(bits), max(bits)
    times = sorted({t for ch in bits.values() for t, _ in ch})
    out = []
    for t in times:
        val = ""
        for b in range(hi, lo - 1, -1):
            ch = bits.get(b, [])
            idx = bisect.bisect_right([c[0] for c in ch], t) - 1 if ch else -1
            val += ch[idx][1] if idx >= 0 else "x"
        if not out or out[-1][1] != val:
            out.append((t, val))
    return out


def bit_signal(signals, scope, name):
    for s in signals:
        if s.scope == scope and s.name == name and s.bit is None:
            return s.changes
    for s in signals:
        if s.scope == scope and s.name == name:
            return s.changes
    raise KeyError(f"sinal não encontrado: {scope}/{name}")


def bus_int(val):
    if any(c not in "01" for c in val):
        return None
    return int(val, 2)


def fmt_bus(val, with_dec=False):
    n = bus_int(val)
    if n is None:
        return "X" * len(val)
    s = f"{n:0{ (len(val)+3)//4 }X}"
    if with_dec:
        s += f" ({n})"
    return s


def choose_tick(span_ns):
    for step in (10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000):
        if span_ns / step <= 12:
            return step
    return 100000


def fmt_time(t_ns):
    if t_ns >= 1000:
        v = t_ns / 1000.0
        return f"{v:g} us"
    return f"{t_ns:g} ns"


class Trace:
    def __init__(self, label, changes, kind, dec=False):
        self.label = label
        self.changes = changes
        self.kind = kind
        self.dec = dec


def draw_traces(traces, t0, t1, out_png, title, subtitle, marks=()):
    lab_w = 230
    width = 1900
    x0, x1 = lab_w, width - 30
    head_h = 86
    row_h_bit = 30
    row_h_bus = 44
    axis_h = 44
    height = head_h + sum(row_h_bus if tr.kind == "bus" else row_h_bit for tr in traces) + axis_h + 16

    img = Image.new("RGB", (width, height), BG)
    d = ImageDraw.Draw(img)
    f_title = ImageFont.truetype(FSANSB, 20)
    f_sub = ImageFont.truetype(FMONO, 13)
    f_lab = ImageFont.truetype(FMONO, 13)
    f_val = ImageFont.truetype(FMONOB, 12)
    f_ax = ImageFont.truetype(FMONO, 12)
    f_mark = ImageFont.truetype(FMONO, 12)

    d.text((16, 12), title, font=f_title, fill=FG)
    d.text((16, 42), subtitle, font=f_sub, fill="#555555")

    def x_of(t):
        return x0 + (t - t0) / (t1 - t0) * (x1 - x0)

    step = choose_tick(t1 - t0)
    t = (t0 // step) * step
    while t <= t1:
        if t >= t0:
            x = x_of(t)
            d.line([(x, head_h - 6), (x, height - axis_h + 4)], fill=GRID)
            d.text((x + 2, height - axis_h + 8), fmt_time(t), font=f_ax, fill="#444444")
        t += step

    for mt, mlab in marks:
        x = x_of(mt)
        if x0 <= x <= x1:
            for y in range(head_h - 6, height - axis_h + 4, 8):
                d.line([(x, y), (x, y + 4)], fill="#c0392b")
            tw = d.textlength(mlab, font=f_mark)
            tx = x + 3
            if tx + tw > width - 8:
                tx = x - tw - 3
            d.text((tx, head_h - 20), mlab, font=f_mark, fill="#c0392b")

    y = head_h
    for tr in traces:
        is_bus = tr.kind == "bus"
        h = row_h_bus if is_bus else row_h_bit
        d.rectangle([(0, y), (width - 1, y + h - 1)], outline="#eeeeee")
        d.text((12, y + h // 2 - 8), tr.label, font=f_lab, fill=FG)

        ch = tr.changes
        v_start = value_at(ch, t0)
        cur_t = t0
        cur_v = v_start
        events = [(t, v) for t, v in ch if t0 <= t <= t1]
        for et, ev in events:
            if is_bus:
                _bus_seg(d, x_of, cur_t, et, cur_v, y, h, tr.dec, f_val)
            else:
                _bit_seg(d, x_of, cur_t, et, cur_v, y, h)
            cur_t, cur_v = et, ev
        if is_bus:
            _bus_seg(d, x_of, cur_t, t1, cur_v, y, h, tr.dec, f_val)
        else:
            _bit_seg(d, x_of, cur_t, t1, cur_v, y, h)
        y += h

    os.makedirs(os.path.dirname(out_png), exist_ok=True)
    img.save(out_png)
    print(f"  gerado {out_png}")


def _norm(v):
    return v.lower() if v else "x"


def _bit_seg(d, x_of, ta, tb, val, y, h):
    yh, yl = y + 8, y + h - 8
    v = _norm(val)
    xa, xb = x_of(ta), x_of(tb)
    if xb <= xa:
        return
    if v == "1":
        d.line([(xa, yh), (xb, yh)], fill=FG, width=2)
    elif v == "0":
        d.line([(xa, yl), (xb, yl)], fill=FG, width=2)
    else:
        d.rectangle([(xa, yh), (xb, yl)], fill="#fdecea", outline=SPECIAL)
        return
    if ta > 0:
        d.line([(xa, yh), (xa, yl)], fill=FG, width=1)


def _bus_seg(d, x_of, ta, tb, val, y, h, dec, f_val):
    ym = y + h // 2
    hh = h // 2 - 8
    xa, xb = x_of(ta), x_of(tb)
    if xb - xa < 1:
        return
    v = _norm(val)
    unknown = any(c not in "01" for c in v)
    fill = "#fdecea" if unknown else BUS_FILL
    edge = SPECIAL if unknown else BUS_EDGE
    tip = min(9.0, (xb - xa) / 2)
    pts = [(xa, ym - hh), (xa + tip, ym), (xa, ym + hh),
           (xb - tip, ym + hh), (xb, ym), (xb - tip, ym - hh)]
    d.polygon(pts, fill=fill, outline=edge)
    if xb - xa > 52:
        text = fmt_bus(v, with_dec=dec)
        w = d.textlength(text, font=f_val)
        d.text(((xa + xb) / 2 - w / 2, ym - 8), text, font=f_val, fill=FG)


def render_waves():
    vcd = os.path.join(LOGS, "tb_main.vcd")
    signals = parse_vcd(vcd)
    print(f"VCD tb_main: {len(signals)} sinais")

    def mk(label, scope, name, kind, dec=False):
        if kind == "bit":
            return Trace(label, bit_signal(signals, scope, name), "bit")
        ch = build_bus(signals, scope, name)
        if ch is None:
            raise KeyError(f"bus não encontrado: {scope}/{name}")
        return Trace(label, ch, "bus", dec=dec)

    traces = [
        mk("clk (clockTree[4])", "tb_main", "clk", "bit"),
        mk("entA", "tb_main", "entA", "bus"),
        mk("entB", "tb_main", "entB", "bus"),
        mk("inicio", "tb_main", "inicio", "bit"),
        mk("reset[0]", "tb_main", "reset", "bit"),
        mk("mult[7:0]", "tb_main", "mult", "bus", dec=True),
        mk("DUT.inicio_out", "tb_main/DUT", "s_inicio_out", "bit"),
        mk("DUT.b_hab", "tb_main/DUT/BO", "s_b_hab", "bit"),
        mk("DUT.op_sel", "tb_main/DUT/BO", "s_op_sel", "bit"),
        mk("DUT.ab_0", "tb_main/DUT", "s_ab_0", "bit"),
        mk("DUT.estado[2:0]", "tb_main/DUT/BC", "s_state_q", "bus"),
        mk("DUT.P[7:0] (acumulador)", "tb_main/DUT/BO", "s_reg_p", "bus", dec=True),
        mk("DUT.B[3:0] (multiplicador)", "tb_main/DUT/BO", "s_reg_b", "bus"),
    ]

    common = "Questa Intel FPGA Starter Edition 2025.2 — tb_main.vhd — todos os vetores PASSARAM"
    mult_tr = next(t for t in traces if t.label.startswith("mult"))

    def completion_mark(vs, vc, exp):
        last = None
        want = f"{exp:08b}"
        for t, v in mult_tr.changes:
            if vs <= t < vc and _norm(v) == want:
                last = t
        if last is None:
            return []
        return [(last, f"mult={exp} (0x{exp:02X}) estável")]

    # Vetor 3x5: vetor ocupa [0, 12120); a multiplicação termina nos ~250 ns
    draw_traces(
        traces, 0, 1500,
        os.path.join(IMG, "wave_3x5.png"),
        "Multiplicador 4×4 — waveform do vetor 3 × 5 = 15 (zoom da computação)",
        common + " — verificado em 12.08 us",
        marks=completion_mark(0, 12080, 15),
    )
    # Vetor 15x15: pior caso (2*15+6 ciclos); zoom de 2.5 us a partir do start
    draw_traces(
        traces, 24240, 26740,
        os.path.join(IMG, "wave_15x15.png"),
        "Multiplicador 4×4 — waveform do vetor 15 × 15 = 225 (pior caso, zoom)",
        common + " — verificado em 36.32 us",
        marks=completion_mark(24240, 36320, 225),
    )
    draw_traces(
        traces, 0, 60600,
        os.path.join(IMG, "wave_full_run.png"),
        "Multiplicador 4×4 — execução completa do tb_main (5 vetores)",
        common,
        marks=[(12080, "3×5"), (24200, "9×9"), (36320, "15×15"), (48440, "0×7"), (60560, "1×1")],
    )


def render_results_table():
    log = os.path.join(LOGS, "tb_main_transcript.log")
    pat = re.compile(r"PASSOU\s+(\S+)\s*->\s*(\d+)\s*x\s*(\d+)\s*=\s*(\d+)")
    tpat = re.compile(r"Time:\s*([0-9]+)\s*ns")
    rows = []
    with open(log) as fh:
        lines = fh.readlines()
    for i, line in enumerate(lines):
        m = pat.search(line)
        if not m:
            continue
        t = "?"
        if i + 1 < len(lines):
            tm = tpat.search(lines[i + 1])
            if tm:
                t = fmt_time(int(tm.group(1)))
        a, b, got = int(m.group(2)), int(m.group(3)), int(m.group(4))
        rows.append((m.group(1).rstrip("-"), a, b, got, a * b, t))

    ncol = 7
    col_w = [300, 110, 110, 200, 160, 190, 140]
    row_h = 46
    head_h = 52
    width = sum(col_w) + 40
    height = 150 + head_h + row_h * len(rows) + 20
    img = Image.new("RGB", (width, height), BG)
    d = ImageDraw.Draw(img)
    f_t = ImageFont.truetype(FSANSB, 22)
    f_h = ImageFont.truetype(FMONOB, 15)
    f_c = ImageFont.truetype(FMONO, 15)
    f_ok = ImageFont.truetype(FMONOB, 15)

    npass = sum(1 for r in rows if r[3] == r[4])
    d.text((20, 18), "Multiplicador Sequencial 4×4 — verificação funcional (Questa 2025.2)", font=f_t, fill=FG)
    d.text((20, 56), f"tb_main: {npass}/{len(rows)} vetores PASSARAM — transcript sim/questa/logs/tb_main_transcript.log",
           font=f_c, fill="#555555")

    headers = ["Vetor", "entA", "entB", "mult (obtido)", "Esperado", "Concluído em", "Status"]
    y = 110
    x = 20
    d.rectangle([(20, y), (20 + sum(col_w), y + head_h)], fill="#274c77")
    for i, hlab in enumerate(headers):
        d.text((x + 12, y + head_h // 2 - 10), hlab, font=f_h, fill="#ffffff")
        x += col_w[i]
    y += head_h
    for ri, (name, a, b, got, exp, t) in enumerate(rows):
        ok = got == exp
        bg = OK_BG if ok else FAIL_BG
        d.rectangle([(20, y), (20 + sum(col_w), y + row_h)], fill=bg, outline="#cccccc")
        vals = [name, str(a), str(b), str(got), str(exp), t, "PASS" if ok else "FAIL"]
        x = 20
        for i, v in enumerate(vals):
            font = f_ok if i == 6 else f_c
            color = OK_FG if (i == 6 and ok) else (FAIL_FG if i == 6 else FG)
            d.text((x + 12, y + row_h // 2 - 10), v, font=font, fill=color)
            x += col_w[i]
        y += row_h
    out = os.path.join(IMG, "resultados_tb_main.png")
    img.save(out)
    print(f"  gerado {out}")


def render_heatmap():
    src = os.path.join(LOGS, "exaustivo_results.txt")
    data = {}
    nfail = 0
    with open(src) as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            a, b, got, exp, status = line.split()
            data[(int(a), int(b))] = (int(got), status == "OK")
            if status != "OK":
                nfail += 1
    cell = 58
    ml, mt, mr, mb = 92, 150, 30, 56
    width = ml + cell * 16 + mr
    height = mt + cell * 16 + mb
    img = Image.new("RGB", (width, height), BG)
    d = ImageDraw.Draw(img)
    f_t = ImageFont.truetype(FSANSB, 22)
    f_s = ImageFont.truetype(FMONO, 13)
    f_ax = ImageFont.truetype(FMONOB, 14)
    f_cell = ImageFont.truetype(FMONO, 13)

    npass = 256 - nfail
    d.text((20, 16), "Multiplicador Sequencial 4×4 — varredura exaustiva (Questa 2025.2)", font=f_t, fill=FG)
    d.text((20, 54), f"tb_exhaustive: {npass}/256 pares corretos — sim/questa/logs/exaustivo_results.txt",
           font=f_s, fill="#555555")
    d.text((20, 76), "célula = valor lido em mult[7:0] após a multiplicação entA × entB", font=f_s, fill="#555555")

    for a in range(16):
        d.text((20, mt + a * cell + cell // 2 - 10), f"entA={a:2d}", font=f_ax, fill=FG)
        d.text((ml + a * cell + cell // 2 - 14, mt - 28), f"{a:2d}", font=f_ax, fill=FG)
    d.text((ml + 16 * cell // 2 - 30, mt - 54), "entB →", font=f_ax, fill=FG)
    d.text((20, mt - 54), "entA ↓", font=f_ax, fill=FG)

    for a in range(16):
        for b in range(16):
            got, ok = data.get((a, b), (-1, False))
            x = ml + b * cell
            y = mt + a * cell
            d.rectangle([(x, y), (x + cell - 2, y + cell - 2)],
                        fill=OK_BG if ok else FAIL_BG,
                        outline="#b8c4b8" if ok else FAIL_FG)
            d.text((x + 12, y + cell // 2 - 9), str(got), font=f_cell,
                   fill=OK_FG if ok else FAIL_FG)
    legend = f"verde = correto ({npass})   vermelho = incorreto ({nfail})"
    d.text((20, height - 36), legend, font=f_s, fill="#333333")
    out = os.path.join(IMG, "mapa_256_exaustivo.png")
    img.save(out)
    print(f"  gerado {out}")


def main():
    print("Renderizando imagens de verificacao (Questa)...")
    render_waves()
    render_results_table()
    render_heatmap()
    print("OK")


if __name__ == "__main__":
    sys.exit(main())
