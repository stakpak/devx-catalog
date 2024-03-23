package simplemongodb

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^14\\.13\\."]: minor: >=23

#Values: [=~"^14\\.13\\."]: {
	// ## @section Global parameters
	// ## Global Docker image parameters
	// ## Please, note that this will override the image parameters, including dependencies, configured to use the global value
	// ## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass
	// ##

	// ## @param global.imageRegistry Global Docker image registry
	// ## @param global.imagePullSecrets Global Docker registry secret names as an array
	// ## @param global.storageClass Global StorageClass for Persistent Volume(s)
	// ## @param global.namespaceOverride Override the namespace for resource deployed by the chart, but can itself be overridden by the local namespaceOverride

	global: {
		imageRegistry: string | *""
		//   ## E.g.
		//   ## imagePullSecrets:
		//   ##   - myRegistryKeySecretName
		//   ##
		imagePullSecrets: [...v1.#LocalObjectReference]
		storageClass:      string | *""
		namespaceOverride: string | *""
		//   compatibility:
		//     ## Compatibility adaptations for Openshift
		//     ##
		//     openshift:
		//       ## @param global.compatibility.openshift.adaptSecurityContext Adapt the securityContext sections of the deployment to make them compatible with Openshift restricted-v2 SCC: remove runAsUser, runAsGroup and fsGroup and let the platform use their allowed default IDs. Possible values: auto (apply if the detected running cluster is Openshift), force (perform the adaptation always), disabled (do not perform adaptation)
		//       ##
		//       adaptSecurityContext: disabled
		compatibility: {...}
	}
	// ## @section Common parameters
	// ##
	// ## @param nameOverride String to partially override mongodb.fullname template (will maintain the release name)
	// ##
	nameOverride: string | *""
	// ## @param fullnameOverride String to fully override mongodb.fullname template
	// ##
	fullnameOverride: string | *""
	// ## @param namespaceOverride String to fully override common.names.namespace
	// ##
	namespaceOverride: string | *""
	// ## @param kubeVersion Force target Kubernetes version (using Helm capabilities if not set)
	// ##
	kubeVersion: string | *""
	// ## @param clusterDomain Default Kubernetes cluster domain
	// ##
	clusterDomain: string | *"cluster.local"
	// ## @param extraDeploy Array of extra objects to deploy with the release
	// ## extraDeploy:
	// ## This needs to be uncommented and added to 'extraDeploy' in order to use the replicaset 'mongo-labeler' sidecar
	// ## for dynamically discovering the mongodb primary pod
	// ## suggestion is to use a hard-coded and predictable TCP port for the primary mongodb pod (here is 30001, choose your own)
	// ## - apiVersion: v1
	// ##   kind: Service
	// ##   metadata:
	// ##     name: mongodb-primary
	// ##     namespace: the-mongodb-namespace
	// ##     labels:
	// ##       app.kubernetes.io/component: mongodb
	// ##       app.kubernetes.io/instance: mongodb
	// ##       app.kubernetes.io/managed-by: Helm
	// ##       app.kubernetes.io/name: mongodb
	// ##   spec:
	// ##     type: NodePort
	// ##     externalTrafficPolicy: Cluster
	// ##     ports:
	// ##       - name: mongodb
	// ##         port: 30001
	// ##         nodePort: 30001
	// ##         protocol: TCP
	// ##         targetPort: mongodb
	// ##     selector:
	// ##       app.kubernetes.io/component: mongodb
	// ##       app.kubernetes.io/instance: mongodb
	// ##       app.kubernetes.io/name: mongodb
	// ##       primary: "true"
	// ##
	extraDeploy: [...k8s.#Object]
	// ## @param commonLabels Add labels to all the deployed resources (sub-charts are not considered). Evaluated as a template
	// ##
	commonLabels: k8s.#Labels
	// ## @param commonAnnotations Common annotations to add to all Mongo resources (sub-charts are not considered). Evaluated as a template
	// ##
	commonAnnotations: k8s.#Annotations
	// ## @param topologyKey Override common lib default topology key. If empty - "kubernetes.io/hostname" is used
	// ## i.e. topologyKey: topology.kubernetes.io/zone
	// ##
	topologyKey: string | *""
	// ## @param serviceBindings.enabled Create secret for service binding (Experimental)
	// ## Ref: https://servicebinding.io/service-provider/
	// ##
	serviceBindings: {
		enabled: bool | *false
	}
	// ## @param enableServiceLinks Whether information about services should be injected into pod's environment variable
	// ## The environment variables injected by service links are not used, but can lead to slow boot times or slow running of the scripts when there are many services in the current namespace.
	// ## If you experience slow pod startups or slow running of the scripts you probably want to set this to `false`.
	// ##
	enableServiceLinks: bool | *true
	// ## Enable diagnostic mode in the deployment
	// ##
	diagnosticMode: {
		//   ## @param diagnosticMode.enabled Enable diagnostic mode (all probes will be disabled and the command will be overridden)
		//   ##
		enabled: bool | *false
		//   ## @param diagnosticMode.command Command to override all containers in the deployment
		//   ##
		command: [...string]
		//   ## @param diagnosticMode.args Args to override all containers in the deployment
		//   ##
		args: [...string]
	}
	// ## @section MongoDB(&reg;) parameters
	// ##

	// ## Bitnami MongoDB(&reg;) image
	// ## ref: https://hub.docker.com/r/bitnami/mongodb/tags/
	// ## @param image.registry [default: REGISTRY_NAME] MongoDB(&reg;) image registry
	// ## @param image.repository [default: REPOSITORY_NAME/mongodb] MongoDB(&reg;) image registry
	// ## @skip image.tag MongoDB(&reg;) image tag (immutable tags are recommended)
	// ## @param image.digest MongoDB(&reg;) image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
	// ## @param image.pullPolicy MongoDB(&reg;) image pull policy
	// ## @param image.pullSecrets Specify docker-registry secret names as an array
	// ## @param image.debug Set to true if you would like to see extra information on logs

	image: {
		registry:   string | *"docker.io"
		repository: string | *"bitnami/mongodb"
		tag:        string | *"7.0.6-debian-12-r0"
		digest:     string | *""
		//   ## Specify a imagePullPolicy
		//   ## ref: https://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images
		pullPolicy: string | *"IfNotPresent"
		//   ## Optionally specify an array of imagePullSecrets.
		//   ## Secrets must be manually created in the namespace.
		//   ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
		//   ## pullSecrets:
		//   ##   - myRegistryKeySecretName
		pullSecrets: [...string]
		//   ## Set to true if you would like to see extra information on logs
		//   ##
		debug: bool | *false
	}
	// ## @param schedulerName Name of the scheduler (other than default) to dispatch pods
	// ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
	schedulerName: string | *""
	// ## @param architecture MongoDB(&reg;) architecture (`standalone` or `replicaset`)
	architecture: *"replicaset" | "standalone"
	// ## @param useStatefulSet Set to true to use a StatefulSet instead of a Deployment (only when `architecture=standalone`)
	useStatefulSet: bool | *false

	// 	## @param replicaCount Number of MongoDB(&reg;) nodes
	// ## When `mongodb.architecture=replicaset`, the number of replicas is taken in account
	// ## When `mongodb.architecture=standalone`, the number of replicas can only be 0 or 1 (value higher then 1 will not be taken in account)
	// ##
	replicaCount: int | *2

	// ## MongoDB(&reg;) Authentication parameters
	auth: {
		//   ## @param auth.enabled Enable authentication
		//   ## ref: https://docs.mongodb.com/manual/tutorial/enable-authentication/
		enabled: bool | *true
		//   ## @param auth.rootUser MongoDB(&reg;) root user
		rootUser: string | *"root"
		//   ## @param auth.rootPassword MongoDB(&reg;) root password
		//   ## ref: https://github.com/bitnami/containers/tree/main/bitnami/mongodb#setting-the-root-user-and-password-on-first-run
		rootPassword: string | *""
		//   ## MongoDB(&reg;) custom users and databases
		//   ## ref: https://github.com/bitnami/containers/tree/main/bitnami/mongodb#creating-a-user-and-database-on-first-run
		//   ## @param auth.usernames List of custom users to be created during the initialization
		//   ## @param auth.passwords List of passwords for the custom users set at `auth.usernames`
		//   ## @param auth.databases List of custom databases to be created during the initialization
		usernames: [...string]
		passwords: [...string]
		databases: [...string]
		//   ## @param auth.username DEPRECATED: use `auth.usernames` instead
		//   ## @param auth.password DEPRECATED: use `auth.passwords` instead
		//   ## @param auth.database DEPRECATED: use `auth.databases` instead
		//   ##
		username: string | *""
		password: string | *""
		database: string | *""
		//   ## @param auth.replicaSetKey Key used for authentication in the replicaset (only when `architecture=replicaset`)
		replicaSetKey: string | *""
		//   ## @param auth.existingSecret Existing secret with MongoDB(&reg;) credentials (keys: `mongodb-passwords`, `mongodb-root-password`, `mongodb-metrics-password`, `mongodb-replica-set-key`)
		//   ## NOTE: When it's set the previous parameters are ignored.
		existingSecret: string | *""
	}
	tls: {
		//   ## @param tls.enabled Enable MongoDB(&reg;) TLS support between nodes in the cluster as well as between mongo clients and nodes
		enabled: bool | *false
		//   ## @param tls.mTLS.enabled IF TLS support is enabled, require clients to provide certificates
		mTLS: {
			enabled: bool | *false
		}
		//   ## @param tls.autoGenerated Generate a custom CA and self-signed certificates
		autoGenerated: bool | *true
		//   ## @param tls.existingSecret Existing secret with TLS certificates (keys: `mongodb-ca-cert`, `mongodb-ca-key`)
		//   ## NOTE: When it's set it will disable secret creation.
		existingSecret: string | *""
		//   ## Add Custom CA certificate
		//   ## @param tls.caCert Custom CA certificated (base64 encoded)
		//   ## @param tls.caKey CA certificate private key (base64 encoded)
		caCert: string | *""
		caKey:  string | *""
		//   ## @param tls.pemChainIncluded Flag to denote that the Certificate Authority (CA) certificates are bundled with the endpoint cert.
		//   ## Certificates must be in proper order, where the top certificate is the leaf and the bottom certificate is the top-most intermediate CA.
		pemChainIncluded: bool | *false
		standalone: {
			//     ## @param tls.standalone.existingSecret Existing secret with TLS certificates (`tls.key`, `tls.crt`, `ca.crt`) or (`tls.key`, `tls.crt`) with tls.pemChainIncluded set as enabled.
			//     ## NOTE: When it's set it will disable certificate self-generation from existing CA.
			existingSecret: string | *""
		}
		replicaset: {
			//     ## @param tls.replicaset.existingSecrets Array of existing secrets with TLS certificates (`tls.key`, `tls.crt`, `ca.crt`) or (`tls.key`, `tls.crt`) with tls.pemChainIncluded set as enabled.
			//     ## existingSecrets:
			//     ##  - "mySecret-0"
			//     ##  - "mySecret-1"
			//     ## NOTE: When it's set it will disable certificate self-generation from existing CA.
			existingSecrets: [...string]
		}
		hidden: {
			//     ## @param tls.hidden.existingSecrets Array of existing secrets with TLS certificates (`tls.key`, `tls.crt`, `ca.crt`) or (`tls.key`, `tls.crt`) with tls.pemChainIncluded set as enabled.
			//     ## existingSecrets:
			//     ##  - "mySecret-0"
			//     ##  - "mySecret-1"
			//     ## NOTE: When it's set it will disable certificate self-generation from existing CA.
			existingSecrets: [...string]
		}
		arbiter: {
			//     ## @param tls.arbiter.existingSecret Existing secret with TLS certificates (`tls.key`, `tls.crt`, `ca.crt`) or (`tls.key`, `tls.crt`) with tls.pemChainIncluded set as enabled.
			//     ## NOTE: When it's set it will disable certificate self-generation from existing CA.
			existingSecret: string | *""
		}
		//   ## Bitnami Nginx image
		//   ## @param tls.image.registry [default: REGISTRY_NAME] Init container TLS certs setup image registry
		//   ## @param tls.image.repository [default: REPOSITORY_NAME/nginx] Init container TLS certs setup image repository
		//   ## @skip tls.image.tag Init container TLS certs setup image tag (immutable tags are recommended)
		//   ## @param tls.image.digest Init container TLS certs setup image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
		//   ## @param tls.image.pullPolicy Init container TLS certs setup image pull policy
		//   ## @param tls.image.pullSecrets Init container TLS certs specify docker-registry secret names as an array
		//   ## @param tls.extraDnsNames Add extra dns names to the CA, can solve x509 auth issue for pod clients
		image: {
			registry:   string | *"docker.io"
			repository: string | *"bitnami/nginx"
			tag:        string | *"1.25.4-debian-12-r2"
			digest:     string | *""
			pullPolicy: string | *"IfNotPresent"
			pullSecrets: [...string]
		}
		extraDnsNames: [...string]
		//   ## @param tls.mode Allows to set the tls mode which should be used when tls is enabled (options: `allowTLS`, `preferTLS`, `requireTLS`)
		mode: "allowTLS" | "preferTLS" | *"requireTLS"
		//   ## Init Container resource requests and limits
		//   ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
		//   ## We usually recommend not to specify default resources and to leave this as a conscious
		//   ## choice for the user. This also increases chances charts run on environments with little
		//   ## resources, such as Minikube. If you do want to specify resources, uncomment the following
		//   ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
		//   ## @param tls.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if tls.resources is set (tls.resources is recommended for production).
		//   ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
		resourcesPreset: #ResourcePresent
		//   ## @param tls.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
		resources: v1.#ResourceRequirements
		//   ## Init Container securityContext 
		//   ## ref: https://kubernetes.io/docs/concepts/security/pod-security-policy/
		//   ## @param tls.securityContext Init container generate-tls-cert Security context
		securityContext: v1.#SecurityContext
	}
	// ## @param automountServiceAccountToken Mount Service Account token in pod
	automountServiceAccountToken: bool | *false
	// ## @param hostAliases Add deployment host aliases
	// ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
	hostAliases: [...v1.#HostAlias]
	// ## @param replicaSetName Name of the replica set (only when `architecture=replicaset`)
	// ## Ignored when mongodb.architecture=standalone
	replicaSetName: string | *"rs0"
	// ## @param replicaSetHostnames Enable DNS hostnames in the replicaset config (only when `architecture=replicaset`)
	// ## Ignored when mongodb.architecture=standalone
	// ## Ignored when externalAccess.enabled=true
	replicaSetHostnames: bool | *true
	// ## @param enableIPv6 Switch to enable/disable IPv6 on MongoDB(&reg;)
	// ## ref: https://github.com/bitnami/containers/tree/main/bitnami/mongodb#enablingdisabling-ipv6
	enableIPv6: bool | *false
	// ## @param directoryPerDB Switch to enable/disable DirectoryPerDB on MongoDB(&reg;)
	// ## ref: https://github.com/bitnami/containers/tree/main/bitnami/mongodb#enablingdisabling-directoryperdb
	directoryPerDB: bool | *false
	// ## MongoDB(&reg;) System Log configuration
	// ## ref: https://github.com/bitnami/containers/tree/main/bitnami/mongodb#configuring-system-log-verbosity-level
	// ## @param systemLogVerbosity MongoDB(&reg;) system log verbosity level
	// ## @param disableSystemLog Switch to enable/disable MongoDB(&reg;) system log
	systemLogVerbosity: int | *0
	disableSystemLog:   bool | *false
	// ## @param disableJavascript Switch to enable/disable MongoDB(&reg;) server-side JavaScript execution
	// ## ref: https://docs.mongodb.com/manual/core/server-side-javascript/
	disableJavascript: bool | *false
	// ## @param enableJournal Switch to enable/disable MongoDB(&reg;) Journaling
	// ## ref: https://docs.mongodb.com/manual/reference/configuration-options/#mongodb-setting-storage.journal.enabled
	enableJournal: bool | *true
	// ## @param configuration MongoDB(&reg;) configuration file to be used for Primary and Secondary nodes
	// ## For documentation of all options, see: http://docs.mongodb.org/manual/reference/configuration-options/
	// ## Example:
	// ## configuration: |-
	// ##   # where and how to store data.
	// ##   storage:
	// ##     dbPath: /bitnami/mongodb/data/db
	// ##     journal:
	// ##       enabled: true
	// ##     directoryPerDB: false
	// ##   # where to write logging data
	// ##   systemLog:
	// ##     destination: file
	// ##     quiet: false
	// ##     logAppend: true
	// ##     logRotate: reopen
	// ##     path: /opt/bitnami/mongodb/logs/mongodb.log
	// ##     verbosity: 0
	// ##   # network interfaces
	// ##   net:
	// ##     port: 27017
	// ##     unixDomainSocket:
	// ##       enabled: true
	// ##       pathPrefix: /opt/bitnami/mongodb/tmp
	// ##     ipv6: false
	// ##     bindIpAll: true
	// ##   # replica set options
	// ##   #replication:
	// ##     #replSetName: replicaset
	// ##     #enableMajorityReadConcern: true
	// ##   # process management options
	// ##   processManagement:
	// ##      fork: false
	// ##      pidFilePath: /opt/bitnami/mongodb/tmp/mongodb.pid
	// ##   # set parameter options
	// ##   setParameter:
	// ##      enableLocalhostAuthBypass: true
	// ##   # security options
	// ##   security:
	// ##     authorization: disabled
	// ##     #keyFile: /opt/bitnami/mongodb/conf/keyfile
	// ##
	configuration: string | *""

	// ## @section replicaSetConfigurationSettings settings applied during runtime (not via configuration file)
	// ## If enabled, these are applied by a script which is called within setup.sh
	// ## for documentation see https://docs.mongodb.com/manual/reference/replica-configuration/#replica-set-configuration-fields
	// ## @param replicaSetConfigurationSettings.enabled Enable MongoDB(&reg;) Switch to enable/disable configuring MongoDB(&reg;) run time rs.conf settings
	// ## @param replicaSetConfigurationSettings.configuration run-time rs.conf settings
	replicaSetConfigurationSettings: {
		enabled: bool | *false
		configuration: {...}
	}

	arbiter: {
		//   ## @param arbiter.enabled Enable deploying the arbiter
		//   ##   https://docs.mongodb.com/manual/tutorial/add-replica-set-arbiter/
		enable: bool | *false
		//   ## @param arbiter.automountServiceAccountToken Mount Service Account token in pod
		//   ##
		automountServiceAccountToken: bool | *false
		//   ## @param arbiter.hostAliases Add deployment host aliases
		//   ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
		hostAliases: [...v1.#HostAlias]
		//   ## @param arbiter.configuration Arbiter configuration file to be used
		//   ##   http://docs.mongodb.org/manual/reference/configuration-options/
		configuration:     string | *""
		existingConfigmap: string | *""
		command: [...string]
		args: [...string]
		extraFlags: [...string]
		extraEnvVars: [{...}]
		extraEnvVarsCM:     string | *""
		extraEnvVarsSecret: string | *""
		annotations:        k8s.#Annotations
		labels:             k8s.#Labels
		topologySpreadConstraints: [...v1.#TopologySpreadConstraint]
		lifecycleHooks: {...}
		terminationGracePeriodSeconds: string | *""
		updateStrategy: {
			type: string | *"RollingUpdate"
			rollingUpdate: {
				maxSurge:       string | *"25%"
				maxUnavailable: string | *"25%"
			}
		}
		podManagementPolicy:   string | *"OrderedReady"
		schedulerName:         string | *""
		podAffinityPreset:     string | *""
		podAntiAffinityPreset: string | *"soft"
		nodeAffinityPreset:    v1.#Affinity
		affinity:              v1.#Affinity
		nodeSelector:          k8s.#Labels
		tolerations: [...v1.#Toleration]
		podLabels:                k8s.#Labels
		podAnnotations:           k8s.#Annotations
		priorityClassName:        string | *""
		runtimeClassName:         string | *""
		podSecurityContext:       v1.#PodSecurityContext
		containerSecurityContext: v1.#SecurityContext
		resourcesPreset:          #ResourcePresent
		resources:                v1.#ResourceRequirements
		containerPorts: {
			mongodb: k8s.#Port | *27017
		}
		livenessProbe: v1.#Probe | *{
			enabled:             true
			initialDelaySeconds: 30
			periodSeconds:       20
			timeoutSeconds:      10
			failureThreshold:    6
			successThreshold:    1
		}
		readinessProbe: v1.#Probe | *{
			enabled:             true
			initialDelaySeconds: 5
			periodSeconds:       20
			timeoutSeconds:      10
			failureThreshold:    6
			successThreshold:    1
		}
		startupProbe: v1.#Probe | *{
			enabled:             false
			initialDelaySeconds: 5
			periodSeconds:       10
			timeoutSeconds:      5
			successThreshold:    1
			failureThreshold:    30
		}
		customLivenessProbe: v1.#Probe | *{}
		customReadinessProbe: v1.#Probe | *{}
		customStartupProbe: v1.#Probe | *{}
		initContainers: [...v1.#Container]
		sidecars: [...v1.#Container]
		extraVolumeMounts: [...v1.#VolumeMount]
		extraVolumes: [...v1.#Volume]
		pdb: {
			create:         bool | *false
			minAvailable:   string | *""
			maxUnavailable: string | *""
		}
		service: {
			nameOverride: string | *""
			ports: {
				mongodb: int | *27017
			}
			extraPorts: [...k8s.#Port]
			annotations: k8s.#Annotations
			headless: {
				annotations: k8s.#Annotations
			}
		}
	}
	externalAccess: {
		//   ## @param externalAccess.enabled Enable Kubernetes external cluster access to MongoDB(&reg;) nodes (only for replicaset architecture)
		enabled: bool | *false
		//   ## External IPs auto-discovery configuration
		//   ## An init container is used to auto-detect LB IPs or node ports by querying the K8s API
		//   ## Note: RBAC might be required
		autoDiscovery: {
			//     ## @param externalAccess.autoDiscovery.enabled Enable using an init container to auto-detect external IPs by querying the K8s API
			enabled: bool | *false
			//     ## Bitnami Kubectl image
			//     ## ref: https://hub.docker.com/r/bitnami/kubectl/tags/
			//     ## @param externalAccess.autoDiscovery.image.registry [default: REGISTRY_NAME] Init container auto-discovery image registry
			//     ## @param externalAccess.autoDiscovery.image.repository [default: REPOSITORY_NAME/kubectl] Init container auto-discovery image repository
			//     ## @skip externalAccess.autoDiscovery.image.tag Init container auto-discovery image tag (immutable tags are recommended)
			//     ## @param externalAccess.autoDiscovery.image.digest Init container auto-discovery image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
			//     ## @param externalAccess.autoDiscovery.image.pullPolicy Init container auto-discovery image pull policy
			//     ## @param externalAccess.autoDiscovery.image.pullSecrets Init container auto-discovery image pull secrets
			image: {
				registry:   string | *"docker.io"
				repository: string | *"bitnami/kubectl"
				tag:        string | *"1.29.3-debian-12-r0"
				digest:     string | *""
				//       ## Specify a imagePullPolicy
				//       ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
				//       ## ref: https://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images
				pullPolicy: string | *"IfNotPresent"
				//       ## Optionally specify an array of imagePullSecrets (secrets must be manually created in the namespace)
				//       ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
				//       ## Example:
				//       ## pullSecrets:
				//       ##   - myRegistryKeySecretName
				pullSecrets: [...string]
			}
			//     ## Init Container resource requests and limits
			//     ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
			//     ## We usually recommend not to specify default resources and to leave this as a conscious
			//     ## choice for the user. This also increases chances charts run on environments with little
			//     ## resources, such as Minikube. If you do want to specify resources, uncomment the following
			//     ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
			//     ## @param externalAccess.autoDiscovery.resourcesPreset Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if externalAccess.autoDiscovery.resources is set (externalAccess.autoDiscovery.resources is recommended for production).
			//     ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
			resourcesPreset: #ResourcePresent
			//     ## @param externalAccess.autoDiscovery.resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
			//     ## Example:
			//     ## resources:
			//     ##   requests:
			//     ##     cpu: 2
			//     ##     memory: 512Mi
			//     ##   limits:
			//     ##     cpu: 3
			//     ##     memory: 1024Mi
			//     ##
			resources: v1.#ResourceRequirements
			//   ## Parameters to configure a set of Pods that connect to an existing MongoDB(&reg;) deployment that lies outside of Kubernetes.
			//   ## @param externalAccess.externalMaster.enabled Use external master for bootstrapping
			//   ## @param externalAccess.externalMaster.host External master host to bootstrap from
			//   ## @param externalAccess.externalMaster.port Port for MongoDB(&reg;) service external master host
			externalMaster: {
				enabled: bool | *false
				host:    string | *""
				port:    k8s.#Port | *27017
			}
			//   ## Parameters to configure K8s service(s) used to externally access MongoDB(&reg;)
			//   ## A new service per broker will be created
			service: {
				//     ## @param externalAccess.service.type Kubernetes Service type for external access. Allowed values: NodePort, LoadBalancer or ClusterIP
				type: *"LoadBalancer" | "NodePort" | "ClusterIP"
				//     ## @param externalAccess.service.portName MongoDB(&reg;) port name used for external access when service type is LoadBalancer
				portName: string | *"mongodb"
				//     ## @param externalAccess.service.ports.mongodb MongoDB(&reg;) port used for external access when service type is LoadBalancer
				ports: {
					mongodb: k8s.#Port | *27017
				}
				//     ## @param externalAccess.service.loadBalancerIPs Array of load balancer IPs for MongoDB(&reg;) nodes
				loadbalancerIPs: [...string]
				//     ## @param externalAccess.service.loadBalancerClass loadBalancerClass when service type is LoadBalancer
				//     # ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-class
				loadBalancerClass: string | *""
				//     ## @param externalAccess.service.loadBalancerSourceRanges Address(es) that are allowed when service is LoadBalancer
				//     ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
				loadBalancerSourceRanges: [...string]
				//     ## @param externalAccess.service.allocateLoadBalancerNodePorts Wheter to allocate node ports when service type is LoadBalancer
				//     ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-nodeport-allocation
				allocateLoadBalancerNodePorts: bool | *true
				//     ## @param externalAccess.service.externalTrafficPolicy MongoDB(&reg;) service external traffic policy
				//     ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
				externalTrafficPolicy: string | *"Local"
				//     ## @param externalAccess.service.nodePorts Array of node ports used to configure MongoDB(&reg;) advertised hostname when service type is NodePort
				//     ## Example:
				//     ## nodePorts:
				//     ##   - 30001
				//     ##   - 30002
				nodePorts: [...k8s.#Port]
				//     ## @param externalAccess.service.domain Domain or external IP used to configure MongoDB(&reg;) advertised hostname when service type is NodePort
				//     ## If not specified, the container will try to get the kubernetes node external IP
				//     ## e.g:
				//     ## domain: mydomain.com
				domain: string | *""
				//     ## @param externalAccess.service.extraPorts Extra ports to expose (normally used with the `sidecar` value)
				extraPorts: [...k8s.#Port]
				//     ## @param externalAccess.service.annotations Service annotations for external access
				annotations: k8s.#Annotations
				//     ## @param externalAccess.service.sessionAffinity Control where client requests go, to the same pod or round-robin
				//     ## Values: ClientIP or None
				//     ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
				sessionAffinity: "ClientIP" | *"None"
				//     ## @param externalAccess.service.sessionAffinityConfig Additional settings for the sessionAffinity
				//     ## sessionAffinityConfig:
				//     ##   clientIP:
				//     ##     timeoutSeconds: 300
				sessionAffinityConfig: {...}
			}
			hidden: {
				//     ## @param externalAccess.hidden.enabled Enable Kubernetes external cluster access to MongoDB(&reg;) hidden nodes
				enabled: bool | *false
				//     ## Parameters to configure K8s service(s) used to externally access MongoDB(&reg;)
				//     ## A new service per broker will be created
				service: {
					//     ## @param externalAccess.service.type Kubernetes Service type for external access. Allowed values: NodePort, LoadBalancer or ClusterIP
					type: *"LoadBalancer" | "NodePort" | "ClusterIP"
					//     ## @param externalAccess.service.portName MongoDB(&reg;) port name used for external access when service type is LoadBalancer
					portName: string | *"mongodb"
					//     ## @param externalAccess.service.ports.mongodb MongoDB(&reg;) port used for external access when service type is LoadBalancer
					ports: {
						mongodb: k8s.#Port | *27017
					}
					//     ## @param externalAccess.service.loadBalancerIPs Array of load balancer IPs for MongoDB(&reg;) nodes
					loadbalancerIPs: [...string]
					//     ## @param externalAccess.service.loadBalancerClass loadBalancerClass when service type is LoadBalancer
					//     # ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-class
					loadBalancerClass: string | *""
					//     ## @param externalAccess.service.loadBalancerSourceRanges Address(es) that are allowed when service is LoadBalancer
					//     ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
					loadBalancerSourceRanges: [...string]
					//     ## @param externalAccess.service.allocateLoadBalancerNodePorts Wheter to allocate node ports when service type is LoadBalancer
					//     ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-nodeport-allocation
					allocateLoadBalancerNodePorts: bool | *true
					//     ## @param externalAccess.service.externalTrafficPolicy MongoDB(&reg;) service external traffic policy
					//     ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
					externalTrafficPolicy: string | *"Local"
					//     ## @param externalAccess.service.nodePorts Array of node ports used to configure MongoDB(&reg;) advertised hostname when service type is NodePort
					//     ## Example:
					//     ## nodePorts:
					//     ##   - 30001
					//     ##   - 30002
					nodePorts: [...k8s.#Port]
					//     ## @param externalAccess.service.domain Domain or external IP used to configure MongoDB(&reg;) advertised hostname when service type is NodePort
					//     ## If not specified, the container will try to get the kubernetes node external IP
					//     ## e.g:
					//     ## domain: mydomain.com
					domain: string | *""
					//     ## @param externalAccess.service.extraPorts Extra ports to expose (normally used with the `sidecar` value)
					extraPorts: [...k8s.#Port]
					//     ## @param externalAccess.service.annotations Service annotations for external access
					annotations: k8s.#Annotations
					//     ## @param externalAccess.service.sessionAffinity Control where client requests go, to the same pod or round-robin
					//     ## Values: ClientIP or None
					//     ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
					sessionAffinity: "ClientIP" | *"None"
					//     ## @param externalAccess.service.sessionAffinityConfig Additional settings for the sessionAffinity
					//     ## sessionAffinityConfig:
					//     ##   clientIP:
					//     ##     timeoutSeconds: 300
					sessionAffinityConfig: {...}
				}
			}
		}

	}
	...
}

#ResourcePresent: *"none" | "small" | "medium" | "large" | "xlarge" | "2xlarge"
