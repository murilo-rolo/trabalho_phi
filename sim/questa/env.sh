#!/usr/bin/env bash
# Ambiente comum da simulacao Questa (fonte este arquivo antes de usar vcom/vsim).
# Uso:   source sim/questa/env.sh

QUESTA_HOME="${QUESTA_HOME:-/home/murilo/apps/altera_lite/25.1std/questa_fse}"
export SALT_LICENSE_SERVER="${SALT_LICENSE_SERVER:-/home/murilo/apps/altera_lite/25.1std/licenses/LR-195606_License.dat}"
export PATH="$QUESTA_HOME/bin:$PATH"

# O caminho do projeto tem acento/espaço; o worklib do Questa é criado em /tmp.
export BUILD="${BUILD:-/tmp/opencode/questa_mult}"
export SIMQ="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJ="$(cd "$SIMQ/../.." && pwd)"

questa_banner() {
  echo "Questa: $(vcom -version 2>&1 | head -1)"
  echo "Licenca SALT_LICENSE_SERVER=$SALT_LICENSE_SERVER"
}
