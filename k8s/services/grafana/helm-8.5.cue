package grafana

import (
	"k8s.io/api/core/v1"
	"stakpak.dev/devx/k8s"
)

#KubeVersion: [=~"^8\\.5\\.1"]: minor: >=21
#Values: [=~"^8\\.5\\.1"]: {

    // Default values for deploying Grafana using Helm

    // Image settings
    image: {
      repository: string | *"grafana/grafana"
      tag: string | *"8.5.1"  // Specify the version you want to deploy
      pullPolicy: v1.#enumPullPolicy | *"IfNotPresent"
    }

    // Admin user configuration
    adminUser: string | *"admin"  // Default admin username
    adminPassword: string | *"admin"  // Default admin password
		existingSecret: string | *""

    // Service settings
	  service: {
	  	type: string | *"ClusterIP"
	  	port: k8s.#Port | *3000
	  }

    // Persistence settings
    persistence: {
      enabled: bool | *true  // Enable persistent storage
      size: string | *"10Gi"  // Size of persistent volume
		  storageClass: string | *""
		  accessMode:   string | *"ReadWriteOnce"
		  existingClaim: string | *""
    }

	  livenessProbe: {
		  enabled:             bool | *true
		  initialDelaySeconds: uint | *300
		  periodSeconds:       uint | *1
		  timeoutSeconds:      uint | *5
		  failureThreshold:    uint | *3
		  successThreshold:    uint | *1
	  }

  	readinessProbe: {
	  	enabled:             bool | *true
	  	initialDelaySeconds: uint | *30
	  	periodSeconds:       uint | *10
	  	timeoutSeconds:      uint | *1
	  	failureThreshold:    uint | *3
	  	successThreshold:    uint | *1
	  }

    // Ingress settings
    ingress:{ 
      enabled: bool | *false  // Enable ingress to expose Grafana externally
		  annotations: k8s.#Annotations
      hosts: string | *"grafana.local"  // Example hostname for your ingress
		  tls: bool | *false
    }

	  resources: v1.#ResourceRequirements | *{}

    // Dashboard provisioning (optional)
    dashboards: {
      enabled: bool | *true  // Enable provisioning of dashboards
      defaultFolderName: string | *"grafana-dashboards"  // Default folder for imported dashboards
      dashboardProviders: [{
        name: string | *"default"  // Name of the dashboard provider
        orgId: int | *1  // Organization ID
        folder: string | *""  // Folder for dashboards
        type: string | *"file"  // Provider type (e.g., file)
        disableDeletion: bool | *false  // Disable dashboard deletion
        editable: bool | *true  // Whether the dashboards are editable
        updateIntervalSeconds: int | *10  // Time interval for updates in seconds
        options: {
          path: string | *"/var/lib/grafana/dashboards"  // Path for the dashboards
        }
      }]
    }

    // Datasource provisioning (optional)
    datasources: {
      enabled: bool | *true  // Enable provisioning of datasources
      datasources: [{
        name: string | *"Prometheus"  // Name of the datasource
        type: string | *"prometheus"  // Type of the datasource
        url: string & =~"^http(s)?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$" | *"http://prometheus:9090" | "https://prometheus:9090"  // URL with validation and two default options
        access: string | *"proxy"  // Access mode for the datasource
        isDefault: bool | *true  // Marks the datasource as the default one
      }]
    }


    // Node selector, tolerations, and affinity for pod scheduling
	  affinity: v1.#Affinity
	  nodeSelector: k8s.#Labels
	  tolerations: [...v1.#Toleration]

    // Annotations for Grafana pod
		podAnnotations: k8s.#Annotations

    // Additional volumes and volume mounts
		extraVolumes: [...v1.#Volume]
	  extraVolumeMounts: [...v1.#VolumeMount]
}