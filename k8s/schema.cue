package k8s

import "strings"

#KubernetesName: =~"^[a-z0-9][-a-z0-9]{0,251}[a-z0-9]?$"
#KubernetesResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
	}
	kind!:       string
	apiVersion!: string
	metadata!: {
		namespace?:  #KubernetesName
		name!:       #KubernetesName
		labels:      #Labels
		annotations: #Annotations
	}
	...
}

#Port: uint & <65536
#Labels: [string]:      string
#Annotations: [string]: string
