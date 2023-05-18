package k8s

#KubernetesName: =~"^[a-z0-9][-a-z0-9]{0,251}[a-z0-9]?$"
#KubernetesResource: {
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
