To obatain alertmanager-rules-config.json from alertmanager-rules-config.yaml, run:

`cat alertmanager-rules-config.yaml | gojsontoyaml -yamltojson > alertmanager-rules-config.json`

Similarly, to obtain alertmanager-config-data.json from alertmanager-config-data.yaml, run:

`cat alertmanager-config-data.yaml | gojsontoyaml -yamltojson > alertmanager-config-data.json`


Those two files are obtained from pgo-monitoring:
- https://github.com/CrunchyData/postgres-operator-examples/blob/main/kustomize/monitoring/alertmanager-rules-config.yaml
- https://github.com/CrunchyData/postgres-operator-examples/blob/main/kustomize/monitoring/alertmanager-config.yaml
