To obatain artemis-cluster-service-monitor.json from artemis-cluster-service-monitor.yaml, run:

`cat artemis-cluster-service-monitor.yaml | gojsontoyaml -yamltojson > artemis-cluster-service-monitor.json`


This file is inspired from the following files in artemisCloud-examples:
- https://github.com/artemiscloud/artemiscloud-examples/blob/main/operator/prometheus/prometheus/service_monitor.yaml
