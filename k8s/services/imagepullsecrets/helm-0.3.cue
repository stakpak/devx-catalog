package imagepullsecrets

import (
	"guku.io/devx/k8s"
	"k8s.io/api/core/v1"
)

#KubeVersion: [=~"^0\\.3\\."]: minor: >=21
#Values: [=~"^0\\.3\\."]: {
	replicas: uint | *1
	istio: {
		revision: string | *""
	}
	podAnnotations:     k8s.#Annotations | *{}
	podSecurityContext: v1.#PodSecurityContext | *{
		runAsNonRoot: bool | *true
		seccompProfile: {
			type: string | *"RuntimeDefault"
		}
	}
	securityContext: v1.#SecurityContext | *{
		allowPrivilegeEscalation: bool | *false
		capabilities: {
			drop: [string] | *["ALL"]
		}
	}
	image: {
		repository: string | *"ghcr.io/banzaicloud/imagepullsecrets"
		tag:        string | *"v0.3.12"
		pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
	}
	imagePullSecrets: [...v1.#LocalObjectReference]
	nodeSelector: k8s.#Labels
	affinity:     v1.#Affinity
	tolerations: [...v1.#Toleration]
	resources: v1.#ResourceRequirements | *{
		requests: {
			memory: string | *"100Mi"
			cpu:    string | *"100m"
		}
		limits: {
			memory: string | *"200Mi"
			cpu:    string | *"300m"
		}
	}
	service: {
		type: string | *"ClusterIP"
		port: k8s.#Port | *8080
	}
	serviceAccount: {
		annotations: k8s.#Annotations
	}
	serviceMonitor: {
		scrapeInterval: string | *"5s"
		tlsConfig:      {string: string} | *{}
	}
	developmentMode: {
		enabled: bool | *false
	}
	podDisruptionBudget: {
		enabled: bool | *false
	}
	log: {
		level: "panic" | "fatal" | "error" | "warn" | "warning" | "info" | "debug" | "trace"
	} | *{}
	env: {string: string} | *{}

	defaultConfig: {
		enabled:            bool | *false
		targetSecretName:   string | *"default-secret-name"
		namespaces:         {string: string} | *{}
		namespacesWithPods: [string] | *[]
		credentials:        [string] | *[]
	}

	defaultSecret: {
		enabled:    bool | *false
		secretData: {string: string} | *{}
		type:       string | *""
	}

}
