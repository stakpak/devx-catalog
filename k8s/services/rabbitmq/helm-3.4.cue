package rabbitmq

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^3\\.4\\."]: minor: >=21
#Values: [=~"^3\\.4\\."]: {
	global: {
		imageRegistry: string | *""
		imagePullSecrets: [...v1.#LocalObjectReference]
		storageClass: string | *""
	}

	kubeVersion:       string | *""
	nameOverride:      string | *""
	fullnameOverride:  string | *""
	commonLabels:      k8s.#Labels
	commonAnnotations: k8s.#Annotations
	clusterDomain:     string | *"cluster.local"
	extraDeploy: [...]
	diagnosticMode: {
		enabled: bool | *false
	}

	rabbitmqImage: {
		registry:   string | *"docker.io"
		repository: string | *"bitnami/rabbitmq"
		tag:        string | *"3.11.16-debian-11-r3"
		digest:     string | *""
		pullSecrets: [...v1.#LocalObjectReference]
	}

	credentialUpdaterImage: {
		registry:   string | *"docker.io"
		repository: string | *"bitnami/rmq-default-credential-updater"
		tag:        string | *"1.0.2-scratch-r21"
		digest:     string | *""
		pullSecrets: [...v1.#LocalObjectReference]
	}

	clusterOperator: {
		image: {
			registry:   string | *"docker.io"
			repository: string | *"bitnami/rabbitmq-cluster-operator"
			tag:        string | *"2.2.0-scratch-r7"
			digest:     string | *""
			pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
			pullSecrets: [...v1.#LocalObjectReference]
		}
		replicaCount: uint | *1
		topologySpreadConstraints: [...]
		schedulerName:                 string | *""
		terminationGracePeriodSeconds: string | *""
		livenessProbe:                 v1.#Probe | *{
			enabled:             true
			initialDelaySeconds: 5
			periodSeconds:       30
			timeoutSeconds:      5
			successThreshold:    1
			failureThreshold:    5
		}
		readinessProbe: v1.#Probe | *{
			enabled:             true
			initialDelaySeconds: 5
			periodSeconds:       30
			timeoutSeconds:      5
			successThreshold:    1
			failureThreshold:    5
		}
		startupProbe: v1.#Probe | *{
			enabled:             false
			initialDelaySeconds: 5
			periodSeconds:       30
			timeoutSeconds:      5
			successThreshold:    1
			failureThreshold:    5
		}
		customLivenessProbe:  v1.#Probe | *{}
		customReadinessProbe: v1.#Probe | *{}
		customStartupProbe:   v1.#Probe | *{}
		resources:            v1.#ResourceRequirements | *{
			limits: {}
			requests: {}
		}
		podSecurityContext: v1.#PodSecurityContext | *{
			enabled: true
			fsGroup: 1001
		}
		containerSecurityContext: v1.#PodSecurityContext | *{
			enabled:                true
			runAsUser:              1001
			runAsNonRoot:           true
			readOnlyRootFilesystem: true
		}
		command: v1.#Command | *[]
		args:    v1.#Args | *[]
		hostAliases: [...]
		podLabels:             k8s.#Labels
		podAnnotations:        k8s.#Annotations
		podAffinityPreset:     string | *""
		podAntiAffinityPreset: string | *"soft"
		nodeAffinityPreset:    v1.#Affinity
		affinity:              v1.#Affinity
		nodeSelector:          k8s.#Labels
		tolerations: [...v1.#Toleration]
		updateStrategy: {
			type: string | *"RollingUpdate"
		}
		priorityClassName: string | *""
		lifecycleHooks: {}
		containerPorts: {
			metrics: k8s.#Port | *9782
		}
		extraEnvVars: [...]
		extraEnvVarsCM:     string | *""
		extraEnvVarsSecret: string | *""
		extraVolumes: [...]
		extraVolumeMounts: [...]
		sidecars: [...]
		initContainers: [...]
		rbac: {
			create: bool | *true
		}
		serviceAccount: #ServiceAccount
		metrics:        #Metrics
	}

	msgTopologyOperator: {
		image: {
			registry:   string | *"docker.io"
			repository: string | *"bitnami/rmq-messaging-topology-operator"
			tag:        string | *"1.10.3-scratch-r1"
			digest:     string | *""
			pullPolicy: string | *"IfNotPresent"
			pullSecrets: [...v1.#LocalObjectReference]
		}
		replicaCount: uint | *1
		topologySpreadConstraints: [...]
		schedulerName:                 string | *""
		terminationGracePeriodSeconds: string | *""
		hostNetwork:                   string | *"false"
		dnsPolicy:                     string | *"ClusterFirst"

		livenessProbe: v1.#Probe | *{
			enabled:             true
			initialDelaySeconds: 5
			periodSeconds:       30
			timeoutSeconds:      5
			successThreshold:    1
			failureThreshold:    5
		}
		readinessProbe: v1.#Probe | *{
			enabled:             true
			initialDelaySeconds: 5
			periodSeconds:       30
			timeoutSeconds:      5
			successThreshold:    1
			failureThreshold:    5
		}
		startupProbe: v1.#Probe | *{
			enabled:             false
			initialDelaySeconds: 5
			periodSeconds:       30
			timeoutSeconds:      5
			successThreshold:    1
			failureThreshold:    5
		}
		customLivenessProbe:         v1.#Probe | *{}
		customReadinessProbe:        v1.#Probe | *{}
		customStartupProbe:          v1.#Probe | *{}
		existingWebhookCertSecret:   string | *""
		existingWebhookCertCABundle: string | *""
		resources:                   v1.#ResourceRequirements | *{
			limits: {}
			requests: {}
		}
		podSecurityContext: v1.#PodSecurityContext | *{
			enabled: true
			fsGroup: 1001
		}
		containerSecurityContext: v1.#PodSecurityContext | *{
			enabled:                true
			runAsUser:              1001
			runAsNonRoot:           true
			readOnlyRootFilesystem: true
		}
		command:          v1.#Command | *[]
		args:             v1.#Args | *[]
		fullnameOverride: string | *""
		hostAliases: [...]
		podLabels:             k8s.#Labels
		podAnnotations:        k8s.#Annotations
		podAffinityPreset:     string | *""
		podAntiAffinityPreset: string | *"soft"
		nodeAffinityPreset:    v1.#Affinity
		affinity:              v1.#Affinity
		nodeSelector:          k8s.#Labels
		tolerations: [...v1.#Toleration]
		updateStrategy: {
			type: string | *"RollingUpdate"
		}
		priorityClassName: string | *""
		lifecycleHooks:    _ | *{}
		containerPorts: {
			metrics: k8s.#Port | *8080
		}
		extraEnvVars: [...]
		extraEnvVarsCM:     string | *""
		extraEnvVarsSecret: string | *""
		extraVolumes: [...]
		extraVolumeMounts: [...]
		sidecars: [...]
		initContainers: [...]
		rbac: {
			create: bool | *true
		}
		serviceAccount: #ServiceAccount
		metrics:        #Metrics

		service: k8s.Service | *{
			type:  string | *"ClusterIP"
			ports: k8s.#ServicePort | *{
				webhook: 443
			}
			nodePorts: k8s.#ServicePort | *{
				http: ""
			}
			clusterIP:      string | *""
			loadBalancerIP: string | *""
			extraPorts: [...]
			loadBalancerSourceRanges: [...]
			externalTrafficPolicy: string | *"Cluster"
			annotations:           k8s.#Annotations
			sessionAffinity:       string | *"None"
			sessionAffinityConfig: _ | *{}
		}
	}
	useCertManager: bool | *false
}

