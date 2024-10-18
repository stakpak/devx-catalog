package prometheus

import (
	"k8s.io/api/core/v1"
)

#KubeVersion: [=~"^25\\.26\\.0"]: minor: >=21
#Values: [=~"^25\\.26\\.0"]: {

	// RBAC settings
	rbac: create: bool | *true
	
	// Pod Security Policy settings
	podSecurityPolicy: enabled: bool | *false
	
	// Image pull secrets for Prometheus deployment
	imagePullSecrets: [...v1.#LocalObjectReference]
	
	// Service Account configuration
	#ServiceAccount: {
		// Specifies whether a service account should be created.
		create: bool | *true
		// Annotations for the service account.
		annotations: [string]: string
		// Extra labels for the service account.
		extraLabels: [string]: string
		// Name of the service account to use.
		name: string | *""
	}

	// Common meta labels
	commonMetaLabels: [string]: string

	// ConfigMap reload settings
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
			containerSecurityContext: v1.#SecurityContext
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
			resources: v1.#ResourceRequirements
		}
	}

	// Prometheus server settings
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
		
		// Pod security context
		podSecurityContext: v1.#PodSecurityContext

		// Service configuration
		service: {
			enabled: bool | *true
			type: string | *"ClusterIP"
			servicePort: int | *80
		}
		
		// Ingress configuration
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

		// Persistent volume configuration
		persistentVolume: {
			enabled: bool | *true
			size: string | *"8Gi"
			storageClass: string | *""
			accessModes: [...string] | *["ReadWriteOnce"]
			mountPath: string | *"/data"
		}

		// Alertmanager settings
		alertmanager: {
			enabled: bool | *true
			persistence: {
				enabled: bool | *true
				size: string | *"2Gi"
			}
		}

		// Additional monitoring components
		kubeStateMetrics: enabled: bool | *true
		nodeExporter: enabled: bool | *true
		pushGateway: enabled: bool | *true
	}
}
