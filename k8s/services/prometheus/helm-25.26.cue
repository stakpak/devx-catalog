package prometheus

#KubeVersion: [=~"^25\\.26\\.0"]: minor: >=21
#Values: [=~"^25\\.26\\.0"]: {

    image: {
      repository:    string | *"quay.io/prometheus/prometheus"
      tag:           string | *"latest"        // Change to the desired Prometheus version
      pullPolicy:    string | *"IfNotPresent"  // Options: Always, IfNotPresent
    }

    service: {
      enabled:       bool   | *true
      type:          string | *"ClusterIP"     // Options: ClusterIP, NodePort, LoadBalancer
      port:          int    | *9090            // Default Prometheus service port
    }

    retention:       string | *"15d"           // Data retention period (e.g., 15 days)

    persistentVolume: {
      enabled:       bool   | *true            // Enable persistent storage
      size:          string | *"10Gi"           // Persistent Volume size
      storageClass:  string | *""              // Set the StorageClass, leave empty for default
      accessModes:   [string] | *["ReadWriteOnce"]
    }

    resources: {
      requests: {
        cpu:         string | *"500m"
        memory:      string | *"512Mi"
      }
      limits: {
        cpu:         string | *"1"
        memory:      string | *"1Gi"
      }
    }

    alertmanager: {
      enabled:       bool   | *true            // Enable Alertmanager
      persistence: {
        enabled:     bool   | *true
        size:        string | *"2Gi"           // Size of the persistent volume for Alertmanager
      }
    }

    rbac: {
      create:        bool   | *true            // Enable RBAC roles and bindings
    }

    global: {
      scrape_interval:        string | *"1m"   // Frequency of scraping metrics
      scrape_timeout:         string | *"10s"  // Timeout for a scrape request
      evaluation_interval:    string | *"1m"   // Frequency of rule evaluations
    }

    securityContext: {
      runAsUser:               int | *65534
      runAsNonRoot:            bool | *true
      fsGroup:                 int | *65534    // File system group for volume mounts
    }

    ingress: {
      enabled:       bool   | *false           // Enable Ingress to expose Prometheus externally
      annotations:   [string]: string | *{}
      hosts:         [...string] | *[]
      path:          string | *"/"
      tls:           [...string] | *[]
    }

    serviceAccounts: {
      server: {
        create:      bool   | *true
        name:        string | *""              // Leave empty to use default ServiceAccount
      }
    }
}