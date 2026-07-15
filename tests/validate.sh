#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
validator="${WEBSERVICES_MODULE_CONTRACT_VALIDATOR:-}"
if [ -z "$validator" ]; then
  for candidate in     "$repo_root/../../sso-stack-generator/scripts/modules/module-contract.sh"     "$repo_root/../sso-stack-generator/scripts/modules/module-contract.sh"; do
    if [ -x "$candidate" ]; then
      validator="$candidate"
      break
    fi
  done
fi
[ -n "$validator" ] || { printf '[module-contract] set WEBSERVICES_MODULE_CONTRACT_VALIDATOR or keep sso-stack-generator next to modules workspace\n' >&2; exit 1; }
"$validator" validate "$repo_root"
dashboard="$repo_root/stack.config/grafana/provisioning/dashboards/market-data.json"
jq -e '
  .title == "Daily Market Data" and
  ([.panels[].title] | contains(["Australia", "China", "Europe", "Asia", "United States", "Global + Crypto"])) and
  (any(.panels[].targets[]?; (.expr // "") | contains("market_data_latest_value")))
' "$dashboard" >/dev/null
