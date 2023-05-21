package imagepullsecrets

#KubeVersion: [=~"^0\\.3\\."]: minor: >=21
#Values: [=~"^0\\.3\\."]: {
	replicas: int | *1
	istio: {
		revision: string | *""
	}
	podAnnotations: [string]: string | *{}
	podSecurityContext: {
		runAsNonRoot: bool | *true
		seccompProfile: {
			type: string | *"RuntimeDefault"
		}
	}
	securityContext: {
		allowPrivilegeEscalation: bool | *false
		capabilities: {
			drop: [string] | *["ALL"]
		}
	}
	image: {
		repository: string | *"ghcr.io/banzaicloud/imagepullsecrets"
		tag:        string | *"v0.3.12"
		pullPolicy: string | *"IfNotPresent"
	}
	imagePullSecrets: []
	nodeSelector: {[string]: string} | *{}
	affinity:     {[string]: string} | *{}
	tolerations: []
	resources: {
		requests: {
			memory: string | *"100Mi"
			cpu:    string | *"100m"
		}
		limits: {
			memory: string | *"200Mi"
			cpu:    string | *"300m"
		}
	}
	service: {
		type: string | *"ClusterIP"
		port: int | *8080
	}
	serviceAccount: {
		annotations: {string: string} | *{}
	}
	serviceMonitor: {
		scrapeInterval: string | *"5s"
		tlsConfig:      {string: string} | *{}
	}
	developmentMode: {
		enabled: bool | *false
	}
	podDisruptionBudget: {
		enabled: bool | *false
	}
	log: {
		level: "panic" | "fatal" | "error" | "warn" | "warning" | "info" | "debug" | "trace"
	} | *{}
	env: {string: string} | *{}

	defaultConfig: {
		enabled:            bool | *false
		targetSecretName:   string | *"default-secret-name"
		namespaces:         {string: string} | *{}
		namespacesWithPods: [string] | *[]
		credentials:        [string] | *[]
	}

	defaultSecret: {
		enabled:    bool | *false
		secretData: {string: string} | *{}
		type:       string | *""
	}

}
