package grafana

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

// Define Helm chart settings
#KubeVersion: [=~"^8\\.5\\."]: minor: >=21

#Values: [=~"^8\\.5\\."]: {

    global: {
        imageRegistry: string | *null
        imagePullSecrets: [...string] | *[]
    }

    grafana: {
        enabled:      bool | *true
        isDefault:    bool | *true

        // Health check probes
        readinessProbe: {
            httpGet: {
                path: string | *"/api/health"
                port: int | *3000
            }
        }
        livenessProbe: {
            httpGet: {
                path: string | *"/api/health"
                port: int | *3000
            }
            initialDelaySeconds: int | *60
            timeoutSeconds:      int | *30
            failureThreshold:    int | *10
        }

        // Service configuration
        service: {
            enabled:      bool | *true
            type:         string | *"ClusterIP"
            port:         int | *80
            targetPort:   int | *3000
            annotations:  k8s.#Annotations
            labels:       k8s.#Labels
        }

        // Image configuration for Grafana
        image: {
            registry:     string | *"docker.io"
            repository:   string | *"grafana/grafana"
            tag:          string | *"latest"
            pullPolicy:   v1.PullPolicy | *"IfNotPresent"
        }

        // Resource requests and limits
        resources: {
            limits: {
                cpu:    string | *"500m"
                memory: string | *"1Gi"
            }
            requests: {
                cpu:    string | *"250m"
                memory: string | *"512Mi"
            }
        }

        // Persistence settings
        persistence: {
            enabled:     bool | *false
            accessModes: [...string] | *["ReadWriteOnce"]
            size:        string | *"10Gi"
        }

        // Additional configurations for pods
        nodeSelector: k8s.#Labels
        tolerations:  [...v1.#Toleration]
        affinity:     v1.#Affinity
    }

    // Datasources for Grafana
    // datasources: {
    //     "datasources.yaml": {
    //         apiVersion: 1
    //         datasources: [
    //             {
    //                 name:      "Prometheus"
    //                 type:      "prometheus"
    //                 url:       string | *"http://prometheus-server.monitoring.svc.cluster.local:80"
    //                 access:    "proxy"
    //                 isDefault: true
    //             },
    //             {
    //                 name:      "Loki"
    //                 type:      "loki"
    //                 url:       string | *"http://loki.monitoring.svc.cluster.local:3100"
    //                 access:    "proxy"
    //                 isDefault: false
    //             },
    //         ]
    //     }
    // }

    // Service account and RBAC
    serviceAccount: {
        create: bool | *true
        name:   string | *null
    }
    rbac: {
        create:           bool | *true
        pspEnabled:       bool | *false
        extraRoleRules:   [...{}] | *[]
        extraClusterRoleRules: [...{}] | *[]
    }
}