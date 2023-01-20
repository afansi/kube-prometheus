To obatain postgres-export-podMonitor.json from postgres-export-podMonitor.yaml, run:

`cat postgres-export-podMonitor.yaml | gojsontoyaml -yamltojson > postgres-export-podMonitor.json`


This file is inspired from the following files in pgo-monitoring:
- https://github.com/CrunchyData/postgres-operator-examples/blob/main/kustomize/monitoring/prometheus-config.yaml
