package grafana

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^8\\.5\\.1"]: minor: >=21
#Values: [=~"^8\\.5\\.1"]: {

	global: {
		imageRegistry: string | *null
		imagePullSecrets: [...string] | *[]
	}
	rbac: {
		create: bool | *true
		pspEnabled: bool | *false
		pspUseAppArmor: bool | *false
		namespaced: bool | *false
		extraRoleRules: [...{}] | *[]
		extraClusterRoleRules: [...{}] | *[]
	}
	serviceAccount: {
		create: bool | *true
		name: string | *null
		nameTest: string | *null
		labels: {} | *{}
		automountServiceAccountToken: bool | *false
	}
	replicas: int | *1
	headlessService: bool | *false
	automountServiceAccountToken: bool | *true
	autoscaling: {
		enabled: bool | *false
		minReplicas: int | *1
		maxReplicas: int | *5
		targetCPU: string | *"60"
		targetMemory: string | *""
		behavior: {} | *{}
	}
	podDisruptionBudget: {} | *{}
	deploymentStrategy: {
		type: string | *"RollingUpdate"
	}
	readinessProbe: {
		httpGet: {
			path: string | *"/api/health"
			port: int | *3000
		}
	}
	livenessProbe: {
		httpGet: {
			path: string | *"/api/health"
			port: int | *3000
		}
		initialDelaySeconds: int | *60
		timeoutSeconds: int | *30
		failureThreshold: int | *10
	}
	image: {
		registry: string | *"docker.io"
		repository: string | *"grafana/grafana"
		tag: string | *"latest"
		sha: string | *""
		pullPolicy: v1.PullPolicy | *"IfNotPresent"
		pullSecrets: [...string] | *[]
	}
	testFramework: {
		enabled: bool | *true
		image: {
			registry: string | *"docker.io"
			repository: string | *"bats/bats"
			tag: string | *"v1.4.1"
		}
		imagePullPolicy: v1.PullPolicy | *"IfNotPresent"
		securityContext: {} | *{}
		resources: {} | *{}
	}
	dnsPolicy: string | *null
	dnsConfig: {} | *{}
	securityContext: {
		runAsNonRoot: bool | *true
		runAsUser: int | *472
		runAsGroup: int | *472
		fsGroup: int | *472
	}
	containerSecurityContext: {
		allowPrivilegeEscalation: bool | *false
		capabilities: {
			drop: [...string] | *["ALL"]
		}
		seccompProfile: {
			type: string | *"RuntimeDefault"
		}
	}
	createConfigmap: bool | *true
	extraConfigmapMounts: [...{}] | *[]
	extraEmptyDirMounts: [...{}] | *[]
	extraLabels: {} | *{}
	downloadDashboardsImage: {
		registry: string | *"docker.io"
		repository: string | *"curlimages/curl"
		tag: string | *"7.85.0"
		sha: string | *""
		pullPolicy: v1.PullPolicy | *"IfNotPresent"
	}
	downloadDashboards: {
		env: {} | *{}
		envFromSecret: string | *""
		resources: {} | *{}
		securityContext: {
			allowPrivilegeEscalation: bool | *false
			capabilities: {
				drop: [...string] | *["ALL"]
			}
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
		}
		envValueFrom: {} | *{}
	}
	service: {
		enabled: bool | *true
		type: string | *"ClusterIP"
		ipFamilyPolicy: string | *""
		ipFamilies: [...string] | *[]
		loadBalancerIP: string | *""
		loadBalancerClass: string | *""
		loadBalancerSourceRanges: [...string] | *[]
		port: int | *80
		targetPort: int | *3000
		annotations:      k8s.#Annotations | *null
		labels: {} | *{}
		portName: string | *"service"
		appProtocol: string | *""
	}
	serviceMonitor: {
		enabled: bool | *false
		path: string | *"/metrics"
		labels: {} | *{}
		interval: string | *"30s"
		scheme: string | *"http"
		tlsConfig: {} | *{}
		scrapeTimeout: string | *"30s"
		relabelings: [...{}] | *[]
		metricRelabelings: [...{}] | *[]
		targetLabels: [...string] | *[]
	}
	extraExposePorts: [...{}] | *[]
	hostAliases: [...{}] | *[]
	ingress: {
		enabled: bool | *false
		annotations:      k8s.#Annotations | *null
		labels: {} | *{}
		path: string | *"/"
		pathType: string | *"Prefix"
		hosts: [...string] | *["chart-example.local"]
		extraPaths: [...{}] | *[]
		tls: [...{}] | *[]
	}
	resources: {} | *{}
	nodeSelector: {} | *{}
	tolerations: [...{}] | *[]
	affinity: {} | *{}
	topologySpreadConstraints: [...{}] | *[]
	extraInitContainers: [...{}] | *[]
	extraContainers: string | *""
	extraContainerVolumes: [...{}] | *[]
	extraVolumeMounts: [...{}] | *[]
	extraVolumes: [...{}] | *[]
	persistence: {
		type: string | *"pvc"
		enabled: bool | *false
		accessModes: [...string] | *["ReadWriteOnce"]
		size: string | *"10Gi"
		finalizers: [...string] | *["kubernetes.io/pvc-protection"]
		extraPvcLabels: {} | *{}
		disableWarning: bool | *false
		inMemory: {
			enabled: bool | *false
		}
		lookupVolumeName: bool | *true
	}
	initChownData: {
		enabled: bool | *true
		image: {
			registry: string | *"docker.io"
			repository: string | *"library/busybox"
			tag: string | *"1.31.1"
			sha: string | *""
			pullPolicy: v1.PullPolicy | *"IfNotPresent"
		}
		resources: {} | *{}
		securityContext: {
			runAsNonRoot: bool | *false
			runAsUser: int | *0
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
			capabilities: {
				add: [...string] | *["CHOWN"]
			}
		}
	}
	adminUser: string | *"admin"
	adminPassword: string | *"admin"
	admin: {
		existingSecret: string | *""
		userKey: string | *"admin-user"
		passwordKey: string | *"admin-password"
	}
	command: [...string] | *null
	args: [...string] | *null
	env: {} | *{}
	envValueFrom: {} | *{}
	envFromSecret: string | *""
	envRenderSecret: {} | *{}
	envFromSecrets: [...{}] | *[]
	envFromConfigMaps: [...{}] | *[]
	enableServiceLinks: bool | *true
	extraSecretMounts: [...{}] | *[]
	extraVolumeMounts: [...{}] | *[]
	extraVolumes: [...{}] | *[]
	lifecycleHooks: {} | *{}
	plugins: [...string] | *[]
	datasources: {
		enabled: bool | *false
	}
	alerting: {} | *{}
	notifiers: {} | *{}
	dashboardProviders: {} | *{}
	dashboards: {} | *{}
	dashboardsConfigMaps: {} | *{}
	grafana_ini: {
		paths: {
			data: string | *"/var/lib/grafana/"
			logs: string | *"/var/log/grafana"
			plugins: string | *"/var/lib/grafana/plugins"
			provisioning: string | *"/etc/grafana/provisioning"
		}
		analytics: {
			check_for_updates: bool | *true
		}
		log: {
			mode: string | *"console"
		}
		grafana_net: {
			url: string | *"https://grafana.net"
		}
		server: {
			domain: string | *""
		}
	}
	ldap: {
		enabled: bool | *false
		existingSecret: string | *""
		config: string | *""
	}
	smtp: {
		existingSecret: string | *""
		userKey: string | *"user"
		passwordKey: string | *"password"
	}
	sidecar: {
		image: {
			registry: string | *"quay.io"
			repository: string | *"kiwigrid/k8s-sidecar"
			tag: string | *"1.27.4"
			sha: string | *""
			pullPolicy: v1.PullPolicy | *"IfNotPresent"
		}
		resources: {} | *{}
		securityContext: {
			allowPrivilegeEscalation: bool | *false
			capabilities: {
				drop: [...string] | *["ALL"]
			}
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
		}
		alerts: {
			enabled: bool | *false
			env: {} | *{}
			label: string | *"grafana_alert"
			labelValue: string | *""
			searchNamespace: string | *null
			watchMethod: string | *"WATCH"
			resource: string | *"both"
			reloadURL: string | *"http://localhost:3000/api/admin/provisioning/alerting/reload"
			skipReload: bool | *false
			initAlerts: bool | *false
		}
		dashboards: {
			enabled: bool | *false
			env: {} | *{}
			SCProvider: bool | *true
			label: string | *"grafana_dashboard"
			labelValue: string | *""
			folder: string | *"/tmp/dashboards"
			defaultFolderName: string | *null
			searchNamespace: string | *null
			watchMethod: string | *"WATCH"
			resource: string | *"both"
			folderAnnotation: string | *null
			reloadURL: string | *"http://localhost:3000/api/admin/provisioning/dashboards/reload"
			skipReload: bool | *false
		}
		datasources: {
			enabled: bool | *false
			env: {} | *{}
			label: string | *"grafana_datasource"
			labelValue: string | *""
			searchNamespace: string | *null
			watchMethod: string | *"WATCH"
			resource: string | *"both"
			reloadURL: string | *"http://localhost:3000/api/admin/provisioning/datasources/reload"
			skipReload: bool | *false
			initDatasources: bool | *false
		}
		plugins: {
			enabled: bool | *false
			env: {} | *{}
			label: string | *"grafana_plugin"
			labelValue: string | *""
			searchNamespace: string | *null
			watchMethod: string | *"WATCH"
			resource: string | *"both"
			reloadURL: string | *"http://localhost:3000/api/admin/provisioning/plugins/reload"
			skipReload: bool | *false
			initPlugins: bool | *false
		}
		notifiers: {
			enabled: bool | *false
			env: {} | *{}
			label: string | *"grafana_notifier"
			labelValue: string | *""
			searchNamespace: string | *null
			watchMethod: string | *"WATCH"
			resource: string | *"both"
			reloadURL: string | *"http://localhost:3000/api/admin/provisioning/notifications/reload"
			skipReload: bool | *false
			initNotifiers: bool | *false
		}
	}
	namespaceOverride: string | *""
	revisionHistoryLimit: int | *10
	imageRenderer: {
		deploymentStrategy: {} | *{}
		enabled: bool | *false
		replicas: int | *1
		autoscaling: {
			enabled: bool | *false
			minReplicas: int | *1
			maxReplicas: int | *5
			targetCPU: string | *"60"
			targetMemory: string | *""
			behavior: {} | *{}
		}
		serverURL: string | *""
		renderingCallbackURL: string | *""
		image: {
			registry: string | *"docker.io"
			repository: string | *"grafana/grafana-image-renderer"
			tag: string | *"latest"
			sha: string | *""
			pullPolicy: v1.PullPolicy | *"Always"
		}
		env: {
			HTTP_HOST: string | *"0.0.0.0"
		}
		envValueFrom: {} | *{}
		serviceAccountName: string | *""
		securityContext: {} | *{}
		containerSecurityContext: {
			seccompProfile: {
				type: string | *"RuntimeDefault"
			}
			capabilities: {
				drop: [...string] | *["ALL"]
			}
			allowPrivilegeEscalation: bool | *false
			readOnlyRootFilesystem: bool | *true
		}
		service: {
			enabled: bool | *true
			portName: string | *"http"
			port: int | *8081
			targetPort: int | *8081
			appProtocol: string | *""
		}
		serviceMonitor: {
			enabled: bool | *false
			path: string | *"/metrics"
			labels: {} | *{}
			interval: string | *"1m"
			scheme: string | *"http"
			tlsConfig: {} | *{}
			scrapeTimeout: string | *"30s"
			relabelings: [...{}] | *[]
			targetLabels: [...string] | *[]
		}
		grafanaProtocol: string | *"http"
		grafanaSubPath: string | *""
		podPortName: string | *"http"
		revisionHistoryLimit: int | *10
		networkPolicy: {
			limitIngress: bool | *true
			limitEgress: bool | *false
			extraIngressSelectors: [...{}] | *[]
		}
		resources: {} | *{}
		nodeSelector: {} | *{}
		tolerations: [...{}] | *[]
		affinity: {} | *{}
		extraConfigmapMounts: [...{}] | *[]
		extraSecretMounts: [...{}] | *[]
		extraVolumeMounts: [...{}] | *[]
		extraVolumes: [...{}] | *[]
	}
	networkPolicy: {
		enabled: bool | *false
		ingress: bool | *true
		allowExternal: bool | *true
		explicitNamespacesSelector: {} | *{}
		egress: {
			enabled: bool | *false
			blockDNSResolution: bool | *false
			ports: [...{}] | *[]
			to: [...{}] | *[]
		}
	}
	enableKubeBackwardCompatibility: bool | *false
	useStatefulSet: bool | *false
	extraObjects: [...{}] | *[]
	assertNoLeakedSecrets: bool | *true
}