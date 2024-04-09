package eso

import (
	"stakpak.dev/devx/k8s"
	"k8s.io/api/core/v1"
	admv1 "k8s.io/api/admissionregistration/v1"
)

#KubeVersion: [=~"^0\\.9\\."]: minor: >=19
#Values: [=~"^0\\.9\\."]: {
	global: {
		nodeSelector: k8s.#Labels
		tolerations: [...v1.#Toleration]
		topologySpreadConstraints: [...]
		affinity: v1.#Affinity
	}
	replicaCount: uint | *1

	// -- Specifies the amount of historic ReplicaSets k8s should keep (see https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy)
	revisionHistoryLimit: uint | *10

	image: #Image

	// -- If set, install and upgrade CRDs through helm chart.
	installCRDs: bool | *true

	crds: {
		// -- If true, create CRDs for Cluster External Secret.
		createClusterExternalSecret: bool | *true
		// -- If true, create CRDs for Cluster Secret Store.
		createClusterSecretStore: bool | *true
		// -- If true, create CRDs for Push Secret.
		createPushSecret: bool | *true
		annotations:      k8s.#Annotations
		conversion: enabled: bool | *true
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

	// -- If true external secrets will use recommended kubernetes
	// annotations as prometheus metric labels.
	extendedMetricLabels: bool | *false

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

	// -- if true, the operator will process push secret. Else, it will ignore them.
	processPushSecret: bool | *true

	// -- Specifies whether an external secret operator deployment be created.
	createOperator: bool | *true

	// -- Specifies the number of concurrent ExternalSecret Reconciles external-secret executes at
	// a time.
	concurrent: uint | *1

	serviceAccount: #ServiceAccount

	rbac: {
		// -- Specifies whether role and rolebinding resources should be created.
		create: bool | *true
		servicebindings: {
			// -- Specifies whether a clusterrole to give servicebindings read access should be created.
			create: bool | *true
		}
	}

	//# -- Extra environment variables to add to container.
	extraEnv: [...v1.#EnvVar]

	//# -- Map of extra arguments to pass to container.
	extraArgs: #ExtraArgs

	//# -- Extra volumes to pass to pod.
	extraVolumes: [...v1.#Volume]

	//# -- Extra volumes to mount to the container.
	extraVolumeMounts: [...v1.#VolumeMount]

	//# -- Extra containers to add to the pod.
	extraContainers: [...]

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

	serviceMonitor: #ServiceMonitor
	metrics:        #Metrics

	nodeSelector: k8s.#Labels

	tolerations: [...v1.#Toleration]

	topologySpreadConstraints: [...v1.#TopologySpreadConstraint]

	affinity: v1.#Affinity

	// -- Pod priority class name.
	priorityClassName: string | *""

	// -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
	podDisruptionBudget: #PodDisruptionBudget

	// -- Run the controller on the host network
	hostNetwork: bool | *false

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

		certManager: {
			// -- Enabling cert-manager support will disable the built in secret and
			//  switch to using cert-manager (installed separately) to automatically issue
			//  and renew the webhook certificate. This chart does not install
			//  cert-manager for you, See https://cert-manager.io/docs/
			enabled: bool | *false
			//  -- Automatically add the cert-manager.io/inject-ca-from annotation to the
			//  webhooks and CRDs. As long as you have the cert-manager CA Injector
			//  enabled, this will automatically setup your webhook's CA to the one used
			//  by cert-manager. See https://cert-manager.io/docs/concepts/ca-injector
			addInjectorAnnotations: bool | *true
			cert: {
				//  -- Create a certificate resource within this chart. See
				//  https://cert-manager.io/docs/usage/certificate/
				create: bool | *true
				//  -- For the Certificate created by this chart, setup the issuer. See
				//  https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.IssuerSpec
				issuerRef: {
					group: string | *"cert-manager.io"
					kind:  string | *"Issuer"
					name:  string | *"my-issuer"
				}
				//  -- Set the requested duration (i.e. lifetime) of the Certificate. See
				//  https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec
				//  One year by default.
				duration: string | *"8760h"
				//  -- How long before the currently issued certificate’s expiry
				//  cert-manager should renew the certificate. See
				//  https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec
				//  Note that renewBefore should be greater than .webhook.lookaheadInterval
				//  since the webhook will check this far in advance that the certificate is
				//  valid.
				renewBefore: string | *""
				//  -- Add extra annotations to the Certificate resource.
				annotations: k8s.#Annotations
			}
		}

		tolerations: [...v1.#Toleration]

		affinity: v1.#Affinity

		// -- Pod priority class name.
		priorityClassName: string | *""

		// -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
		podDisruptionBudget: #PodDisruptionBudget
		prometheus:          #Prometheus

		metrics: #Metrics

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

		// -- Specifies the amount of historic ReplicaSets k8s should keep (see https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy)
		revisionHistoryLimit: 10
		image:                #Image
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

		topologySpreadConstraints: [...v1.#TopologySpreadConstraint]

		affinity: v1.#Affinity

		// -- Run the certController on the host network
		hostNetwork: bool | *false

		// -- Pod priority class name.
		priorityClassName: string | *""

		// -- Pod disruption budget - for more details see https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
		podDisruptionBudget: #PodDisruptionBudget

		metrics: #Metrics

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

	// -- Any extra pod spec on the deployment
	podSpecExtra: v1.#PodSpec | *{}
}

#Image: {
	repository: string | *"ghcr.io/external-secrets/external-secrets"
	pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
	tag:        string | *""
	flavour:    string | *""
}

#PodDisruptionBudget: {
	enabled:        bool | *false
	minAvailable:   uint | null | *1
	maxUnavailable: uint | *null
}

#ServiceMonitor: {
	// -- Specifies whether to create a ServiceMonitor resource for collecting Prometheus metrics
	enabled: bool | *false

	// -- namespace where you want to install ServiceMonitors
	namespace: string | *""

	// -- Additional labels
	additionalLabels: k8s.#Labels

	// --  Interval to scrape metrics
	interval: string | *"30s"

	// -- Timeout if metrics can't be retrieved in given time interval
	scrapeTimeout: string | *"25s"

	// -- Let prometheus add an exported_ prefix to conflicting labels
	honorLabels: bool | *false

	// -- Metric relabel configs to apply to samples before ingestion. [Metric Relabeling](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs)
	metricRelabelings: [...]

	// -- Relabel configs to apply to samples before ingestion. [Relabeling](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
	relabelings: [...v1.#RelabelConfig]
}

#Metrics: service: {
	listen: port: k8s.#Port | *8080
	service: {
		// -- Enable if you use another monitoring tool than Prometheus to scrape the metrics
		enabled: bool | *false

		// -- Metrics service port to scrape
		port: k8s.#Port | *8080

		// -- Additional service annotations
		annotations: k8s.#Annotations
	}
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
	// -- Automounts the service account token in all containers of the pod
	automount: bool | *true
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
