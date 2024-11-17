package pixie

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^0\\.1\\.6"]: minor: >=21
#Values: [=~"^0\\.1\\.6"]: {
    // OLM configuration
    deployOLM:        *"" | string // Optional; defaults to whether OLM is present in the cluster.
    olmNamespace:     *"olm" | string
    olmOperatorNamespace: *"px-operator" | string
    olmBundleChannel: *"stable" | string

    olmCatalogSource: {
      annotations: {} // Optional annotations for CatalogSource pods.
      labels:      {} // Optional labels for CatalogSource pods.
    }

    // Vizier configuration
    vizier: {
      name:           *"pixie" | string // Name of the Vizier instance
      clusterName:    string | *"ObservTest" // Cluster name for Vizier monitoring
      version:        *"" | string // Operator deploys the latest version if empty
      // deployKey:      string | *"px-dep-7f20ab42-b199-418f-872b-f5a84378152f" // Deployment key for Vizier
      deployKey:      string // Deployment key for Vizier
      disableAutoUpdate:    *false | bool // Disable auto-updates if true
      useEtcdOperator:      *false | bool // Use etcd for in-memory storage if true
      cloudAddr:            *"withpixie.ai:443" | string // Pixie cloud instance address
      devCloudNamespace:    *"plc" | string // Namespace for dev Pixie cloud, if used

      pemMemoryLimit:       *"" | string // PEM pod memory limit (defaults to 2Gi if empty)
      pemMemoryRequest:     *"" | string // PEM pod memory request (defaults to pemMemoryLimit if empty)
      dataAccess:           *"Full" | string // Data access level for scripts on cluster

      pod: {
        annotations:      k8s.#Annotations
        labels: k8s.#Labels
        resources:   { 

          limits: {
            cpu: *"500m" | string
            memory: *"2Gi" | string
          }
          requests: {
            cpu: *"100m" | string
            memory: *"1Gi" | string
          }
        }

        nodeSelector: k8s.#Labels
        tolerations: [...v1.#Toleration]
      }

    }

}