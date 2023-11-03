package resources

import "strings"

#KubernetesResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "\(apiVersion)/\(strings.ToLower(kind))"
		...
	}
	apiVersion: string
	kind:       string
}

#ScaledObject: {
	#KubernetesResource
	apiVersion: "keda.sh/v1alpha1"
	kind:       "ScaledObject"
}

#CPUTrigger: {
	type:       "cpu"
	metricType: "Utilization" | "AverageValue"
	metadata: {
		value:          string
		containerName?: string
	}
}

#MemoryTrigger: {
	type:       "memory"
	metricType: "Utilization" | "AverageValue"
	metadata: {
		value:          string
		containerName?: string
	}
}

#RabbitMQTrigger: {
	type: "rabbitmq"
	metadata: {
		value:            string
		queueName:        string
		mode:             "QueueLength" | "MessageRate"
		protocol?:        "amqp" | "http"
		activationValue?: string
		vhostName?:       string
		host?:            string
		hostFromEnv?:     string
		authenticationRef?: {
			name: string
		}
	}
}
