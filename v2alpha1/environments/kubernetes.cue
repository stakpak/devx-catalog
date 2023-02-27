package environments

import (
	"guku.io/devx/v2alpha1"
	"guku.io/devx/v1/traits"
	"guku.io/devx/v1/transformers/kubernetes"
)

#Kubernetes: v2alpha1.#StackBuilder & {
	$metadata: builder: "Kubernetes"

	config: {
		defaultSecurityContext?: _
		namespace?:              string
		httpProbes?: {
			livenessProbe:  _
			readinessProbe: _
		}
		cmdProbes?: {
			livenessProbe:  _
			readinessProbe: _
		}
		routeResourceAPI: "IngressAPI" //| "GatewayAPI"
		enableHPA:        bool | *true
		gateway?:         traits.#GatewaySpec
	}

	components: {
		if config.gateway != _|_ {
			[string]: this={
				if this.http != _|_ {
					http: gateway: config.gateway
				}
			}
		}
	}

	flows: {
		// all resources transformers
		if config.namespace != _|_ {
			"k8s/add-namespace": pipeline: [kubernetes.#AddNamespace & {
				namespace: config.namespace
			}]
		}
		"k8s/add-labels": pipeline: [kubernetes.#AddLabels & {
			labels: [string]: string
		}]
		"k8s/add-annotations": pipeline: [kubernetes.#AddAnnotations & {
			annotations: [string]: string
		}]

		// pod spec
		"k8s/add-pod-labels": pipeline: [kubernetes.#AddPodLabels & {
			podLabels: [string]: string
		}]
		"k8s/add-pod-annotations": pipeline: [kubernetes.#AddPodAnnotations & {
			podAnnotations: [string]: string
		}]
		"k8s/add-pod-tolerations": pipeline: [kubernetes.#AddPodTolerations & {
			podTolerations: [...]
		}]
		if config.defaultSecurityContext != _|_ {
			"k8s/add-pod-securitycontext": pipeline: [kubernetes.#AddPodSecurityContext & {
				podSecurityContext: config.defaultSecurityContext
			}]
		}

		// workloads
		"k8s/add-deployment": pipeline: [kubernetes.#AddDeployment]
		"k8s/add-workload-volumes": pipeline: [kubernetes.#AddWorkloadVolumes]

		if config.httpProbes != _|_ {
			"k8s/add-workload-http-probes": {
				match: traits: Exposable: null
				pipeline: [kubernetes.#AddWorkloadProbes & {
					livenessProbe:  config.httpProbes.livenessProbe
					readinessProbe: config.httpProbes.readinessProbe
				}]
			}
		}
		if config.cmdProbes != _|_ {
			"k8s/add-workload-cmd-probes": {
				exclude: traits: Exposable: null
				pipeline: [kubernetes.#AddWorkloadProbes & {
					livenessProbe:  config.cmdProbes.livenessProbe
					readinessProbe: config.cmdProbes.readinessProbe
				}]
			}
		}

		// servers
		"k8s/add-service": pipeline: [kubernetes.#AddService]
		if config.routeResourceAPI == "IngressAPI" {
			"k8s/add-http-ingress": pipeline: [
				kubernetes.#AddIngress & kubernetes.#AddAnnotations,
			]
		}
		if config.routeResourceAPI == "GatewayAPI" {
		}

		// scaling
		"k8s/add-replicas": pipeline: [kubernetes.#AddReplicas]

		if config.enableHPA != _|_ {
			"k8s/add-hpa": pipeline: [kubernetes.#AddHPA & {
				hpaMetrics: [...] | *[
						{
						type: "Resource"
						resource: {
							name: "cpu"
							target: {
								type:               "Utilization"
								averageUtilization: 80
							}
						}
					},
					{
						type: "Resource"
						resource: {
							name: "memory"
							target: {
								type:               "Utilization"
								averageUtilization: 80
							}
						}
					},
				]
			}]
		}
	}
}
