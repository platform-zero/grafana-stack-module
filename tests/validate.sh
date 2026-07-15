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
runtime_model="$repo_root/stack.runtime.yaml"
jq -e '
  .title == "Daily Market Data" and
  .version >= 3 and
  ([.panels[].title] | contains([
    "S&P 500",
    "Largest Daily Moves",
    "Source Status",
    "Regional Benchmarks",
    "Market Change Signal (24h)",
    "Instrument Catalog"
  ])) and
  all(.panels[]; .datasource.uid == "prometheus") and
  (any(.panels[].targets[]?; (.expr // "") | contains("market_data_latest_value"))) and
  (any(.panels[].targets[]?; (.expr // "") | contains("topk(14, abs(market_data_daily_change_percent))"))) and
  (any(.panels[].transformations[]?; .id == "organize"))
' "$dashboard" >/dev/null
grep -Eq 'GF_PLUGINS_DISABLE_PLUGINS: "grafana-lokiexplore-app"' "$runtime_model"
grep -Eq 'GF_PLUGINS_PREINSTALL_DISABLED: true' "$runtime_model"
