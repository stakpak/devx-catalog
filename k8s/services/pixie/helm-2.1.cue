package pixie

import (
	"k8s.io/api/core/v1"
	// "stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^2\\.1\\.6"]: minor: >=21
#Values: [=~"^2\\.1\\.6"]: {

    clusterRegistrationWaitImage: {
        repository: "gcr.io/pixie-oss/pixie-dev-public/curl"
        tag:        "1.0"
        pullPolicy: v1.PullPolicy | *"IfNotPresent"
    }

    image: {
        repository: "newrelic/newrelic-pixie-integration"
        tag:        string | *"latest"
        pullPolicy: v1.PullPolicy | *"IfNotPresent"
        pullSecrets: []
    }

    resources: {
        limits: {
            memory: string | *"250M"
        }
        requests: {
            cpu:    string | *"100m"
            memory: string | *"250M"
        }
    }

    podAnnotations: k8s.#Annotations
    podLabels: k8s.#Labels

    job: {
        annotations: {}
        labels: {}
    }

    proxy: {}

    nodeSelector:   k8s.#Labels

    tolerations: [...v1.#Toleration]

    affinity: v1.#Affinity

    customScripts: {}

    excludeNamespacesRegex: ""
    excludePodsRegex: ""

}
