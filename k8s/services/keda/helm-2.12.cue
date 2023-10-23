package keda

import (
	"stakpak.dev/devx/k8s"
	"k8s.io/api/core/v1"
)

#KubeVersion: [=~"^2\\.12\\."]: minor: >=20

#Values: [=~"^2\\.12\\."]: {
	// # Default values for keda.
	// # This is a YAML-formatted file.
	// # Declare variables to be passed into your templates.
	image: {
		keda: {
			// # -- Image name of KEDA operator
			repository: string | *"ghcr.io/kedacore/keda"
			// # -- Image tag of KEDA operator. Optional, given app version of Helm chart is used by default
			tag: string | *""
		}
		metricsApiServer: {
			// # -- Image name of KEDA Metrics API Server
			repository: string | *"ghcr.io/kedacore/keda-metrics-apiserver"
			// # -- Image tag of KEDA Metrics API Server. Optional, given app version of Helm chart is used by default
			tag: string | *""
		}
		webhooks: {
			// # -- Image name of KEDA admission-webhooks
			repository: "ghcr.io/kedacore/keda-admission-webhooks"
			// # -- Image tag of KEDA admission-webhooks . Optional, given app version of Helm chart is used by default
			tag: string | *""
		}
		pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
	}
	// # -- Kubernetes cluster domain
	clusterDomain: string | *"cluster.local"
	crds: {
		//   # -- Defines whether the KEDA CRDs have to be installed or not.
		install: bool | *true
	}
	// # -- Defines Kubernetes namespaces to watch to scale their workloads. Default watches all namespaces
	watchNamespace: string | *""
	// # -- Name of secret to use to pull images to use to pull Docker images
	imagePullSecrets: [...v1.#LocalObjectReference]

	operator: {
		//   # -- Name of the KEDA operator
		name: string | *"keda-operator"
		//   # -- ReplicaSets for this Deployment you want to retain (Default: 10)
		revisionHistoryLimit: int | *10
		//   # -- Capability to configure the number of replicas for KEDA operator.
		//   # While you can run more replicas of our operator, only one operator instance will be the leader and serving traffic.
		//   # You can run multiple replicas, but they will not improve the performance of KEDA, it could only reduce downtime during a failover.
		//   # Learn more in [our documentation](https://keda.sh/docs/latest/operate/cluster/#high-availability).
		replicaCount: int | *1
		//   # -- [Affinity] for pod scheduling for KEDA operator. Takes precedence over the `affinity` field
		//     # podAntiAffinity:
		//     #   requiredDuringSchedulingIgnoredDuringExecution:
		//     #   - labelSelector:
		//     #       matchExpressions:
		//     #       - key: app
		//     #         operator: In
		//     #         values:
		//     #         - keda-operator
		//     #     topologyKey: "kubernetes.io/hostname"
		affinity: v1.#Affinity
		//   # -- Liveness probes for operator ([docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/))
		livenessProbe: v1.#Probe | *{
			initialDelaySeconds: int | *25
			periodSeconds:       int | *10
			timeoutSeconds:      int | *1
			failureThreshold:    int | *3
			successThreshold:    int | *1
		}
		//   # -- Readiness probes for operator ([docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes))
		readinessProbe: v1.#Probe | *{
			initialDelaySeconds: int | *20
			periodSeconds:       int | *3
			timeoutSeconds:      int | *1
			failureThreshold:    int | *3
			successThreshold:    int | *1
		}
	}

	metricsServer: {
		//   # -- ReplicaSets for this Deployment you want to retain (Default: 10)
		revisionHistoryLimit: int | *10
		//   # -- Capability to configure the number of replicas for KEDA metric server.
		//   # While you can run more replicas of our metric server, only one instance will used and serve traffic.
		//   # You can run multiple replicas, but they will not improve the performance of KEDA, it could only reduce downtime during a failover.
		//   # Learn more in [our documentation](https://keda.sh/docs/latest/operate/cluster/#high-availability).
		replicaCount: int | *1
		//   # use ClusterFirstWithHostNet if `useHostNetwork: true` https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy
		//   # -- Defined the DNS policy for the metric server
		dnsPolicy: v1.#enumDNSPolicy | *"ClusterFirst"
		//   # -- Enable metric server to use host network
		useHostNetwork: bool | *false
		//   # -- [Affinity] for pod scheduling for Metrics API Server. Takes precedence over the `affinity` field
		//     # podAntiAffinity:
		//     #   requiredDuringSchedulingIgnoredDuringExecution:
		//     #   - labelSelector:
		//     #       matchExpressions:
		//     #       - key: app
		//     #         operator: In
		//     #         values:
		//     #         - keda-operator-metrics-apiserver
		//     #     topologyKey: "kubernetes.io/hostname"
		affinity: v1.#Affinity
		//   # -- Liveness probes for Metrics API Server ([docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/))
		livenessProbe: v1.#Probe | *{
			initialDelaySeconds: int | *5
			periodSeconds:       int | *10
			timeoutSeconds:      int | *1
			failureThreshold:    int | *3
			successThreshold:    int | *1
		}
		//   # -- Readiness probes for Metrics API Server ([docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes))
		readinessProbe: v1.#Probe | *{
			initialDelaySeconds: int | *5
			periodSeconds:       int | *3
			timeoutSeconds:      int | *1
			failureThreshold:    int | *3
			successThreshold:    int | *1
		}
	}

	webhooks: {
		//   # -- Name of the KEDA admission webhooks
		name: string | *"keda-admission-webhooks"
		//   # -- Enable admission webhooks (this feature option will be removed in v2.12)
		enabled: bool | *true
		//   # -- Port number to use for KEDA admission webhooks. Default is 9443.
		port: int | *9443
		//   # -- Port number to use for KEDA admission webhooks health probe
		healthProbePort: int | *8081
		//   # -- Liveness probes for admission webhooks ([docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/))
		livenessProbe: v1.#Probe | *{
			initialDelaySeconds: int | *25
			periodSeconds:       int | *10
			timeoutSeconds:      int | *1
			failureThreshold:    int | *3
			successThreshold:    int | *1
		}
		//   # -- Readiness probes for admission webhooks ([docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-readiness-probes))
		readinessProbe: v1.#Probe | *{
			initialDelaySeconds: int | *20
			periodSeconds:       int | *3
			timeoutSeconds:      int | *1
			failureThreshold:    int | *3
			successThreshold:    int | *1
		}
		//   # -- Enable webhook to use host network, this is required on EKS with custom CNI
		useHostNetwork: bool | *false
		//   # -- ReplicaSets for this Deployment you want to retain (Default: 10)
		revisionHistoryLimit: int | *10
		//   # -- Capability to configure the number of replicas for KEDA admission webhooks
		replicaCount: int | *1
		//   # -- [Affinity] for pod scheduling for KEDA admission webhooks. Takes precedence over the `affinity` field
		//     # podAntiAffinity:
		//     #   requiredDuringSchedulingIgnoredDuringExecution:
		//     #   - labelSelector:
		//     #       matchExpressions:
		//     #       - key: app
		//     #         operator: In
		//     #         values:
		//     #         - keda-operator
		//     #     topologyKey: "kubernetes.io/hostname"
		affinity: v1.#Affinity
		//   # -- [Failure policy](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#failure-policy) to use with KEDA admission webhooks
		failurePolicy: v1.#enumFailurePolicy | *"Ignore"
	}

	updateStrategy: {
		//   # -- Capability to configure [Deployment upgrade strategy] for operator
		operator: v1.#DeploymentStrategy
		//   # -- Capability to configure [Deployment upgrade strategy] for Metrics Api Server
		metricsApiServer: v1.#DeploymentStrategy
		//   # -- Capability to configure [Deployment upgrade strategy] for Admission webhooks
		webhooks: v1.#DeploymentStrategy
	}

	podDisruptionBudget: {
		//   # -- Capability to configure [Pod Disruption Budget]
		operator: v1.#PodDisruptionBudgetSpec
		//   # -- Capability to configure [Pod Disruption Budget]
		metricServer: v1.#PodDisruptionBudgetSpec
		//   # -- Capability to configure [Pod Disruption Budget]
		webhooks: v1.#PodDisruptionBudgetSpec
	}

	additionalLabels:      k8s.#Labels
	additionalAnnotations: k8s.#Annotations
	podAnnotations: {
		//   # -- Pod annotations for KEDA operator
		keda: k8s.#Annotations
		//   # -- Pod annotations for KEDA Metrics Adapter
		metricsAdapter: k8s.#Annotations
		//   # -- Pod annotations for KEDA Admission webhooks
		webhooks: k8s.#Annotations
	}
	podLabels: {
		//   # -- Pod labels for KEDA operator
		keda: k8s.#Labels
		//   # -- Pod labels for KEDA Metrics Adapter
		metricsAdapter: k8s.#Labels
		//   # -- Pod labels for KEDA Admission webhooks
		webhooks: k8s.#Labels
	}

	rbac: {
		//   # -- Specifies whether RBAC should be used
		create: bool | *true
		//   # -- Specifies whether RBAC for CRDs should be [aggregated](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles) to default roles (view, edit, admin)
		aggregateToDefaultRoles: bool | *false
	}

	serviceAccount: {
		//   # -- Specifies whether a service account should be created
		create: bool | *true
		//   # -- The name of the service account to use.
		//   # If not set and create is true, a name is generated using the fullname template
		name: string | *"keda-operator"
		//   # -- Specifies whether a service account should automount API-Credentials
		automountServiceAccountToken: bool | *true
		//   # -- Annotations to add to the service account
		annotations: k8s.#Annotations
	}

	podIdentity: {
		activeDirectory: {
			// # Set to the value of the Azure Active Directory Pod Identity
			// # See https://keda.sh/docs/concepts/authentication/#azure-pod-identity
			// # This will be set as a label on the KEDA Pod(s)
			// # -- Identity in Azure Active Directory to use for Azure pod identity
			identity: string | *""
		}
		azureWorkload: {
			//     # -- Set to true to enable Azure Workload Identity usage.
			//     # See https://keda.sh/docs/concepts/authentication/#azure-workload-identity
			//     # This will be set as a label on the KEDA service account.
			enabled: bool | *false
			//     # Set to the value of the Azure Active Directory Client and Tenant Ids
			//     # respectively. These will be set as annotations on the KEDA service account.
			//     # -- Id of Azure Active Directory Client to use for authentication with Azure Workload Identity. ([docs](https://keda.sh/docs/concepts/authentication/#azure-workload-identity))
			clientId: string | *""
			//     # -- Id Azure Active Directory Tenant to use for authentication with for Azure Workload Identity. ([docs](https://keda.sh/docs/concepts/authentication/#azure-workload-identity))
			tenantId: string | *""
			//     # Set to the value of the service account token expiration duration.
			//     # This will be set as an annotation on the KEDA service account.
			//     # -- Duration in seconds to automatically expire tokens for the service account. ([docs](https://keda.sh/docs/concepts/authentication/#azure-workload-identity))
			tokenExpiration: int | *3600
		}
		aws: {
			irsa: {
				//       # -- Specifies whether [AWS IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) is to be enabled or not.
				enabled: bool | *false
				//       # -- Sets the token audience for IRSA.
				//       # This will be set as an annotation on the KEDA service account.
				audience: string | *"sts.amazonaws.com"
				//       # -- Set to the value of the ARN of an IAM role with a web identity provider.
				//       # This will be set as an annotation on the KEDA service account.
				roleArn: string | *""
				//       # -- Sets the use of an STS regional endpoint instead of global.
				//       # Recommended to use regional endpoint in almost all cases.
				//       # This will be set as an annotation on the KEDA service account.
				stsRegionalEndpoints: bool | *true
				//       # -- Set to the value of the service account token expiration duration.
				//       # This will be set as an annotation on the KEDA service account.
				tokenExpiration: int | *3600
			}
		}
		gcp: {
			//     # -- Set to true to enable GCP Workload Identity.
			//     # See https://keda.sh/docs/2.10/authentication-providers/gcp-workload-identity/
			//     # This will be set as a annotation on the KEDA service account.
			enabled: bool | *false
			//     # -- GCP IAM Service Account Email which you would like to use for workload identity.
			gcpIAMServiceAccount: string | *""
		}
	}
	grpcTLSCertsSecret: string | *""
	hashiCorpVaultTLS:  string | *""

	logging: {
		operator: {
			// # -- Logging level for KEDA Operator.
			// # allowed values: `debug`, `info`, `error`, or an integer value greater than 0, specified as string
			level: "debug" | "error" | *"info" | string
			// # -- Logging format for KEDA Operator.
			// # allowed values: `json` or `console`
			format: "json" | *"console"
			// # -- Logging time encoding for KEDA Operator.
			// # allowed values are `epoch`, `millis`, `nano`, `iso8601`, `rfc3339` or `rfc3339nano`
			timeEncoding: "epoch" | "millis" | "nano" | "iso8601" | "rfc3339nano" | *"rfc3339"
		}
		metricServer: {
			// # -- Logging level for Metrics Server.
			// # allowed values: `0` for info, `4` for debug, or an integer value greater than 0, specified as string
			level: *"0" | "4"
		}
		webhooks: {
			// # -- Logging level for KEDA Operator.
			// # allowed values: `debug`, `info`, `error`, or an integer value greater than 0, specified as string
			level: "debug" | "error" | *"info" | string
			// # -- Logging format for KEDA Admission webhooks.
			// # allowed values: `json` or `console`
			format: "json" | *"console"
			// # -- Logging time encoding for KEDA Operator.
			// # allowed values are `epoch`, `millis`, `nano`, `iso8601`, `rfc3339` or `rfc3339nano`
			timeEncoding: "epoch" | "millis" | "nano" | "iso8601" | "rfc3339nano" | *"rfc3339"
		}
	}

	// # -- [Security context] for all containers
	// # @default -- [See below](#KEDA-is-secure-by-default)
	securityContext: {
		//   # -- [Security context] of the operator container
		//   # @default -- [See below](#KEDA-is-secure-by-default)
		operator: {
			capabilities: {
				drop: [...v1.#Capability] | *["ALL"]
			}
			allowPrivilegeEscalation: bool | *false
			readOnlyRootFilesystem:   bool | *true
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
		}
		//   # -- [Security context] of the metricServer container
		//   # @default -- [See below](#KEDA-is-secure-by-default)
		metricServer: {
			capabilities: {
				drop: [...v1.#Capability] | *["ALL"]
			}
			allowPrivilegeEscalation: bool | *false
			readOnlyRootFilesystem:   bool | *true
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
		}
		//   # -- [Security context] of the admission webhooks container
		//   # @default -- [See below](#KEDA-is-secure-by-default)
		webhooks: {
			capabilities: {
				drop: [...v1.#Capability] | *["ALL"]
			}
			allowPrivilegeEscalation: bool | *false
			readOnlyRootFilesystem:   bool | *true
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
		}
	}

	// # --  [Pod security context] for all pods
	// # @default -- [See below](#KEDA-is-secure-by-default)
	podSecurityContext: {
		//   # -- [Pod security context] of the KEDA operator pod
		//   # @default -- [See below](#KEDA-is-secure-by-default)
		operator: {
			runAsNonRoot: bool | *true
			//     # runAsUser: 1000
			//     # runAsGroup: 1000
			//     # fsGroup: 1000
		}
		//   # -- [Pod security context] of the KEDA metrics apiserver pod
		//   # @default -- [See below](#KEDA-is-secure-by-default)
		metricServer: {
			runAsNonRoot: bool | *true
			//     # runAsUser: 1000
			//     # runAsGroup: 1000
			//     # fsGroup: 1000
		}
		//   # -- [Pod security context] of the KEDA admission webhooks
		//   # @default -- [See below](#KEDA-is-secure-by-default)
		webhooks: {
			runAsNonRoot: true
			//     # runAsUser: 1000
			//     # runAsGroup: 1000
			//     # fsGroup: 1000
		}
	}

	serivce: {
		// # -- KEDA Metric Server service type
		type: v1.#enumServiceType | *"ClusterIP"
		// # -- HTTPS port for KEDA Metric Server service
		portHttps: int | *443
		// # -- HTTPS port for KEDA Metric Server container
		portHttpsTarget: int | *6443
		// # -- Annotations to add the KEDA Metric Server service
		annotations: k8s.#Annotations
	}

	// # We provides the default values that we describe in our docs:
	// # https://keda.sh/docs/latest/operate/cluster/
	// # If you want to specify the resources (or totally remove the defaults), change or comment the following
	// # lines, adjust them as necessary, or simply add the curly braces after 'operator' and/or 'metricServer'
	// # and remove/comment the default values
	resources: {
		//   # -- Manage [resource request & limits] of KEDA operator pod
		operator: {
			limits: {
				cpu:    string | *"1"
				memory: string | *"1000Mi"
			}
			requests: {
				cpu:    string | *"100m"
				memory: string | *"100Mi"
			}
		}
		//   # -- Manage [resource request & limits] of KEDA metrics apiserver pod
		metricServer: {
			limits: {
				cpu:    string | *"1"
				memory: string | *"1000Mi"
			}
			requests: {
				cpu:    string | *"100m"
				memory: string | *"100Mi"
			}
		}
		//   # -- Manage [resource request & limits] of KEDA admission webhooks pod
		webhooks: {
			limits: {
				cpu:    string | *"50m"
				memory: string | *"100Mi"
			}
			requests: {
				cpu:    string | *"10m"
				memory: string | *"10Mi"
			}
		}
	}

	// # -- Node selector for pod scheduling ([docs](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/))
	nodeSelector: k8s.#Labels
	// # -- Tolerations for pod scheduling ([docs](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/))
	tolerations: [...v1.#Toleration]

	topologySpreadConstraints: {
		// # -- [Pod Topology Constraints] of KEDA operator pod
		operator: [...v1.#TopologySpreadConstraint]
		// # -- [Pod Topology Constraints] of KEDA metrics apiserver pod
		metricsServer: [...v1.#TopologySpreadConstraint]
		// # -- [Pod Topology Constraints] of KEDA admission webhooks pod
		webhooks: [...v1.#TopologySpreadConstraint]
	}

	affinity: v1.#Affinity

	// # -- priorityClassName for all KEDA components
	priorityClassName: string | *""

	// ## The default HTTP timeout in milliseconds that KEDA should use
	// ## when making requests to external services. Removing this defaults to a
	// ## reasonable default
	http: {
		//   # -- The default HTTP timeout to use for all scalers that use raw HTTP clients (some scalers use SDKs to access target services. These have built-in HTTP clients, and the timeout does not necessarily apply to them)
		timeout: int | *3000
		keepAlive: {
			//     # -- Enable HTTP connection keep alive
			enabled: bool | *true
		}
		//   # -- The minimum TLS version to use for all scalers that use raw HTTP clients (some scalers use SDKs to access target services. These have built-in HTTP clients, and this value does not necessarily apply to them)
		minTlsVersion: string | *"TLS12"
	}

	// ## Extra KEDA Operator and Metrics Adapter container arguments
	extraArgs: {
		//   # -- Additional KEDA Operator container arguments
		keda: [string]: string | *{}
		//   # -- Additional Metrics Adapter container arguments
		metricsAdapter: [string]: string | *{}
	}

	// # -- Additional environment variables that will be passed onto all KEDA components
	env: [...v1.#EnvVar]

	// # Extra volumes and volume mounts for the deployment. Optional.
	volumes: {
		keda: {
			//     # -- Extra volumes for KEDA deployment
			extraVolumes: [...v1.#Volume]
			//     # -- Extra volume mounts for KEDA deployment
			extraVolumeMounts: [...v1.#VolumeMount]
		}
		metricsApiServer: {
			//     # -- Extra volumes for metric server deployment
			extraVolumes: [...v1.#Volume]
			//     # -- Extra volume mounts for metric server deployment
			extraVolumeMounts: [...v1.#VolumeMount]
		}
		webhooks: {
			//     # -- Extra volumes for admission webhooks deployment
			extraVolumes: [...v1.#Volume]
			//     # -- Extra volume mounts for admission webhooks deployment
			extraVolumeMounts: [...v1.#VolumeMount]
		}
	}

	prometheus: {
		metricServer: {
			//     # -- Enable metric server Prometheus metrics expose
			enabled: bool | *false
			//     # -- HTTP port used for exposing metrics server prometheus metrics
			port: k8s.#Port | *8080
			//     # -- HTTP port name for exposing metrics server prometheus metrics
			portName: string | *"metrics"
			serviceMonitor: {
				//       # -- Enables ServiceMonitor creation for the Prometheus Operator
				enabled: bool | *false
				//       # -- JobLabel selects the label from the associated Kubernetes service which will be used as the job label for all metrics. [ServiceMonitor Spec]
				jobLabel: string | *""
				//       # -- TargetLabels transfers labels from the Kubernetes `Service` onto the created metrics
				targetLabels: [...string] | *[]
				//       # -- PodTargetLabels transfers labels on the Kubernetes `Pod` onto the created metrics
				podTargetLabels: [...string] | *[]
				//       # -- Name of the service port this endpoint refers to. Mutually exclusive with targetPort
				port: "metrics"
				//       # -- Name or number of the target port of the Pod behind the Service, the port must be specified with container port property. Mutually exclusive with port
				targetPort: k8s.#Port | *""
				//       # -- Interval at which metrics should be scraped If not specified Prometheus’ global scrape interval is used.
				interval: string | *""
				//       # -- Timeout after which the scrape is ended If not specified, the Prometheus global scrape timeout is used unless it is less than Interval in which the latter is used
				scrapeTimeout: string | *""
				//       # -- DEPRECATED. List of expressions that define custom relabeling rules for metric server ServiceMonitor crd (prometheus operator). [RelabelConfig Spec]
				relabellings: []
				//       # -- List of expressions that define custom relabeling rules for metric server ServiceMonitor crd (prometheus operator). [RelabelConfig Spec]
				relabelings: []
				//       # --  Additional labels to add for metric server using ServiceMonitor crd (prometheus operator)
				additionalLabels: k8s.#Labels
			}
			podMonitor: {
				//       # -- Enables PodMonitor creation for the Prometheus Operator
				enabled: bool | *false
				//       # -- Scraping interval for metric server using podMonitor crd (prometheus operator)
				interval: string | *""
				//       # -- Scraping timeout for metric server using podMonitor crd (prometheus operator)
				scrapeTimeout: string | *""
				//       # -- Scraping namespace for metric server using podMonitor crd (prometheus operator)
				namespace: string | *""
				//       # -- Additional labels to add for metric server using podMonitor crd (prometheus operator)
				additionalLabels: k8s.#Labels
				//       # -- List of expressions that define custom relabeling rules for metric server podMonitor crd (prometheus operator)
				relabelings: []
			}
		}
		operator: {
			//     # -- Enable KEDA Operator prometheus metrics expose
			enabled: bool | *false
			//     # -- Port used for exposing KEDA Operator prometheus metrics
			port: k8s.#Port | *8080

			serviceMonitor: {
				//       # -- Enables ServiceMonitor creation for the Prometheus Operator
				enabled: bool | *false
				//       # -- JobLabel selects the label from the associated Kubernetes service which will be used as the job label for all metrics. [ServiceMonitor Spec]
				jobLabel: string | *""
				//       # -- TargetLabels transfers labels from the Kubernetes `Service` onto the created metrics
				targetLabels: [...string] | *[]
				//       # -- PodTargetLabels transfers labels on the Kubernetes `Pod` onto the created metrics
				podTargetLabels: [...string] | *[]
				//       # -- Name of the service port this endpoint refers to. Mutually exclusive with targetPort
				port: "metrics"
				//       # -- Name or number of the target port of the Pod behind the Service,
				//       # the port must be specified with container port property. Mutually exclusive with port
				targetPort: string | *""
				//       # -- Interval at which metrics should be scraped If not specified Prometheus’ global scrape interval is used.
				interval: string | *""
				//       # -- Timeout after which the scrape is ended If not specified, the Prometheus global scrape timeout is used unless it is less than Interval in which the latter is used
				scrapeTimeout: string | *""
				//       # -- DEPRECATED. List of expressions that define custom relabeling rules for metric server ServiceMonitor crd (prometheus operator). [RelabelConfig Spec]
				relabellings: []
				//       # -- List of expressions that define custom relabeling rules for metric server ServiceMonitor crd (prometheus operator). [RelabelConfig Spec]
				relabelings: []
				//       # -- Additional labels to add for metric server using ServiceMonitor crd (prometheus operator)
				additionalLabels: k8s.#Labels
			}
			podMonitor: {
				//       # -- Enables PodMonitor creation for the Prometheus Operator
				enabled: bool | *false
				//       # -- Scraping interval for KEDA Operator using podMonitor crd (prometheus operator)
				interval: string | *""
				//       # -- Scraping timeout for KEDA Operator using podMonitor crd (prometheus operator)
				scrapeTimeout: string | *""
				//       # -- Scraping namespace for KEDA Operator using podMonitor crd (prometheus operator)
				namespace: string | *""
				//       # -- Additional labels to add for KEDA Operator using podMonitor crd (prometheus operator)
				additionalLabels: k8s.#Labels
				//       # --  List of expressions that define custom relabeling rules for KEDA Operator podMonitor crd (prometheus operator)
				relabelings: []
			}
			prometheusRules: {
				//       # -- Enables PrometheusRules creation for the Prometheus Operator
				enabled: bool | *false
				//       # -- Scraping namespace for KEDA Operator using prometheusRules crd (prometheus operator)
				namespace: string | *""
				//       # -- Additional labels to add for KEDA Operator using prometheusRules crd (prometheus operator)
				additionalLabels: k8s.#Labels
				//       # -- Additional alerts to add for KEDA Operator using prometheusRules crd (prometheus operator)
				alerts: *[] | [
					//         # - alert: KedaScalerErrors
					//         #   annotations:
					//         #     description: Keda scaledObject {{ $labels.scaledObject }} is experiencing errors with {{ $labels.scaler }} scaler
					//         #     summary: Keda Scaler {{ $labels.scaler }} Errors
					//         #   expr: sum by ( scaledObject , scaler) (rate(keda_metrics_adapter_scaler_errors[2m]))  > 0
					//         #   for: 2m
					//         #   labels:
					{
						alert:       string | *"KedaScalerErrors"
						annotations: k8s.#Annotations
						expr:        string | *"sum by ( scaledObject , scaler) (rate(keda_metrics_adapter_scaler_errors[2m]))  > 0"
						for:         string | *"2m"
						labels:      k8s.#Labels
					},
				]
			}
		}
		webhooks: {
			//     # -- Enable KEDA admission webhooks prometheus metrics expose
			enabled: bool | *false
			//     # -- Port used for exposing KEDA admission webhooks prometheus metrics
			port: k8s.#Port | *8080
			//     # -- HTTP port name for exposing KEDA admission webhooks prometheus metrics
			serviceMonitor: {
				//       # -- Enables ServiceMonitor creation for the Prometheus webhooks
				enabled: bool | *false
				//       # -- jobLabel selects the label from the associated Kubernetes service which will be used as the job label for all metrics. [ServiceMonitor Spec]
				jobLabel: string | *""
				//       # -- TargetLabels transfers labels from the Kubernetes `Service` onto the created metrics
				targetLabels: [...string] | *[]
				//       # -- PodTargetLabels transfers labels on the Kubernetes `Pod` onto the created metrics
				podTargetLabels: [...string] | *[]
				//       # -- Name of the service port this endpoint refers to. Mutually exclusive with targetPort
				port: "metrics"
				//       # -- Name or number of the target port of the Pod behind the Service, the port must be specified with container port property. Mutually exclusive with port
				targetPort: k8s.#Port | *""
				//       # -- Interval at which metrics should be scraped If not specified Prometheus’ global scrape interval is used.
				interval: string | *""
				//       # -- Timeout after which the scrape is ended If not specified, the Prometheus global scrape timeout is used unless it is less than Interval in which the latter is used
				scrapeTimeout: string | *""
				//       # -- DEPRECATED. List of expressions that define custom relabeling rules for metric server ServiceMonitor crd (prometheus operator). [RelabelConfig Spec]
				relabellings: []
				//       # -- List of expressions that define custom relabeling rules for metric server ServiceMonitor crd (prometheus operator). [RelabelConfig Spec]
				relabelings: []
				//       # -- Additional labels to add for metric server using ServiceMonitor crd (prometheus operator)
				additionalLabels: k8s.#Labels
			}
			prometheusRules: {
				//       # -- Enables PrometheusRules creation for the Prometheus Operator
				enabled: bool | *false
				//       # -- Scraping namespace for KEDA Operator using prometheusRules crd (prometheus operator)
				namespace: string | *""
				//       # -- Additional labels to add for KEDA Operator using prometheusRules crd (prometheus operator)
				additionalLabels: k8s.#Labels
				//       # -- Additional alerts to add for KEDA Operator using prometheusRules crd (prometheus operator)
				alerts: *[] | [
					//         # - alert: KedaScalerErrors
					//         #   annotations:
					//         #     description: Keda scaledObject {{ $labels.scaledObject }} is experiencing errors with {{ $labels.scaler }} scaler
					//         #     summary: Keda Scaler {{ $labels.scaler }} Errors
					//         #   expr: sum by ( scaledObject , scaler) (rate(keda_metrics_adapter_scaler_errors[2m]))  > 0
					//         #   for: 2m
					//         #   labels:
					{
						alert:       string | *"KedaScalerErrors"
						annotations: k8s.#Annotations
						expr:        string | *"sum by ( scaledObject , scaler) (rate(keda_metrics_adapter_scaler_errors[2m]))  > 0"
						for:         string | *"2m"
						labels:      k8s.#Labels
					},
				]
			}
		}
	}

	opentelemetry: {
		collector: {
			// # -- Uri of OpenTelemetry Collector to push telemetry to
			uri: string | *""
		}
		operator: {
			// # -- Enable pushing metrics to an OpenTelemetry Collector for operator
			enabled: bool | *false
		}
	}

	certificates: {
		//   # -- Enables the self generation for KEDA TLS certificates inside KEDA operator
		autoGenerated: bool | *true
		//   # -- Secret name to be mounted with KEDA TLS certificates
		secretName: string | *"kedaorg-certs"
		//   # -- Path where KEDA TLS certificates are mounted
		mountPath: string | *"/certs"
		certManager: {
			//     # -- Enables Cert-manager for certificate management
			enabled: bool | *false
			//     # -- Generates a self-signed CA with Cert-manager.
			//     # If generateCA is false, the secret with the CA
			//     # has to be annotated with `cert-manager.io/allow-direct-injection: "true"`
			generateCA: bool | *true
			//     # -- Secret name where the CA is stored (generatedby cert-manager or user given)
			caSecretName: string | *"kedaorg-ca"
			//     # -- Add labels/annotations to secrets created by Certificate resources
			//     # [docs](https://cert-manager.io/docs/usage/certificate/#creating-certificate-resources)
			secretTemplate: {
				annotations: k8s.#Annotations
				labels:      k8s.#Labels
			}
		}
	}

	permissions: {
		metricServer: {
			restrict: {
				// -- Restrict Secret Access for Metrics Server
				secret: bool | *false
			}
		}
		operator: {
			restrict: {
				// -- Restrict Secret Access for KEDA operator
				secret: bool | *false
			}
		}
	}

    // # -- Array of extra K8s manifests to deploy
    extraObjects: [...]

    // # -- Capability to turn on/off ASCII art in Helm installation notes
    asciiArt: bool | *true
}
