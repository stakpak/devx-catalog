package strimzi

import (
	"stakpak.dev/devx/k8s"
	"k8s.io/api/core/v1"
)

#KubeVersion: [=~"^0\\.40\\."]: minor: >=21

#Values: [=~"^0\\.40\\."]: {
	// # Default values for strimzi-kafka-operator.
	// # Default replicas for the cluster operator
	replicas: uint | *1

	// # If you set `watchNamespaces` to the same value as ``.Release.Namespace` (e.g. `helm ... --namespace $NAMESPACE`),
	// # the chart will fail because duplicate RoleBindings will be attempted to be created in the same namespace
	watchNamespaces: [...string]
	watchAnyNamespace: bool | *false

	defaultImageRegistry:   string | *"quay.io"
	defaultImageRepository: string | *"strimzi"
	defaultImageTag:        string | *"0.40.0"

	image: {
		registry:   string | *""
		repository: string | *""
		name:       string | *"operator"
		tag:        string | *""
		imagePullSecrets: [...v1.#LocalObjectReference]
	}

	logVolume:                    string | *"co-config-volume"
	logConfigMap:                 string | *"strimzi-cluster-operator"
	logConfiguration:             string | *""
	logLevel:                     string | *"$${env:STRIMZI_LOG_LEVEL:-INFO}"
	fullReconciliationIntervalMs: uint | *120000
	operationTimeoutMs:           uint | *300000
	kubernetesServiceDnsDomain:   string | *"cluster.local"
	featureGates:                 string | *""
	tmpDirSizeLimit:              string | *"1Mi"

	// Additional environment variables
	extraEnvs: [...{
		name:  string
		value: string
	}]

	tolerations: [...v1.#Toleration]
	affinity:          v1.#Affinity
	annotations:       k8s.#Annotations
	labels:            k8s.#Labels
	nodeSelector:      k8s.#Labels
	priorityClassName: string | *""

	podSecurityContext: v1.#PodSecurityContext
	securityContext:    v1.#SecurityContext
	rbac: {
		create: bool | *true
	}
	serviceAccountCreate: bool | *true
	serviceAccount:       string | *"strimzi-cluster-operator"

	leaderElection: {
		enable: bool | *true
	}

	podDisruptionBudget: {
		enabled:        bool | *false
		minAvailable:   uint | null | *1
		maxUnavailable: uint | *null
	}

	dashboards: {
		enabled:     bool | *false
		namespace:   string | *null
		label:       string | *"grafana_dashboard"
		labelValue:  string | *"1"
		annotations: k8s.#Annotations
		extraLabels: k8s.#Labels
	}

	kafka: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka"
			tagPrefix:  string | *""
		}
	}
	kafkaConnect: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka"
			tagPrefix:  string | *""
		}
	}
	topicOperator: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"operator"
			tag:        string | *""
		}
	}
	userOperator: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"operator"
			tag:        string | *""
		}
	}
	kafkaInit: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"operator"
			tag:        string | *""
		}
	}
	tlsSidecarEntityOperator: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka"
			tagPrefix:  string | *""
		}
	}
	kafkaMirrorMaker: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka"
			tagPrefix:  string | *""
		}
	}
	kafkaBridge: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka-bridge"
			tag:        string | *"0.28.0"
		}
	}
	kafkaExporter: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka"
			tagPrefix:  string | *""
		}
	}
	kafkaMirrorMaker2: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka"
			tagPrefix:  string | *""
		}
	}
	cruiseControl: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kafka"
			tagPrefix:  string | *""
		}
	}
	kanikoExecutor: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"kaniko-executor"
			tag:        string | *""
		}
	}
	mavenBuilder: {
		image: {
			registry:   string | *""
			repository: string | *""
			name:       string | *"maven-builder"
			tag:        string | *""
		}
	}
	resources: v1.#ResourceRequirements | *{
		limits: {
			memory: string | *"384Mi"
			cpu:    string | *"1000m"
		}
		requests: {
			memory: string | *"384Mi"
			cpu:    string | *"200m"
		}
	}

	livenessProbe: v1.#Probe | *{
		initialDelaySeconds: int | *10
		periodSeconds:       int | *30
	}
	readinessProbe: v1.#Probe | *{
		initialDelaySeconds: int | *10
		periodSeconds:       int | *30
	}

	createGlobalResources: bool | *true
	// # Create clusterroles that extend existing clusterroles to interact with strimzi crds
	// # Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles
	createAggregateRoles: bool | *false
	// # Override the exclude pattern for exclude some labels
	labelsExclusionPattern: string | *""
	// # Controls whether Strimzi generates network policy resources (By default true)
	generateNetworkPolicy: bool | *true
	// # Override the value for Connect build timeout
	connectBuildTimeoutMs: uint | *300000
}
