package minio

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^5\\.0\\."]: minor: >=21
#Values: [=~"^5\\.0\\."]: {

	nameOverride:     string | *""
	fullnameOverride: string | *""

	clusterDomain: string | *"cluster.local"

	image: {
		repository: string | *"quay.io/minio/minio"
		tag:        string | *"RELEASE.2023-07-07T07-13-57Z"
		pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
	}

	imagePullSecrets: [...v1.#LocalObjectReference]

	mcImage: {
		repository: string | *"quay.io/minio/mc"
		tag:        string | *"RELEASE.2023-07-07T07-13-57Z"
		pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
	}

	mode: "standalone" | *"distributed"

	additionalLabels:      k8s.#Labels
	additionalAnnotations: k8s.#Annotations

	//Typically the deployment/statefulset includes checksums of secrets/config,
	//So that when these change on a subsequent helm install, the deployment/statefulset
	//is restarted. This can result in unnecessary restarts under GitOps tooling such as
	//flux, so set to "true" to disable this behaviour.
	ignoreChartChecksums: bool | *false

	//Additional arguments to pass to minio binary
	extraArgs: [string]: string

	//Additional volumes to minio container
	extraVolumes: [...v1.#Volume]

	//Additional volumeMounts to minio container
	extraVolumeMounts: [...v1.#VolumeMount]

	//Additional sidecar containers
	extraContainers: [...v1.#Container]

	//Internal port number for MinIO S3 API container
	//Change service.port to change external port number
	minioAPIPort: k8s.#Port | *9000

	//Internal port number for MinIO Browser Console container
	//Change consoleService.port to change external port number
	minioConsolePort: k8s.#Port | *9001

	//Update strategy for Deployments
	deploymentUpdate: {
		type:           string | *"RollingUpdate"
		maxUnavailable: uint | string | *0
		maxSurge:       uint | string | *"100%"
	}

	//Update strategy for StatefulSets
	statefulSetUpdate: {
		updateStrategy: string | *"RollingUpdate"
	}

	//Pod priority settings
	//ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/
	// ##
	priorityClassName: string | *""

	//Pod runtime class name
	//ref https://kubernetes.io/docs/concepts/containers/runtime-class/
	// ##
	runtimeClassName: string | *""

	//Set default rootUser, rootPassword
	//AccessKey and secretKey is generated when not set
	//Distributed MinIO ref: https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-multi-node-multi-drive.html
	// ##
	rootUser:     string | *""
	rootPassword: string | *""

	//Use existing Secret that store following variables:
	// ##
	//| Chart var             | .data.<key> in Secret    |
	//|:----------------------|:-------------------------|
	//| rootUser              | rootUser                 |
	//| rootPassword          | rootPassword             |
	// ##
	//All mentioned variables will be ignored in values file.
	//.data.rootUser and .data.rootPassword are mandatory,
	//others depend on enabled status of corresponding sections.
	existingSecret: string | *""

	//Directory on the MinIO pof
	certsPath:    string | *"/etc/minio/certs/"
	configPathmc: string | *"/etc/minio/mc/"

	//Path where PV would be mounted on the MinIO Pod
	mountPath: string | *"/export"
	//Override the root directory which the minio server should serve from.
	//If left empty, it defaults to the value of {{ .Values.mountPath }}
	//If defined, it must be a sub-directory of the path specified in {{ .Values.mountPath }}
	// ##
	bucketRoot: string | *""

	// Number of drives attached to a node
	drivesPerNode: uint | *1
	// Number of MinIO containers running
	replicas: uint | *16
	// Number of expanded MinIO clusters
	pools: uint | *1

	//TLS Settings for MinIO
	tls: {
		enabled: bool | *false
		//  Create a secret with private.key and public.crt files and pass that here. Ref: https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
		if tls.enabled {
			certSecret: string
			publicCrt:  string
			privateKey: string
		}
	}

	//Trusted Certificates Settings for MinIO. Ref: https://min.io/docs/minio/linux/operations/network-encryption.html#third-party-certificate-authorities
	//Bundle multiple trusted certificates into one secret and pass that here. Ref: https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
	//When using self-signed certificates, remember to include MinIO's own certificate in the bundle with key public.crt.
	//If certSecret is left empty and tls is enabled, this chart installs the public certificate from .Values.tls.certSecret.
	trustedCertsSecret: string | *""

	//Enable persistence using Persistent Volume Claims
	//ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
	persistence: {
		enabled:     bool | *true
		annotations: k8s.#Annotations
		//  A manually managed Persistent Volume and Claim
		//  Requires persistence.enabled: true
		//  If defined, PVC must be created manually before volume will be bound
		existingClaim: string | *""
		//  minio data Persistent Volume Storage Class
		//  If defined, storageClassName: <storageClass>
		//  If set to "-", storageClassName: "", which disables dynamic provisioning
		//  If undefined (the default) or set to null, no storageClassName spec is
		//    set, choosing the default provisioner.  (gp2 on AWS, standard on
		//    GKE, AWS & OpenStack)
		//  Storage class of PV to bind. By default it looks for standard storage class.
		//  If the PV uses a different storage class, specify that here.
		storageClass: string | *""
		volumeName:   string | *""
		accessMode:   string | *"ReadWriteOnce"
		size:         string | *"500Gi"

		//  If subPath is set mount a sub folder of a volume instead of the root of the volume.
		//  This is especially handy for volume plugins that don't natively support sub mounting (like glusterfs).
		subPath: string | *""
	}

	//Expose the MinIO service to be accessed from outside the cluster (LoadBalancer service).
	//or access it from within the cluster (ClusterIP service). Set the service type and the port to serve it.
	//ref: http://kubernetes.io/docs/user-guide/services/
	service: {
		type:           string | *"ClusterIP"
		port:           uint | *9000
		nodePort:       uint | *32000
		clusterIP:      string | *""
		loadBalancerIP: string | *""
		annotations:    k8s.#Annotations
		externalIPs: [...string]
	}

	//Configure Ingress based on the documentation here: https://kubernetes.io/docs/concepts/services-networking/ingress/

	ingress: {
		enabled:          bool | *false
		ingressClassName: string | *""
		labels:           k8s.#Labels
		//     # node-role.kubernetes.io/ingress: platform
		annotations: k8s.#Annotations
		//     # kubernetes.io/ingress.class: nginx
		//     # kubernetes.io/tls-acme: "true"
		//     # kubernetes.io/ingress.allow-http: "false"
		//     # kubernetes.io/ingress.global-static-ip-name: ""
		//     # nginx.ingress.kubernetes.io/secure-backends: "true"
		//     # nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
		//     # nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
		path: string | *"/"
		hosts: [...string]
		//     - minio-example.local
		tls: [...{
			secretName: string
			hosts: [...string]
		}]
		//   #  - secretName: chart-example-tls
		//   #    hosts:
		//   #      - chart-example.local
	}

	consoleService: {
		type:      string | *"ClusterIP"
		port:      uint | *9001
		nodePort:  uint | *32001
		clusterIP: string | *""
		labels:    k8s.#Labels
		//     # node-role.kubernetes.io/ingress: platform
		loadBalancerIP: string | *""
		annotations:    k8s.#Annotations
		//     # kubernetes.io/ingress.class: nginx
		//     # kubernetes.io/tls-acme: "true"
		//     # kubernetes.io/ingress.allow-http: "false"
		//     # kubernetes.io/ingress.global-static-ip-name: ""
		//     # nginx.ingress.kubernetes.io/secure-backends: "true"
		//     # nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
		//     # nginx.ingress.kubernetes.io/whitelist-source-range: 0.0.0.0/0
		externalIPs: [...string]
		path: string | *"/"
		hosts: [...string]
		//     - minio-example.local
		tls: [...{
			secretName: string
			hosts: [...string]
		}]
		//   #  - secretName: chart-example-tls
		//   #    hosts:
		//   #      - chart-example.local
	}

	//Node labels for pod assignment
	//Ref: https://kubernetes.io/docs/user-guide/node-selection/

	nodeSelector: k8s.#Labels
	tolerations: [...v1.#Toleration]
	affinity: k8s.#Affinity
	topologySpreadConstraints: [...]

	//Add stateful containers to have security context, if enabled MinIO will run as this
	//user and group NOTE: securityContext is only enabled if persistence.enabled=true
	securityContext: v1.#PodSecurityContext | *{
		enabled:             true
		runAsUser:           1000
		runAsGroup:          1000
		fsGroup:             1000
		fsGroupChangePolicy: "OnRootMismatch"
	}

	// # Additational pod annotations
	podAnnotations: k8s.#Annotations

	// # Additional pod labels
	podLabels: k8s.#Labels

	//Configure resource requests and limits
	//ref: http://kubernetes.io/docs/user-guide/compute-resources/
	resources: v1.#ResourceRequirements | *{
		requests: {

			memory: string | *"16Gi"
		}
	}

	//List of policies to be created after minio install
	// ##
	//In addition to default policies [readonly|readwrite|writeonly|consoleAdmin|diagnostics]
	//you can define additional policies with custom supported actions and resources
	policies: {
		...
	}
	//writeexamplepolicy policy grants creation or deletion of buckets with name
	//starting with example. In addition, grants objects write permissions on buckets starting with
	//example.
	// # - name: writeexamplepolicy
	// #   statements:
	// #     - effect: Allow  # this is the default
	// #       resources:
	// #         - 'arn:aws:s3:::example*/*'
	// #       actions:
	// #         - "s3:AbortMultipartUpload"
	// #         - "s3:GetObject"
	// #         - "s3:DeleteObject"
	// #         - "s3:PutObject"
	// #         - "s3:ListMultipartUploadParts"
	// #     - resources:
	// #         - 'arn:aws:s3:::example*'
	// #       actions:
	// #         - "s3:CreateBucket"
	// #         - "s3:DeleteBucket"
	// #         - "s3:GetBucketLocation"
	// #         - "s3:ListBucket"
	// #         - "s3:ListBucketMultipartUploads"
	//readonlyexamplepolicy policy grants access to buckets with name starting with example.
	//In addition, grants objects read permissions on buckets starting with example.
	// # - name: readonlyexamplepolicy
	// #   statements:
	// #     - resources:
	// #         - 'arn:aws:s3:::example*/*'
	// #       actions:
	// #         - "s3:GetObject"
	// #     - resources:
	// #         - 'arn:aws:s3:::example*'
	// #       actions:
	// #         - "s3:GetBucketLocation"
	// #         - "s3:ListBucket"
	// #         - "s3:ListBucketMultipartUploads"
	//conditionsexample policy creates all access to example bucket with aws:username="johndoe" and source ip range 10.0.0.0/8 and 192.168.0.0/24 only
	// # - name: conditionsexample
	// #   statements:
	// #     - resources:
	// #       - 'arn:aws:s3:::example/*'
	// #       actions:
	// #       - 's3:*'
	// #       conditions:
	// #         - StringEquals: '"aws:username": "johndoe"'
	// #         - IpAddress: |
	// #             "aws:SourceIp": [
	// #               "10.0.0.0/8",
	// #               "192.168.0.0/24"
	// #             ]
	// #

	//Additional Annotations for the Kubernetes Job makePolicyJob
	makePolicyJob: {
		securityContext: v1.#PodSecurityContext | *{
			enabled:    false
			runAsUser:  1000
			runAsGroup: 1000
		}
		resources: v1.#ResourceRequirements | *{
			requests: {
				memory: string | *"128Mi"
			}
		}
		//   # Command to run after the main command on exit
		exitCommand: string | *""
	}

	//List of users to be created after minio install
	// ##
	users: [...]
	//  Username, password and policy to be assigned to the user
	//  Default policies are [readonly|readwrite|writeonly|consoleAdmin|diagnostics]
	//  Add new policies as explained here https://min.io/docs/minio/kubernetes/upstream/administration/identity-access-management.html#access-management
	//  NOTE: this will fail if LDAP is enabled in your MinIO deployment
	//  make sure to disable this if you are using LDAP.
	//   - accessKey: console
	//     secretKey: console123
	//     policy: consoleAdmin
	//   # Or you can refer to specific secret
	//   #- accessKey: externalSecret
	//   #  existingSecret: my-secret
	//   #  existingSecretKey: password
	//   #  policy: readonly

	//Additional Annotations for the Kubernetes Job makeUserJob
	makeUserJob: {
		securityContext: v1.#PodSecurityContext | *{
			enabled:    false
			runAsUser:  1000
			runAsGroup: 1000
		}
		resources: v1.#ResourceRequirements | *{
			requests: {
				memory: string | *"128Mi"
			}
		}
		//   # Command to run after the main command on exit
		exitCommand: string | *""
	}

	//List of service accounts to be created after minio install
	// ##
	svcaccts: [...]
	//  accessKey, secretKey and parent user to be assigned to the service accounts
	//  Add new service accounts as explained here https://min.io/docs/minio/kubernetes/upstream/administration/identity-access-management/minio-user-management.html#service-accounts
	//   # - accessKey: console-svcacct
	//   #   secretKey: console123
	//   #   user: console
	//  Or you can refer to specific secret
	//   # - accessKey: externalSecret
	//   #   existingSecret: my-secret
	//   #   existingSecretKey: password
	//   #   user: console
	//  You also can pass custom policy
	//   # - accessKey: console-svcacct
	//   #   secretKey: console123
	//   #   user: console
	//   #   policy:
	//   #     statements:
	//   #       - resources:
	//   #           - 'arn:aws:s3:::example*/*'
	//   #         actions:
	//   #           - "s3:AbortMultipartUpload"
	//   #           - "s3:GetObject"
	//   #           - "s3:DeleteObject"
	//   #           - "s3:PutObject"
	//   #           - "s3:ListMultipartUploadParts"

	makeServiceAccountJob: {
		securityContext: v1.#PodSecurityContext | *{
			enabled:    false
			runAsUser:  1000
			runAsGroup: 1000
		}
		resources: v1.#ResourceRequirements | *{
			requests: {
				memory: string | *"128Mi"
			}
		}
		//   # Command to run after the main command on exit
		exitCommand: string | *""
	}

	//List of buckets to be created after minio install
	// ##
	buckets: [...]
	//   #   # Name of the bucket
	//   # - name: bucket1
	//   #   # Policy to be set on the
	//   #   # bucket [none|download|upload|public]
	//   #   policy: none
	//   #   # Purge if bucket exists already
	//   #   purge: false
	//   #   # set versioning for
	//   #   # bucket [true|false]
	//   #   versioning: false
	//   #   # set objectlocking for
	//   #   # bucket [true|false] NOTE: versioning is enabled by default if you use locking
	//   #   objectlocking: false
	//   # - name: bucket2
	//   #   policy: none
	//   #   purge: false
	//   #   versioning: true
	//   #   # set objectlocking for
	//   #   # bucket [true|false] NOTE: versioning is enabled by default if you use locking
	//   #   objectlocking: false

	//Additional Annotations for the Kubernetes Job makeBucketJob
	makeBucketJob: {
		securityContext: v1.#PodSecurityContext | *{
			enabled:    false
			runAsUser:  1000
			runAsGroup: 1000
		}
		resources: v1.#ResourceRequirements | *{
			requests: {
				memory: string | *"128Mi"
			}
		}
		//   # Command to run after the main command on exit
		exitCommand: string | *""
	}

	//List of command to run after minio install
	//NOTE: the mc command TARGET is always "myminio"
	customCommands: [...]
	//   # - command: "admin policy attach myminio consoleAdmin --group='cn=ops,cn=groups,dc=example,dc=com'"

	//Additional Annotations for the Kubernetes Job customCommandJob
	customCommandJob: {
		securityContext: v1.#PodSecurityContext | *{
			enabled:    false
			runAsUser:  1000
			runAsGroup: 1000
		}
		resources: v1.#ResourceRequirements | *{
			requests: {
				memory: string | *"128Mi"
			}
		}
		//   # Command to run after the main command on exit
		exitCommand: string | *""
	}

	//Merge jobs
	postJob: {
		podAnnotations:  k8s.#Annotations
		annotations:     k8s.#Annotations
		securityContext: v1.#PodSecurityContext | *{
			enabled:    false
			runAsUser:  1000
			runAsGroup: 1000
			fsGroup:    1000
		}
		nodeSelector: k8s.#Labels
		tolerations: [...v1.#Toleration]
		affinity: k8s.#Affinity
	}

	//Use this field to add environment variables relevant to MinIO server. These fields will be passed on to MinIO container(s)
	//when Chart is deployed
	environment: [...]
	//  Please refer for comprehensive list https://min.io/docs/minio/linux/reference/minio-server/minio-server.html
	//  MINIO_SUBNET_LICENSE: "License key obtained from https://subnet.min.io"
	//  MINIO_BROWSER: "off"

	//The name of a secret in the same kubernetes namespace which contain secret values
	//This can be useful for LDAP password, etc
	//The key in the secret must be 'config.env'
	// ##
	extraSecret: string | *""

	//OpenID Identity Management
	//The following section documents environment variables for enabling external identity management using an OpenID Connect (OIDC)-compatible provider.
	//See https://min.io/docs/minio/linux/operations/external-iam/configure-openid-external-identity-management.html for a tutorial on using these variables.
	oidc: {
		enabled:      bool | *false
		configUrl:    string | *"https://identity-provider-url/.well-known/openid-configuration"
		clientId:     string | *"minio"
		clientSecret: string | *""
		claimName:    string | *"policy"
		scopes:       string | *"openid,profile,email"
		redirectUri:  string | *"https://console-endpoint-url/oauth_callback"
		// Can leave empty
		claimPrefix: string | *""
		comment:     string | *""
	}

	networkPolicy: {
		enabled:       bool | *false
		allowExternal: bool | *true
	}

	//PodDisruptionBudget settings
	//ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions/

	podDisruptionBudget: {
		enabled:        bool | *false
		maxUnavailable: uint | string | *1
	}

	//Specify the service account to use for the MinIO pods. If 'create' is set to 'false' and 'name' is left unspecified, the account 'default' will be used.
	serviceAccount: {
		create: bool | *true
		//  The name of the service account to use. If 'create' is 'true', a service account with that name
		name: string | *"minio-sa"
	}

	metrics: {
		serviceMonitor: {
			enable:           bool | *false
			includeNode:      bool | *false
			public:           bool | *true
			additionalLabels: k8s.#Labels
			annotations:      k8s.#Annotations
			relabelConfigs: {...}
			relabelConfigsCluster: {...}
			//       # metricRelabelings:
			//       #   - regex: (server|pod)
			//       #     action: labeldrop
			namespace:     string | *""
			interval:      string | *""
			scrapeTimeout: string | *""
		}
	}

	//ETCD settings: https://github.com/minio/minio/blob/master/docs/sts/etcd.md
	//Define endpoints to enable this section.
	etcd: {
		endpoints: [...string]
		pathPrefix:        string | *""
		corednsPathPrefix: string | *""
		clientCert:        string | *""
		clientCertKey:     string | *""
	}
}
