package keycloak

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^18\\.7\\."]: minor: >=21

#Values: [=~"^18\\.7\\."]: {

	// 	## @section Global parameters
	// ## Global Docker image parameters
	// ## Please, note that this will override the image parameters, including dependencies, configured to use the global value
	// ## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass
	// ##

	// ## @param global.imageRegistry Global Docker image registry
	// ## @param global.imagePullSecrets Global Docker registry secret names as an array
	// ## @param global.storageClass Global StorageClass for Persistent Volume(s)
	// ##
	global: {
		imageRegistry: string | *""
		//   ## E.g.
		//   ## imagePullSecrets:
		//   ##   - myRegistryKeySecretName
		//   ##
		imagePullSecrets: [...v1.#LocalObjectReference]
		storageClass: string | *""
	}

	// 	## @section Common parameters
	// ##

	// ## @param kubeVersion Force target Kubernetes version (using Helm capabilities if not set)
	// ##
	kubeVersion: string | *""
	// ## @param nameOverride String to partially override common.names.fullname
	// ##
	nameOverride: string | *""
	// ## @param fullnameOverride String to fully override common.names.fullname
	// ##
	fullnameOverride: string | *""
	// ## @param namespaceOverride String to fully override common.names.namespace
	// ##
	namespaceOverride: string | *""
	// ## @param commonLabels Labels to add to all deployed objects
	// ##
	commonLabels: k8s.#Labels
	// ## @param enableServiceLinks If set to false, disable Kubernetes service links in the pod spec
	// ## Ref: https://kubernetes.io/docs/tutorials/services/connect-applications-service/#accessing-the-service
	// ##
	enableServiceLinks: bool | *true
	// ## @param commonAnnotations Annotations to add to all deployed objects
	// ##
	commonAnnotations: k8s.#Annotations
	// ## @param dnsPolicy DNS Policy for pod
	// ## ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
	// ## E.g.
	// ## dnsPolicy: ClusterFirst
	dnsPolicy: string | *""
	// ## @param dnsConfig DNS Configuration pod
	// ## ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
	// ## E.g.
	// ## dnsConfig:
	// ##   options:
	// ##   - name: ndots
	// ##     value: "4"
	dnsConfig: v1.#PodDNSConfig | *{}
	// ## @param clusterDomain Default Kubernetes cluster domain
	// ##
	clusterDomain: string | *"cluster.local"
	// ## @param extraDeploy Array of extra objects to deploy with the release
	// ##
	extraDeploy: [...]
	// ## Enable diagnostic mode in the statefulset
	// ##
	diagnosticMode: {
		//   ## Enable diagnostic mode (all probes will be disabled and the command will be overridden)
		//   ##
		enabled: bool | *false
		//   ## Command to override all containers in the the statefulset
		//   ##
		command: [...string] | *["sleep"]
		//   ## Args to override all containers in the the statefulset
		//   ##
		args: [...string] | *["infinity"]
	}

	// 	## @section Keycloak parameters

	// ## Bitnami Keycloak image version
	// ## ref: https://hub.docker.com/r/bitnami/keycloak/tags/
	// ## @param image.registry [default: REGISTRY_NAME] Keycloak image registry
	// ## @param image.repository [default: REPOSITORY_NAME/keycloak] Keycloak image repository
	// ## @skip image.tag Keycloak image tag (immutable tags are recommended)
	// ## @param image.digest Keycloak image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
	// ## @param image.pullPolicy Keycloak image pull policy
	// ## @param image.pullSecrets Specify docker-registry secret names as an array
	// ## @param image.debug Specify if debug logs should be enabled
	// ##

	image: {
		registry:   string | *"docker.io"
		repository: string | *"bitnami/keycloak"
		tag:        string | *"23.0.7-debian-12-r0"
		digest:     string | *""
		// 		  ## Specify a imagePullPolicy
		//   ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
		//   ## ref: https://kubernetes.io/docs/concepts/containers/images/#pre-pulled-images
		//   ##
		pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
		// 		  ## Optionally specify an array of imagePullSecrets.
		//   ## Secrets must be manually created in the namespace.
		//   ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
		//   ## Example:
		//   ## pullSecrets:
		//   ##   - myRegistryKeySecretName
		//   ##
		pullSecrets: [...v1.#LocalObjectReference]
		// 		  ## Set to true if you would like to see extra information on logs
		//   ##
		debug: bool | *false
	}

	// 	## Keycloak authentication parameters
	// ## ref: https://github.com/bitnami/containers/tree/main/bitnami/keycloak#admin-credentials
	// ##
	auth: {
		// ## Keycloak administrator user
		// ##
		adminUser: string | *"admin"
		// ## Keycloak administrator password for the new user
		// ##
		adminPassword: string | *""
		// ## Existing secret containing Keycloak admin password
		// ##
		existingSecret: string | *""
		// ## Key where the Keycloak admin password is being stored inside the existing secret.
		// ##
		passwordSecretKey: string | *""
		// ## Additional custom annotations for Keycloak auth secret object
		// ##
		annotations: k8s.#Annotations
	}

	// 	## HTTPS settings
	// ## ref: https://github.com/bitnami/containers/tree/main/bitnami/keycloak#tls-encryption
	// ##
	tls: {
		//   ## @param tls.enabled Enable TLS encryption. Required for HTTPs traffic.
		//   ##
		enabled: bool | *false
		//   ## @param tls.autoGenerated Generate automatically self-signed TLS certificates. Currently only supports PEM certificates
		//   ##
		autoGenerated: bool | *false
		//   ## @param tls.existingSecret Existing secret containing the TLS certificates per Keycloak replica
		//   ## Create this secret following the steps below:
		//   ## 1) Generate your truststore and keystore files (more info at https://www.keycloak.org/docs/latest/server_installation/#_setting_up_ssl)
		//   ## 2) Rename your truststore to `keycloak.truststore.jks` or use a different name overwriting the value 'tls.truststoreFilename'.
		//   ## 3) Rename your keystores to `keycloak.keystore.jks` or use a different name overwriting the value 'tls.keystoreFilename'.
		//   ## 4) Run the command below where SECRET_NAME is the name of the secret you want to create:
		//   ##       kubectl create secret generic SECRET_NAME --from-file=./keycloak.truststore.jks --from-file=./keycloak.keystore.jks
		//   ## NOTE: If usePem enabled, make sure the PEM key and cert are named 'tls.key' and 'tls.crt' respectively.
		//   ##
		existingSecret: string | *""
		//   ## @param tls.usePem Use PEM certificates as input instead of PKS12/JKS stores
		//   ## If "true", the Keycloak chart will look for the files keycloak.key and keycloak.crt inside the secret provided with 'existingSecret'.
		//   ##
		usePem: bool | *false
		//   ## @param tls.truststoreFilename Truststore filename inside the existing secret
		//   ##
		truststoreFilename: string | *"keycloak.truststore.jks"
		//   ## @param tls.keystoreFilename Keystore filename inside the existing secret
		//   ##
		keystoreFilename: string | *"keycloak.keystore.jks"
		//   ## @param tls.keystorePassword Password to access the keystore when it's password-protected
		//   ##
		keystorePassword: string | *""
		//   ## @param tls.truststorePassword Password to access the truststore when it's password-protected
		//   ##
		truststorePassword: string | *""
		//   ## @param tls.passwordsSecret Secret containing the Keystore and Truststore passwords.
		//   ##
		passwordsSecret: string | *""
	}
	// 	## SPI TLS settings
	// ## ref: https://www.keycloak.org/server/keycloak-truststore
	// ##
	spi: {
		//   ## @param spi.existingSecret Existing secret containing the Keycloak truststore for SPI connection over HTTPS/TLS
		//   ## Create this secret following the steps below:
		//   ## 1) Rename your truststore to `keycloak-spi.truststore.jks` or use a different name overwriting the value 'spi.truststoreFilename'.
		//   ## 2) Run the command below where SECRET_NAME is the name of the secret you want to create:
		//   ##       kubectl create secret generic SECRET_NAME --from-file=./keycloak-spi.truststore.jks --from-file=./keycloak.keystore.jks
		//   ##
		existingSecret: string | *""
		//   ## @param spi.truststorePassword Password to access the truststore when it's password-protected
		//   ##
		truststorePassword: string | *""
		//   ## @param spi.truststoreFilename Truststore filename inside the existing secret
		//   ##
		truststoreFilename: string | *"keycloak-spi.truststore.jks"
		//   ## @param spi.passwordsSecret Secret containing the SPI Truststore passwords.
		//   ##
		passwordsSecret: string | *""
		//   ## @param spi.hostnameVerificationPolicy Verify the hostname of the server’s certificate. Allowed values: "ANY", "WILDCARD", "STRICT".
		//   ##
		hostnameVerificationPolicy: string | *""
	}

	// 	## @param production Run Keycloak in production mode. TLS configuration is required except when using proxy=edge.
	// ##
	production: bool | *true
	// ## @param proxy reverse Proxy mode edge, reencrypt, passthrough or none
	// ## ref: https://www.keycloak.org/server/reverseproxy
	// ##
	proxy: "passthrough" | *"edge" | "reencrypt" | "none"
	// ## @param httpRelativePath Set the path relative to '/' for serving resources. Useful if you are migrating from older version which were using '/auth/'
	// ## ref: https://www.keycloak.org/migration/migrating-to-quarkus#_default_context_path_changed
	// ##
	httpRelativePath: string | *"/"

	// 	## Keycloak Service Discovery settings
	// ## ref: https://github.com/bitnami/containers/tree/main/bitnami/keycloak#cluster-configuration
	// ##
	// ## @param configuration Keycloak Configuration. Auto-generated based on other parameters when not specified
	// ## Specify content for keycloak.conf
	// ## NOTE: This will override configuring Keycloak based on environment variables (including those set by the chart)
	// ## The keycloak.conf is auto-generated based on other parameters when this parameter is not specified
	// ##
	// ## Example:
	// ## configuration: |-
	// ##    foo: bar
	// ##    baz:
	// ##
	configuration: string | *""

	// 	## @param existingConfigmap Name of existing ConfigMap with Keycloak configuration
	// ## NOTE: When it's set the configuration parameter is ignored
	// ##
	existingConfigmap: string | *""

	// 	## @param extraStartupArgs Extra default startup args
	// ##
	extraStartupArgs: string | *""

	// ## @param initdbScripts Dictionary of initdb scripts
	// ## Specify dictionary of scripts to be run at first boot
	// ## ref: https://github.com/bitnami/containers/tree/main/bitnami/keycloak#initializing-a-new-instance
	// ## Example:
	// ## initdbScripts:
	// ##   my_init_script.sh: |
	// ##      #!/bin/bash
	// ##      echo "Do something."
	// ##
	initdbScripts: {...} | *{}

	// ## @param initdbScriptsConfigMap ConfigMap with the initdb scripts (Note: Overrides `initdbScripts`)
	// ##
	initdbScriptsConfigMap: string | *""

	// ## @param command Override default container command (useful when using custom images)
	// ##
	command: [...string]

	// ## @param args Override default container args (useful when using custom images)
	// ##
	args: [...string]

	// ## @param extraEnvVars Extra environment variables to be set on Keycloak container
	// ## Example:
	// ## extraEnvVars:
	// ##   - name: FOO
	// ##     value: "bar"
	// ##
	extraEnvVars: [...v1.#EnvVar]

	// 	## @param extraEnvVarsCM Name of existing ConfigMap containing extra env vars
	// ##
	extraEnvVarsCM: string | *""
	// ## @param extraEnvVarsSecret Name of existing Secret containing extra env vars
	// ##
	extraEnvVarsSecret: string | *""

	// 	## @param replicaCount Number of Keycloak replicas to deploy
	// ##
	replicaCount: uint | *1
	// ## @param revisionHistoryLimitCount Number of controller revisions to keep
	// ##
	revisionHistoryLimitCount: uint | *10
	// ## @param containerPorts.http Keycloak HTTP container port
	// ## @param containerPorts.https Keycloak HTTPS container port
	// ## @param containerPorts.infinispan Keycloak infinispan container port
	// ##
	containerPorts: {
		http:       uint | *8080
		https:      uint | *8443
		infinispan: uint | *7800
	}
	// 	## @param extraContainerPorts Optionally specify extra list of additional port-mappings for Keycloak container
	// ##
	extraContainerPorts: [...v1.#ContainerPort]

	// 	## Keycloak pods' SecurityContext
	// ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod
	// ## @param podSecurityContext.enabled Enabled Keycloak pods' Security Context
	// ## @param podSecurityContext.fsGroupChangePolicy Set filesystem group change policy
	// ## @param podSecurityContext.sysctls Set kernel settings using the sysctl interface
	// ## @param podSecurityContext.supplementalGroups Set filesystem extra groups
	// ## @param podSecurityContext.fsGroup Set Keycloak pod's Security Context fsGroup
	// ##
	podSecurityContext: {
		enabled:             bool | *true
		fsGroupChangePolicy: string | *"Always"
		sysctls: [...v1.#Sysctl]
		supplementalGroups: [...uint]
		fsGroup: uint | *1001
	}

	// 	## Keycloak containers' Security Context
	// ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
	// ## @param containerSecurityContext.enabled Enabled containers' Security Context
	// ## @param containerSecurityContext.seLinuxOptions [object,nullable] Set SELinux options in container
	// ## @param containerSecurityContext.runAsUser Set containers' Security Context runAsUser
	// ## @param containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
	// ## @param containerSecurityContext.privileged Set container's Security Context privileged
	// ## @param containerSecurityContext.readOnlyRootFilesystem Set container's Security Context readOnlyRootFilesystem
	// ## @param containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
	// ## @param containerSecurityContext.capabilities.drop List of capabilities to be dropped
	// ## @param containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
	// ##
	containerSecurityContext: {
		enabled:                  bool | *true
		seLinuxOptions:           v1.#SELinuxOptions | *null
		runAsUser:                uint | *1001
		runAsNonRoot:             bool | *true
		privileged:               bool | *false
		readOnlyRootFilesystem:   bool | *false
		allowPrivilegeEscalation: bool | *false
		capabilities: {
			drop: [...string] | *["ALL"]
		}
		seccompProfile: {
			type: string | *"RuntimeDefault"
		}
	}

	// ## Keycloak resource requests and limits
	// ## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
	// ## @param resourcesPreset Set container resources according to one common preset (allowed values: none, nano, small, medium, large, xlarge, 2xlarge). This is ignored if resources is set (resources is recommended for production).
	// ## More information: https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl#L15
	// ##

	resourcesPreset: *"none" | "nano" | "small" | "medium" | "large" | "xlarge" | "2xlarge"

	// 	## @param resources Set container requests and limits for different resources like CPU or memory (essential for production workloads)
	// ## Example:
	// ## resources:
	// ##   requests:
	// ##     cpu: 2
	// ##     memory: 512Mi
	// ##   limits:
	// ##     cpu: 3
	// ##     memory: 1024Mi
	// ##
	resources: v1.#ResourceRequirements | *{}

	// ## Configure extra options for Keycloak containers' liveness, readiness and startup probes
	// ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes
	// ## @param livenessProbe.enabled Enable livenessProbe on Keycloak containers
	// ## @param livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
	// ## @param livenessProbe.periodSeconds Period seconds for livenessProbe
	// ## @param livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
	// ## @param livenessProbe.failureThreshold Failure threshold for livenessProbe
	// ## @param livenessProbe.successThreshold Success threshold for livenessProbe
	// ##
	livenessProbe: {
		enabled:             bool | *true
		initialDelaySeconds: uint | *300
		periodSeconds:       uint | *1
		timeoutSeconds:      uint | *5
		failureThreshold:    uint | *3
		successThreshold:    uint | *1
	}

	// 	## @param readinessProbe.enabled Enable readinessProbe on Keycloak containers
	// ## @param readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
	// ## @param readinessProbe.periodSeconds Period seconds for readinessProbe
	// ## @param readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
	// ## @param readinessProbe.failureThreshold Failure threshold for readinessProbe
	// ## @param readinessProbe.successThreshold Success threshold for readinessProbe
	// ##
	readinessProbe: {
		enabled:             bool | *true
		initialDelaySeconds: uint | *30
		periodSeconds:       uint | *10
		timeoutSeconds:      uint | *1
		failureThreshold:    uint | *3
		successThreshold:    uint | *1
	}

	// 	## When enabling this, make sure to set initialDelaySeconds to 0 for livenessProbe and readinessProbe
	// ## @param startupProbe.enabled Enable startupProbe on Keycloak containers
	// ## @param startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
	// ## @param startupProbe.periodSeconds Period seconds for startupProbe
	// ## @param startupProbe.timeoutSeconds Timeout seconds for startupProbe
	// ## @param startupProbe.failureThreshold Failure threshold for startupProbe
	// ## @param startupProbe.successThreshold Success threshold for startupProbe
	// ##
	startupProbe: {
		enabled:             bool | *false
		initialDelaySeconds: uint | *30
		periodSeconds:       uint | *5
		timeoutSeconds:      uint | *1
		failureThreshold:    uint | *60
		successThreshold:    uint | *1
	}

	// ## @param customLivenessProbe Custom Liveness probes for Keycloak
	// ##
	customLivenessProbe: {...}
	// ## @param customReadinessProbe Custom Rediness probes Keycloak
	// ##
	customReadinessProbe: {...}
	// ## @param customStartupProbe Custom Startup probes for Keycloak
	// ##
	customStartupProbe: {...}
	// ## @param lifecycleHooks LifecycleHooks to set additional configuration at startup
	// ##
	lifecycleHooks: {...}
	// ## @param automountServiceAccountToken Mount Service Account token in pod
	// ##
	automountServiceAccountToken: bool | *true
	// ## @param hostAliases Deployment pod host aliases
	// ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
	// ##
	hostAliases: [...]
	// ## @param podLabels Extra labels for Keycloak pods
	// ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
	// ##
	podLabels: k8s.#Labels
	// ## @param podAnnotations Annotations for Keycloak pods
	// ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
	// ##
	podAnnotations: k8s.#Annotations
	// ## @param podAffinityPreset Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
	// ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
	// ##
	podAffinityPreset: "soft" | "hard" | *""
	// ## @param podAntiAffinityPreset Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
	// ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
	// ##
	podAntiAffinityPreset: *"soft" | "hard"

	// 	## Node affinity preset
	// ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
	// ##
	nodeAffinityPreset: {
		// 	  ## @param nodeAffinityPreset.type Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
		//   ##
		type: "soft" | "hard" | *""
		//   ## @param nodeAffinityPreset.key Node label key to match. Ignored if `affinity` is set.
		//   ## E.g.
		//   ## key: "kubernetes.io/e2e-az-name"
		//   ##
		key: string | *""
		//   ## @param nodeAffinityPreset.values Node label values to match. Ignored if `affinity` is set.
		//   ## E.g.
		//   ## values:
		//   ##   - e2e-az1
		//   ##   - e2e-az2
		//   ##
		values: [...]
	}

	// ## @param affinity Affinity for pod assignment
	// ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
	// ##
	affinity: v1.#Affinity

	// 	## @param nodeSelector Node labels for pod assignment
	// ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
	// ##
	nodeSelector: k8s.#Labels

	// 	## @param tolerations Tolerations for pod assignment
	// ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
	// ##
	tolerations: [...v1.#Toleration]

	// 	## @param topologySpreadConstraints Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template
	// ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#spread-constraints-for-pods
	// ##
	topologySpreadConstraints: [...v1.#TopologySpreadConstraint]

	// ## @param podManagementPolicy Pod management policy for the Keycloak statefulset
	// ##
	podManagementPolicy: "OrderedReady" | *"Parallel"

	// 	## @param priorityClassName Keycloak pods' Priority Class Name
	// ## ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/
	// ##
	priorityClassName: string | *""

	// 	## @param schedulerName Use an alternate scheduler, e.g. "stork".
	// ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
	// ##
	schedulerName: string | *""

	// 	## @param terminationGracePeriodSeconds Seconds Keycloak pod needs to terminate gracefully
	// ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods
	// ##
	terminationGracePeriodSeconds: string | *""

	// 	## @param updateStrategy.type Keycloak statefulset strategy type
	// ## @param updateStrategy.rollingUpdate Keycloak statefulset rolling update configuration parameters
	// ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
	// ##
	updateStrategy: {
		type: "OnDelete" | "Recreate" | *"RollingUpdate"
		rollingUpdate: {...}
	}

	// 	## @param extraVolumes Optionally specify extra list of additional volumes for Keycloak pods
	// ##
	extraVolumes: [...v1.#Volume]
	// ## @param extraVolumeMounts Optionally specify extra list of additional volumeMounts for Keycloak container(s)
	// ##
	extraVolumeMounts: [...v1.#VolumeMount]

	// 	## @param initContainers Add additional init containers to the Keycloak pods
	// ## Example:
	// ## initContainers:
	// ##   - name: your-image-name
	// ##     image: your-image
	// ##     imagePullPolicy: Always
	// ##     ports:
	// ##       - name: portname
	// ##         containerPort: 1234
	// ##
	initContainers: [...v1.#Container]

	// 	## @param sidecars Add additional sidecar containers to the Keycloak pods
	// ## Example:
	// ## sidecars:
	// ##   - name: your-image-name
	// ##     image: your-image
	// ##     imagePullPolicy: Always
	// ##     ports:
	// ##       - name: portname
	// ##         containerPort: 1234
	// ##
	sidecars: [...v1.#Container]

	// 	## @section Exposure parameters
	// ##

	// ## Service configuration
	// ##
	service: {
		// 		  ## @param service.type Kubernetes service type
		//   ##
		type: "NodePort" | "LoadBalancer" | "ExternalName" | *"ClusterIP"

		// 		  ## @param service.http.enabled Enable http port on service
		//   ##
		http: {
			enabled: bool | *true
		}
		// 		  ## @param service.ports.http Keycloak service HTTP port
		//   ## @param service.ports.https Keycloak service HTTPS port
		//   ##
		ports: {
			http:  uint | *80
			https: uint | *443
		}

		// 		  ## @param service.nodePorts [object] Specify the nodePort values for the LoadBalancer and NodePort service types.
		//   ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
		//   ##
		nodePorts: {
			http:  string | *""
			https: string | *""
		}

		// 	## @param service.sessionAffinity Control where client requests go, to the same pod or round-robin
		//   ## Values: ClientIP or None
		//   ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
		//   ##
		sessionAffinity: "ClientIP" | *"None"

		//   ## @param service.sessionAffinityConfig Additional settings for the sessionAffinity
		// 	  ## sessionAffinityConfig:
		//   ##   clientIP:
		//   ##     timeoutSeconds: 300
		//   ##
		sessionAffinityConfig: {...}

		// 	  ## @param service.clusterIP Keycloak service clusterIP IP
		//   ## e.g:
		//   ## clusterIP: None
		//   ##
		clusterIP: string | *""

		//   ## @param service.loadBalancerIP loadBalancerIP for the SuiteCRM Service (optional, cloud specific)
		//   ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer
		//   ##
		loadBalancerIP: string | *""

		//   ## @param service.loadBalancerSourceRanges Address that are allowed when service is LoadBalancer
		//   ## https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
		//   ## Example:
		//   ## loadBalancerSourceRanges:
		//   ##   - 10.10.10.0/24
		//   ##
		loadBalancerSourceRanges: [...string]

		//   ## @param service.externalTrafficPolicy Enable client source IP preservation
		//   ## ref https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
		//   ##
		externalTrafficPolicy: *"Cluster" | string

		//   ## @param service.annotations Additional custom annotations for Keycloak service
		//   ##
		annotations: k8s.#Annotations

		//   ## @param service.extraPorts Extra port to expose on Keycloak service
		//   ##
		extraPorts: [...v1.#ServicePort]

		//  ## Headless service properties
		//   ##
		headless: {
			// 		  ## @param service.headless.annotations Annotations for the headless service.
			//   ##
			annotations: k8s.#Annotations
			// 		  ## @param service.headless.extraPorts Extra ports to expose on Keycloak headless service
			//   ##
			extraPorts: [...]
		}
	}

	ingress: {
		// Enable ingress record generation for Keycloak
		enabled: bool | *false

		// IngressClass that will be used to implement the Ingress (Kubernetes 1.18+)
		// This is supported in Kubernetes 1.18+ and required if you have more than one IngressClass marked as the default for your cluster.
		ingressClassName: string | *""

		// Ingress path type
		pathType: string | *"ImplementationSpecific"

		// Force Ingress API version (automatically detected if not set)
		apiVersion: string | *""

		// Default host for the ingress record (evaluated as template)
		hostname: string | *"keycloak.local"

		// Default path for the ingress record (evaluated as template)
		path: string | *"{{ .Values.httpRelativePath }}"

		// Backend service port to use. Default is http. Alternative is https.
		servicePort: string | *"http"

		// Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.
		// Use this parameter to set the required annotations for cert-manager.
		annotations: k8s.#Annotations

		// Additional labels for the Ingress resource.
		labels: k8s.#Labels

		// Enable TLS configuration for the host defined at `ingress.hostname` parameter.
		// TLS certificates will be retrieved from a TLS secret with name: `{{- printf "%s-tls" (tpl .Values.ingress.hostname .) }}`
		// You can:
		//   - Use the `ingress.secrets` parameter to create this TLS secret
		//   - Rely on cert-manager to create it by setting the corresponding annotations
		//   - Rely on Helm to create self-signed certificates by setting `ingress.selfSigned=true`
		tls: bool | *false

		// Create a TLS secret for this ingress record using self-signed certificates generated by Helm
		selfSigned: bool | *false

		// An array with additional hostname(s) to be covered with the ingress record
		extraHosts: [...v1.#HostAlias]

		// Any additional arbitrary paths that may need to be added to the ingress under the main host.
		extraPaths: [...v1.#HTTPIngressPath]

		// The tls configuration for additional hostnames to be covered with this ingress record.
		extraTls: [...v1.#IngressTLS]

		// If you're providing your own certificates, please use this to add the certificates as secrets.
		// Key and certificate should start with -----BEGIN CERTIFICATE----- or -----BEGIN RSA PRIVATE KEY-----.
		// Name should line up with a tlsSecret set further up.
		// If you're using cert-manager, this is unneeded, as it will create the secret for you if it is not set.
		// It is also possible to create and manage the certificates outside of this helm chart.
		secrets: [...v1.#Secret]

		// Additional rules to be covered with this ingress record
		extraRules: [...v1.#IngressRule]
	}

	adminIngress: {
		// Enable admin ingress record generation for Keycloak
		enabled: bool | *false

		// IngressClass that will be used to implement the Ingress (Kubernetes 1.18+)
		// This is supported in Kubernetes 1.18+ and required if you have more than one IngressClass marked as the default for your cluster.
		ingressClassName: string | *""

		// Ingress path type
		pathType: string | *"ImplementationSpecific"

		// Force Ingress API version (automatically detected if not set)
		apiVersion: string | *""

		// Default host for the admin ingress record (evaluated as template)
		hostname: string | *"keycloak.local"

		// Default path for the admin ingress record (evaluated as template)
		path: string | *"{{ .Values.httpRelativePath }}"

		// Backend service port to use. Default is http. Alternative is https.
		servicePort: string | *"http"

		// Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations.
		// Use this parameter to set the required annotations for cert-manager.
		annotations: k8s.#Annotations

		// Additional labels for the Ingress resource.
		labels: k8s.#Labels

		// Enable TLS configuration for the host defined at `adminIngress.hostname` parameter.
		// TLS certificates will be retrieved from a TLS secret with name: `{{- printf "%s-tls" (tpl .Values.adminIngress.hostname .) }}`
		// You can:
		//   - Use the `adminIngress.secrets` parameter to create this TLS secret
		//   - Rely on cert-manager to create it by setting the corresponding annotations
		//   - Rely on Helm to create self-signed certificates by setting `adminIngress.selfSigned=true`
		tls: bool | *false

		// Create a TLS secret for this ingress record using self-signed certificates generated by Helm
		selfSigned: bool | *false

		// An array with additional hostname(s) to be covered with the admin ingress record
		extraHosts: [...v1.#HostAlias]

		// Any additional arbitrary paths that may need to be added to the admin ingress under the main host.
		extraPaths: [...v1.#HTTPIngressPath]

		// The tls configuration for additional hostnames to be covered with this ingress record.
		extraTls: [...v1.#IngressTLS]

		// If you're providing your own certificates, please use this to add the certificates as secrets.
		// Key and certificate should start with -----BEGIN CERTIFICATE----- or -----BEGIN RSA PRIVATE KEY-----.
		// Name should line up with a tlsSecret set further up.
		// If you're using cert-manager, this is unneeded, as it will create the secret for you if it is not set.
		// It is also possible to create and manage the certificates outside of this helm chart.
		secrets: [...v1.#Secret]

		// Additional rules to be covered with this ingress record
		extraRules: [...v1.#IngressRule]
	}

	networkPolicy: {
		// Specifies whether a NetworkPolicy should be created
		enabled: bool | *true

		// Don't require server label for connections
		// The Policy model to apply. When set to false, only pods with the correct
		// server label will have network access to the ports server is listening
		// on. When true, server will accept connections from any source
		// (with the correct destination port).
		allowExternal: bool | *true

		// Allow the pod to access any range of port and all destinations.
		allowExternalEgress: bool | *true

		// List of possible endpoints to kube-apiserver (limit to your cluster settings to increase security)
		kubeAPIServerPorts: [...uint] | *[443, 6443, 8443]

		// Add extra ingress rules to the NetworkPolicy
		//   ## @param networkPolicy.extraIngress [array] Add extra ingress rules to the NetworkPolice
		//   ## e.g:
		//   ## extraIngress:
		//   ##   - ports:
		//   ##       - port: 1234
		//   ##     from:
		//   ##       - podSelector:
		//   ##           - matchLabels:
		//   ##               - role: frontend
		//   ##       - podSelector:
		//   ##           - matchExpressions:
		//   ##               - key: role
		//   ##                 operator: In
		//   ##                 values:
		//   ##                   - frontend
		extraIngress: [...v1.#NetworkPolicyIngressRule]

		// Add extra ingress rules to the NetworkPolicy
		//   ## @param networkPolicy.extraEgress [array] Add extra ingress rules to the NetworkPolicy
		//   ## e.g:
		//   ## extraEgress:
		//   ##   - ports:
		//   ##       - port: 1234
		//   ##     to:
		//   ##       - podSelector:
		//   ##           - matchLabels:
		//   ##               - role: frontend
		//   ##       - podSelector:
		//   ##           - matchExpressions:
		//   ##               - key: role
		//   ##                 operator: In
		//   ##                 values:
		//   ##                   - frontend
		//   ##
		extraEgress: [...v1.#NetworkPolicyEgressRule]

		// Labels to match to allow traffic from other namespaces
		ingressNSMatchLabels: k8s.#Labels

		// Pod labels to match to allow traffic from other namespaces
		ingressNSPodMatchLabels: k8s.#Labels
	}

	serviceAccount: {
		// Specifies whether a ServiceAccount should be created
		create: bool | *true

		// Name of the created ServiceAccount
		// If not set and create is true, a name is generated using the fullname template
		name: string | *""

		// Auto-mount the service account token in the pod
		automountServiceAccountToken: bool | *false

		// Additional custom annotations for the ServiceAccount
		annotations: k8s.#Annotations

		// Additional labels for the ServiceAccount
		extraLabels: k8s.#Labels
	}

	rbac: {
		//   ## @param rbac.create Whether to create and use RBAC resources or not
		//   ##
		create: bool | *false
		//   ## @param rbac.rules Custom RBAC rules
		//   ## Example:
		//   ## rules:
		//   ##   - apiGroups:
		//   ##       - ""
		//   ##     resources:
		//   ##       - pods
		//   ##     verbs:
		//   ##       - get
		//   ##       - list
		//   ##
		rules: [...v1.#PolicyRule]
	}

	pdb: {
		// Enable/disable a Pod Disruption Budget creation
		create: bool | *false

		// Minimum number/percentage of pods that should remain scheduled
		minAvailable: uint | *1

		// Maximum number/percentage of pods that may be made unavailable
		maxUnavailable: uint | *""
	}

	autoscaling: {
		// Enable autoscaling for Keycloak
		enabled: bool | *false

		// Minimum number of Keycloak replicas
		minReplicas: uint | *1

		// Maximum number of Keycloak replicas
		maxReplicas: uint | *11

		// Target CPU utilization percentage
		targetCPU: uint | string | *""

		// Target Memory utilization percentage
		targetMemory: uint | string | *""
	}

	metrics: {
		// Enable exposing Keycloak statistics
		enabled: bool | *false

		// Keycloak metrics service parameters
		service: {
			// Metrics service HTTP port
			ports: {
				http: uint | *8080
			}

			// Annotations for enabling prometheus to access the metrics endpoints
			annotations: *{
				"prometheus.io/scrape": "true"
				"prometheus.io/port":   "{{ .Values.metrics.service.ports.http }}"
			} | k8s.#Annotations

			// Add additional ports to the keycloak metrics service (i.e. admin port 9000)
			extraPorts: [...v1.#ServicePort]
		}

		// Prometheus Operator ServiceMonitor configuration
		serviceMonitor: {
			// Create ServiceMonitor Resource for scraping metrics using PrometheusOperator
			enabled: bool | *false

			// Metrics service HTTP port
			port: *"http" | string

			// The endpoint configuration of the ServiceMonitor. Path is mandatory. Interval, timeout and labellings can be overwritten.
			endpoints: *[
				{path: '{{ include "keycloak.httpPath" . }}metrics'},
				{path: '{{ include "keycloak.httpPath" . }}realms/master/metrics'},
			] | [...v1.#ServiceMonitorSpecEndpoint]

			// Namespace which Prometheus is running in
			namespace: string | *""

			// Interval at which metrics should be scraped
			interval: string | *"30s"

			// Specify the timeout after which the scrape is ended
			scrapeTimeout: string | *""

			// Additional labels that can be used so ServiceMonitor will be discovered by Prometheus
			labels: k8s.#Labels

			// Prometheus instance selector labels
			selector: k8s.#Labels

			// RelabelConfigs to apply to samples before scraping
			relabelings: [...v1.#RelabelConfig]

			// MetricRelabelConfigs to apply to samples before ingestion
			metricRelabelings: [...v1.#RelabelConfig]

			// honorLabels chooses the metric's labels on collisions with target labels
			honorLabels: bool | *false

			// The name of the label on the target service to use as the job name in prometheus.
			jobLabel: string | *""
		}

		// Prometheus Operator alert rules configuration
		prometheusRule: {
			// Create PrometheusRule Resource for scraping metrics using PrometheusOperator
			enabled: bool | *false

			// Namespace which Prometheus is running in
			namespace: string | *""

			// Additional labels that can be used so PrometheusRule will be discovered by Prometheus
			labels: k8s.#Labels

			// Groups, containing the alert rules
			groups: [...v1.#PrometheusRuleGroup]
		}
	}

	keycloakConfigCli: {
		// Whether to enable keycloak-config-cli job
		enabled: bool | *false

		// Bitnami keycloak-config-cli image
		image: {
			// keycloak-config-cli container image registry
			registry: string | *"docker.io"
			// keycloak-config-cli container image repository
			repository: string | *"bitnami/keycloak-config-cli"
			// keycloak-config-cli container image tag
			tag: string | *"5.10.0-debian-12-r9"
			// keycloak-config-cli container image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag
			digest: string | *""
			// keycloak-config-cli container image pull policy
			pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
			// keycloak-config-cli container image pull secrets
			pullSecrets: [...v1.#LocalObjectReference]
		}

		// Annotations for keycloak-config-cli job
		annotations: *{
			"helm.sh/hook":               "post-install,post-upgrade,post-rollback"
			"helm.sh/hook-delete-policy": "hook-succeeded,before-hook-creation"
			"helm.sh/hook-weight":        "5"
		} | k8s.#Annotations

		// Command for running the container (set to default if not set). Use array form
		command: [...]

		// Args for running the container (set to default if not set). Use array form
		args: [...]

		// Mount Service Account token in pod
		automountServiceAccountToken: bool | *true

		// Job pod host aliases
		hostAliases: [...v1.#HostAlias]

		// Set container resources according to one common preset
		resourcesPreset: string | *"none"

		// Set container requests and limits for different resources like CPU or memory
		resources: v1.#ResourceRequirements

		// keycloak-config-cli Security Context
		containerSecurityContext: {
			enabled:                  bool | *true
			seLinuxOptions:           v1.#SELinuxOptions | *null
			runAsUser:                uint | *1001
			runAsNonRoot:             bool | *true
			privileged:               bool | *false
			readOnlyRootFilesystem:   bool | *false
			allowPrivilegeEscalation: bool | *false
			capabilities: {
				drop: [...string] | *["ALL"]
			}
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
		}

		// keycloak-config-cli pods' Security Context
		podSecurityContext: {
			enabled:             bool | *true
			fsGroupChangePolicy: string | *"Always"
			sysctls: [...v1.#Sysctl]
			supplementalGroups: [...uint] | *[]
			fsGroup: uint | *1001
		}

		// Number of retries before considering a Job as failed
		backoffLimit: uint | *1

		// Pod extra labels
		podLabels: k8s.#Labels

		// Annotations for job pod
		podAnnotations: k8s.#Annotations

		// Additional environment variables to set
		extraEnvVars: [...v1.#EnvVar]

		// Node labels for pod assignment
		nodeSelector: v1.#NodeSelector

		// Tolerations for job pod assignment
		podTolerations: [...v1.#Toleration]

		// ConfigMap with extra environment variables
		extraEnvVarsCM: string | *""

		// Secret with extra environment variables
		extraEnvVarsSecret: string | *""

		// Extra volumes to add to the job
		extraVolumes: [...v1.#Volume]

		// Extra volume mounts to add to the container
		extraVolumeMounts: [...v1.#VolumeMount]

		// Add additional init containers to the Keycloak config cli pod
		initContainers: [...v1.#Container]

		// Add additional sidecar containers to the Keycloak config cli pod
		sidecars: [...v1.#Container]

		// keycloak-config-cli realms configuration
		configuration: {...}

		// ConfigMap with keycloak-config-cli configuration
		existingConfigmap: string | *""

		// Automatic Cleanup for Finished Jobs
		cleanupAfterFinished: {
			enabled: bool | *false
			seconds: uint | *600
		}
	}

	// PostgreSQL chart configuration
	postgresql: {
		// Switch to enable or disable the PostgreSQL helm chart
		enabled: bool | *true
		// Password for the "postgres" admin user. Ignored if `auth.existingSecret` with key `postgres-password` is provided
		auth: {
			postgresPassword: string | *""
			// Name for a custom user to create
			username: string | *"bn_keycloak"
			// Password for the custom user to create
			password: string | *""
			// Name for a custom database to create
			database: string | *"bitnami_keycloak"
			// Name of existing secret to use for PostgreSQL credentials
			existingSecret: string | *""
		}
		// PostgreSQL architecture (`standalone` or `replication`)
		architecture: *"standalone" | "replication"
	}

	// External PostgreSQL configuration
	// All of these values are only used when postgresql.enabled is set to false
	externalDatabase: {
		// Database host
		host: string | *""
		// Database port number
		port: uint | *5432
		// Non-root username for Keycloak
		user: string | *""
		// Keycloak database name
		database: string | *""
		// Password for the non-root username for Keycloak
		password: string | *""
		// Name of an existing secret resource containing the database credentials
		existingSecret: string | *""
		// Name of an existing secret key containing the database host name
		existingSecretHostKey: string | *""
		// Name of an existing secret key containing the database port
		existingSecretPortKey: string | *""
		// Name of an existing secret key containing the database user
		existingSecretUserKey: string | *""
		// Name of an existing secret key containing the database name
		existingSecretDatabaseKey: string | *""
		// Name of an existing secret key containing the database credentials
		existingSecretPasswordKey: string | *""
		// Additional custom annotations for external database secret object
		annotations: k8s.#Annotations
	}

	// 	## Keycloak cache configuration
	// ## ref: https://www.keycloak.org/server/caching
	// ## @param cache.enabled Switch to enable or disable the keycloak distributed cache for kubernetes.
	// ## NOTE: Set to false to use 'local' cache (only supported when replicaCount=1).
	// ## @param cache.stackName Set infinispan cache stack to use
	// ## @param cache.stackFile Set infinispan cache stack filename to use
	// ##
	cache: {
		enabled:   bool | *true
		stackName: string | *"kubernetes"
		stackFile: string | *""
	}

	// 	## Keycloak logging configuration
	// ## ref: https://www.keycloak.org/server/logging
	// ## @param logging.output Alternates between the default log output format or json format
	// ## @param logging.level Allowed values as documented: FATAL, ERROR, WARN, INFO, DEBUG, TRACE, ALL, OFF
	// ##
	logging: {
		output: string | *"default"
		level:  string | *"INFO"
	}
}
