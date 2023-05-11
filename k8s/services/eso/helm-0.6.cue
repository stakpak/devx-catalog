package eso

import (
	"guku.io/devx/k8s"
	"k8s.io/api/core/v1"
	admv1 "k8s.io/api/admissionregistration/v1"
)

#KubeVersion: [=~"^0\\.6\\."]: minor: >=19
#Values: [=~"^0\\.6\\."]: {
	replicaCount: uint | *1

	image: #Image

	// -- If set, install and upgrade CRDs through helm chart.
	installCRDs: bool | *true

	crds: {
		// -- If true, create CRDs for Cluster External Secret.
		createClusterExternalSecret: bool | *true
		// -- If true, create CRDs for Cluster Secret Store.
		createClusterSecretStore: bool | *true
	}

	imagePullSecrets: [...v1.#LocalObjectReference]
	nameOverride:     string | *""
	fullnameOverride: string | *""

	// -- If true, external-secrets will perform leader election between instances to ensure no more
	// than one instance of external-secrets operates at a time.
	leaderElect: bool | *false

	// -- If set external secrets will filter matching
	// Secret Stores with the appropriate controller values.
	controllerClass: string | *""

	// -- If set external secrets are only reconciled in the
	// provided namespace
	scopedNamespace: string | *""

	// -- Must be used with scopedNamespace. If true, create scoped RBAC roles under the scoped namespace
	// and implicitly disable cluster stores and cluster external secrets
	scopedRBAC: bool | *false

	// -- if true, the operator will process cluster external secret. Else, it will ignore them.
	processClusterExternalSecret: bool | *true

	// -- if true, the operator will process cluster store. Else, it will ignore them.
	processClusterStore: bool | *true

	// -- Specifies whether an external secret operator deployment be created.
	createOperator: bool | *true

	// -- Specifies the number of concurrent ExternalSecret Reconciles external-secret executes at
	// a time.
	concurrent: uint | *1

	serviceAccount: #ServiceAccount

	rbac: {
		// -- Specifies whether role and rolebinding resources should be created.
		create: bool | *true
	}

	//# -- Extra environment variables to add to container.
	extraEnv: [...v1.#EnvVar]

	//# -- Map of extra arguments to pass to container.
	extraArgs: #ExtraArgs

	//# -- Extra volumes to pass to pod.
	extraVolumes: [...v1.#Volume]

	//# -- Extra volumes to mount to the container.
	extraVolumeMounts: [...v1.#VolumeMount]

	// -- Annotations to add to Deployment
	deploymentAnnotations: k8s.#Annotations

	// -- Annotations to add to Pod
	podAnnotations: k8s.#Annotations

	podLabels: k8s.#Labels

	podSecurityContext: v1.#PodSecurityContext
	// fsGroup: 2000

	securityContext: v1.#SecurityContext
	// capabilities:
	//   drop:
	//   - ALL
	// readOnlyRootFilesystem: true
	// runAsNonRoot: true
	// runAsUser: 1000

	resources: v1.#ResourceRequirements
	// requests:
	//   cpu: 10m
	//   memory: 32Mi

	prometheus: #Prometheus

	serviceMonitor: #ServiceMonitor
	metrics:        #Metrics

	nodeSelector: k8s.#Labels

	tolerations: [...v1.#Toleration]

	affinity: v1.#Affinity

	// -- Pod priority class name.
	priorityClassName: string | *""

	// -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
	podDisruptionBudget: #PodDisruptionBudget

	webhook: {
		// -- Specifies whether a webhook deployment be created.
		create: bool | *true
		// -- Specifices the time to check if the cert is valid
		certCheckInterval: string | *"5m"
		// -- Specifices the lookaheadInterval for certificate validity
		lookaheadInterval: string | *""
		replicaCount:      uint | *1
		certDir:           string | *"/tmp/certs"
		// -- specifies whether validating webhooks should be created with failurePolicy: Fail or Ignore
		failurePolicy: admv1.#enumFailurePolicyType | *"Fail"
		// -- Specifies if webhook pod should use hostNetwork or not.
		hostNetwork: bool | *false
		image:       #Image
		imagePullSecrets: [...v1.#LocalObjectReference]
		nameOverride:     string | *""
		fullnameOverride: string | *""
		// -- The port the webhook will listen to
		port: k8s.#Port | *10250
		rbac: {
			// -- Specifies whether role and rolebinding resources should be created.
			create: bool | *true
		}
		serviceAccount: #ServiceAccount
		nodeSelector:   k8s.#Labels

		tolerations: [...v1.#Toleration]

		affinity: v1.#Affinity

		// -- Pod priority class name.
		priorityClassName: string | *""

		// -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
		podDisruptionBudget: #PodDisruptionBudget
		prometheus:          #Prometheus

		serviceMonitor: #ServiceMonitor
		metrics:        #Metrics

		readinessProbe: {
			// -- Address for readiness probe
			address: string | *""
			// -- ReadinessProbe port for kubelet
			port: k8s.#Port | *8081
		}

		//# -- Extra environment variables to add to container.
		extraEnv: [...v1.#EnvVar]

		//# -- Map of extra arguments to pass to container.
		extraArgs: #ExtraArgs

		//# -- Extra volumes to pass to pod.
		extraVolumes: [...v1.#Volume]

		//# -- Extra volumes to mount to the container.
		extraVolumeMounts: [...v1.#VolumeMount]

		// -- Annotations to add to Secret
		secretAnnotations: k8s.#Annotations

		// -- Annotations to add to Deployment
		deploymentAnnotations: k8s.#Annotations

		// -- Annotations to add to Pod
		podAnnotations: k8s.#Annotations

		podLabels: k8s.#Labels

		podSecurityContext: v1.#PodSecurityContext
		// fsGroup: 2000

		securityContext: v1.#SecurityContext
		// capabilities:
		//   drop:
		//   - ALL
		// readOnlyRootFilesystem: true
		// runAsNonRoot: true
		// runAsUser: 1000

		resources: v1.#ResourceRequirements
	}
	// requests:
	//   cpu: 10m
	//   memory: 32Mi

	certController: {
		// -- Specifies whether a certificate controller deployment be created.
		create:          bool | *true
		requeueInterval: string | *"5m"
		replicaCount:    uint | *1
		image:           #Image
		imagePullSecrets: [...v1.#LocalObjectReference]
		nameOverride:     string | *""
		fullnameOverride: string | *""
		rbac: {
			// -- Specifies whether role and rolebinding resources should be created.
			create: bool | *true
		}
		serviceAccount: #ServiceAccount
		nodeSelector:   k8s.#Labels
		tolerations: [...v1.#Toleration]

		affinity: v1.#Affinity

		// -- Pod priority class name.
		priorityClassName: string | *""

		// -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
		podDisruptionBudget: #PodDisruptionBudget

		prometheus: #Prometheus

		serviceMonitor: #ServiceMonitor
		metrics:        #Metrics

		//# -- Extra environment variables to add to container.
		extraEnv: [...v1.#EnvVar]

		//# -- Map of extra arguments to pass to container.
		extraArgs: #ExtraArgs

		//# -- Extra volumes to pass to pod.
		extraVolumes: [...v1.#Volume]

		//# -- Extra volumes to mount to the container.
		extraVolumeMounts: [...v1.#VolumeMount]

		// -- Annotations to add to Deployment
		deploymentAnnotations: k8s.#Annotations

		// -- Annotations to add to Pod
		podAnnotations: k8s.#Annotations

		podLabels: k8s.#Labels

		podSecurityContext: v1.#PodSecurityContext
		// fsGroup: 2000

		securityContext: v1.#SecurityContext
		// capabilities:
		//   drop:
		//   - ALL
		// readOnlyRootFilesystem: true
		// runAsNonRoot: true
		// runAsUser: 1000

		resources: v1.#ResourceRequirements
	}
	// requests:
	//   cpu: 10m
	//   memory: 32Mi
	// -- Specifies `dnsOptions` to deployment
	dnsConfig: v1.#PodDNSConfig
}

#Image: {
	repository: string | *"ghcr.io/external-secrets/external-secrets"
	pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
	tag:        string | *""
}

#PodDisruptionBudget: {
	enabled:        bool | *false
	minAvailable:   uint | null | *1
	maxUnavailable: uint | *null
}

#ServiceMonitor: {
	// -- Specifies whether to create a ServiceMonitor resource for collecting Prometheus metrics
	enabled: bool | *false

	// -- Additional labels
	additionalLabels: k8s.#Labels

	// --  Interval to scrape metrics
	interval: string | *"30s"

	// -- Timeout if metrics can't be retrieved in given time interval
	scrapeTimeout: string | *"25s"
}

#Metrics: service: {
	// -- Enable if you use another monitoring tool than Prometheus to scrape the metrics
	enabled: bool | *false

	// -- Metrics service port to scrape
	port: k8s.#Port | *8080

	// -- Additional service annotations
	annotations: k8s.#Annotations
}

#Prometheus: {
	// -- deprecated. will be removed with 0.7.0, use serviceMonitor instead.
	enabled: bool | *false
	service: {
		// -- deprecated. will be removed with 0.7.0, use serviceMonitor instead.
		port: k8s.#Port | *8080
	}
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
	name: string | *""
}

#ExtraArgs: {
	[string]: string | null
}
