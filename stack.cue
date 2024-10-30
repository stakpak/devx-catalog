package main

import (
    "stakpak.dev/devx/v1"
     "stakpak.dev/devx/v1/traits"
    "stakpak.dev/devx/k8s/stacks"
)

stack: v1.#Stack & {
    components: {
        // EKS Cluster Configuration
        cluster: {
            traits.#KubernetesCluster
            k8s: name: "demo"
            k8s: version: minor: 27
            aws: {
                region: "us-east-1"
                vpc: {
                    name: "default"
                    cidr: "10.0.0.0/16"
                    subnets: {
                        private: [
                            "10.0.1.0/24",
                            "10.0.2.0/24",
                            "10.0.3.0/24" 
                        ]
                        public:  [
                            "10.0.101.0/24",
                            "10.0.102.0/24",
                            "10.0.103.0/24" 
                        ]
                    }
                }
            }
            eks: {
                moduleVersion: "19.21.0"
                instanceType:  "t3.small"
                minSize:       2
                maxSize:       5
                desiredSize:   2
                public:        true
            }
         }
        // Add Observability Stack
		stacks.ObservabilityStack.components
        grafana:    k8s: cluster.k8s
        prometheus: k8s: cluster.k8s
        loki:       k8s: cluster.k8s
        pixie:      k8s: cluster.k8s
    }
}

