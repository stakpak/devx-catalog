package prometheus

#KubeVersion: [=~"^25\\.26\\.0"]: minor: >=21
#Values: [=~"^25\\.26\\.0"]: {

  rbac: create: bool | *true
  podSecurityPolicy: enabled: bool | *false
  imagePullSecrets: [...{ name: string }]
  serviceAccounts: { 
    server: {
  	create: bool | *true
  	name: string | *""
  	annotations: [string]: string
    }
  }
  commonMetaLabels: [string]: string
  configmapReload: {
  	reloadUrl: string | *""
  	env: [...{
  		name: string
  		value: string | *""
  		valueFrom: {
  			secretKeyRef: {
  				name: string
  				key: string
  				optional: bool | *false
  			}
  		}
  	}]
  	prometheus: {
  		enabled: bool | *true
  		name: string | *"configmap-reload"
  		image: {
  			repository: string | *"quay.io/prometheus-operator/prometheus-config-reloader"
  			tag: string | *"latest"
  			digest: string | *""
  			pullPolicy: string | *"IfNotPresent"
  		}
  		containerPort: int | *8080
  		containerPortName: string | *"metrics"
  		extraArgs: [string]: string
  		extraVolumeDirs: [string]: string
  		extraVolumeMounts: [string]: string
  		extraConfigmapMounts: [...{
  			name: string
  			mountPath: string
  			subPath: string
  			configMap: string
  			readOnly: bool | *true
  		}]
  		containerSecurityContext: [string]: string
  		livenessProbe: {
  			httpGet: {
  				path: string | *"/healthz"
  				port: int | *8080
  				scheme: string | *"HTTP"
  			}
  			periodSeconds: int | *10
  			initialDelaySeconds: int | *2
  		}
  		readinessProbe: {
  			httpGet: {
  				path: string | *"/healthz"
  				port: int | *8080
  				scheme: string | *"HTTP"
  			}
  			periodSeconds: int | *10
  		}
  		startupProbe: {
  			enabled: bool | *false
  			httpGet: {
  				path: string | *"/healthz"
  				port: int | *8080
  				scheme: string | *"HTTP"
  			}
  			periodSeconds: int | *10
  		}
  		resources: [string]: string
  	}
  }

  server: {
  	name: string | *"server"
  	image: {
  		repository: string | *"quay.io/prometheus/prometheus"
  		tag: string | *""
  		digest: string | *""
  		pullPolicy: string | *"IfNotPresent"
  	}
  	global: {
  		scrape_interval: string | *"1m"
  		scrape_timeout: string | *"10s"
  		evaluation_interval: string | *"1m"
  	}
  	resources: {
  		limits: {
  			cpu: string | *"500m"
  			memory: string | *"512Mi"
  		}
  		requests: {
  			cpu: string | *"500m"
  			memory: string | *"512Mi"
  		}
  	}
  	podSecurityContext: {
  		runAsUser: int | *65534
  		runAsNonRoot: bool | *true
  		fsGroup: int | *65534
  	}
  	service: {
  		enabled: bool | *true
  		type: string | *"ClusterIP"
  		servicePort: int | *80
  	}
  	ingress: {
  		enabled: bool | *false
  		annotations: [string]: string
  		hosts: [...string]
  		path: string | *"/"
  		tls: [...{
  			secretName: string
  			hosts: [...string]
  		}]
  	}
  	persistentVolume: {
  		enabled: bool | *true
  		size: string | *"8Gi"
  		storageClass: string | *""
  		accessModes: [...string] | *["ReadWriteOnce"]
  		mountPath: string | *"/data"
  	}
  	alertmanager: {
  		enabled: bool | *true
  		persistence: {
  			enabled: bool | *true
  			size: string | *"2Gi"
  		}
  	}
  	kubeStateMetrics: enabled: bool | *true
  	nodeExporter: enabled: bool | *true
  	pushGateway: enabled: bool | *true
  }
}