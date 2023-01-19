local ingress(name, namespace, rules) = {
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: name,
    namespace: namespace,
    annotations: {
      'nginx.ingress.kubernetes.io/auth-type': 'basic',
      'nginx.ingress.kubernetes.io/auth-secret': 'basic-auth',
      'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
    },
  },
  spec: { rules: rules },
};

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  (import 'kube-prometheus/addons/all-namespaces.libsonnet') +
  (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: 'http://www.grafana.reach.talkylabs.com',
            },
          },
        },
      },
    },
    // Configure External URL's per application and network policy
    grafana+:: {
      networkPolicy+: {
        spec+: {
          ingress: [
            super.ingress[0] + {
              from+: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'app.kubernetes.io/name': 'ingress-nginx',
                    },
                  },
                },
              ],
            },
          ] + super.ingress[1:],
        },
      },
    },
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: 'http://www.alertmanager.reach.talkylabs.com',
        },
      },
      networkPolicy+: {
        spec+: {
          ingress: [
            super.ingress[0] + {
              from+: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'app.kubernetes.io/name': 'ingress-nginx',
                    },
                  },
                },
              ],
            },
          ] + super.ingress[1:],
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://www.prometheus.reach.talkylabs.com',
        },
      },
      networkPolicy+: {
        spec+: {
          ingress: [
            super.ingress[0] + {
              from+: [
                {
                  namespaceSelector: {
                    matchLabels: {
                      'app.kubernetes.io/name': 'ingress-nginx',
                    },
                  },
                },
              ],
            },
          ] + super.ingress[1:],
        },
      },
    },
    // Create ingress objects per application
    ingress+:: {
      'alertmanager-main': ingress(
        'alertmanager-main',
        $.values.common.namespace,
        [{
          host: 'www.alertmanager.reach.talkylabs.com',
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'alertmanager-main',
                  port: {
                    name: 'web',
                  },
                },
              },
            }],
          },
        }]
      ),
      grafana: ingress(
        'grafana',
        $.values.common.namespace,
        [{
          host: 'www.grafana.reach.talkylabs.com',
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'grafana',
                  port: {
                    name: 'http',
                  },
                },
              },
            }],
          },
        }],
      ),
      'prometheus-k8s': ingress(
        'prometheus-k8s',
        $.values.common.namespace,
        [{
          host: 'www.prometheus.reach.talkylabs.com',
          http: {
            paths: [{
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'prometheus-k8s',
                  port: {
                    name: 'web',
                  },
                },
              },
            }],
          },
        }],
      ),
    },
  } + {
    // Create basic auth secret 'ingress-talky-kube-prometheus-auth' using htpasswd:
    // htpasswd -c ingress-talky-kube-prometheus-auth <username>
    // # to encode in base64 from the shell, run: echo -n 'content' | base64
    // # to decode from base64, you can run: echo 'base64-str' | base64 --decode 
    ingress+:: {
      'basic-auth-secret': {
        apiVersion: 'v1',
        kind: 'Secret',
        metadata: {
          name: 'basic-auth',
          namespace: $.values.common.namespace,
        },
        data: { auth: std.base64(importstr 'ingress-talky-kube-prometheus-auth') },
        type: 'Opaque',
      },
    },
  };

{ 'setup/namespace': kp.kubePrometheus.namespace } +
{
  ['setup/' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule' && name != 'networkPolicy' && name != 'service' && name != 'clusterRole' && name != 'deployment' && name != 'clusterRoleBinding' && name != 'serviceAccount'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheusOperator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheusOperator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'prometheusOperator-serviceAccount': kp.prometheusOperator.serviceAccount } +
{ 'prometheusOperator-service': kp.prometheusOperator.service } +
{ 'prometheusOperator-clusterRole': kp.prometheusOperator.clusterRole } +
{ 'prometheusOperator-clusterRoleBinding': kp.prometheusOperator.clusterRoleBinding } +
{ 'prometheusOperator-deployment': kp.prometheusOperator.deployment } +
{ 'prometheusOperator-networkPolicy': kp.prometheusOperator.networkPolicy } +
{ 'kubePrometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackboxExporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kubeStateMetrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetesControlPlane-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
{ ['nodeExporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheusAdapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