#ServiceMonitor: {
	enabled:       bool | *false
	jobLabel:      k8s.#Labels | *"app.kubernetes.io/name"
	honorLabels:   bool | *false
	selector:      _ | *{}
	scrapeTimeout: string | *""
	interval:      string | *""
	metricRelabelings: [...]
	relabelings: [...]
	labels: k8s.#Labels
}

#ServiceAccount: {
	// -- Specifies whether a service account should be created.
	create: bool | *true
	// -- Annotations to add to the service account.
	annotations: k8s.#Annotations
	// -- Extra Labels to add to the service account.
	extraLabels: k8s.#Labels
	// -- The name of the service account to use.
	// If not set and create is true, a name is generated using the fullname template.
	name:                         string | *""
	automountServiceAccountToken: bool | *true
}

#Metrics: service: {
	// -- Enable if you use another monitoring tool than Prometheus to scrape the metrics
	enabled: bool | *false

	type: string | *"ClusterIP"

	// -- Metrics service port to scrape
	port:      k8s.#Port | *80
	nodePorts: k8s.#Port | *{
		http: ""
	}
	clusterIP: string | *""
	extraPorts: [...]
	loadBalancerIP: string | *""
	loadBalancerSourceRanges: [...]
	externalTrafficPolicy: string | *"Cluster"

	// -- Additional service annotations
	annotations: k8s.#Annotations | *{
		"prometheus.io/scrape": "true"
		"prometheus.io/port":   port
	}
	sessionAffinity:       string | *"None"
	sessionAffinityConfig: _ | *{}
	serviceMonitor:        #ServiceMonitor
}
