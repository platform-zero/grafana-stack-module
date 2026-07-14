# grafana stack module

- Module id: `grafana`
- Module repo: `grafana-stack-module`
- Source repo: none declared
- Lifecycle: `active`

## Owned overlays
- `stack.runtime.yaml`
- `stack.config/grafana`

## Dependencies
- `prometheus`
- `stack-foundation`

## Validation

```sh
./tests/validate.sh
```

## Lifecycle

`active` modules are expected to keep `stack.module.json`, owned overlays, and `tests/validate.sh` in sync.
