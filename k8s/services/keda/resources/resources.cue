package resources

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
