package digitalocean

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	helpers "stakpak.dev/devx/v1/transformers/terraform/digitalocean/helpers"
)

#AddKubernetesCluster: v1.#Transformer & {
	traits.#KubernetesCluster
	k8s: _
	k8s: version: major: 1
	k8s: version: minor: <=26 & >=24
	digitalocean: {
		providerVersion: string | *"2.28.1"
		region:          helpers.#Region
		doks: {
			nodeSize:      *"s-1vcpu-2gb" | "s-2vcpu-2gb" | "s-1vcpu-3gb" | "s-2vcpu-4gb" | "c-2" | "s-4vcpu-8gb" | "g-2vcpu-8gb" | "gd-2vcpu-8gb" | "c-4" | "s-6vcpu-16gb" | "g-4vcpu-16gb" | "gd-4vcpu-16gb" | "c-8" | "s-8vcpu-32gb" | "g-8vcpu-32gb" | "gd-8vcpu-32gb" | "c-16" | "s-12vcpu-48gb" | "s-16vcpu-64gb" | "g-16vcpu-64gb" | "gd-16vcpu-64gb" | "c-32" | "s-20vcpu-96gb" | "s-24vcpu-128gb" | "g-32vcpu-128gb" | "gd-32vcpu-128gb" | "g-40vcpu-160gb" | "gd-40vcpu-160gb" | "s-32vcpu-192gb"
			minSize:       uint | *1
			maxSize:       uint | *2
			nodeAutoScale: bool | *true
			autoUpgrade:   bool | *true
			ha:            bool | *true
		}
		...
	}
	$resources: terraform: schema.#Terraform & {
		data: "digitalocean_kubernetes_versions": "\(k8s.name)": {
			version_prefix: "\(k8s.version.major).\(k8s.version.minor)."
		}
		terraform: {
			required_providers: {
				"digitalocean": {
					source:  "digitalocean/digitalocean"
					version: digitalocean.providerVersion
				}
			}
		}
		resource: digitalocean_kubernetes_cluster: "\(k8s.name)": {
			name:         k8s.name
			region:       digitalocean.region
			version:      "${data.digitalocean_kubernetes_versions.\(k8s.name).latest_version}"
			auto_upgrade: digitalocean.doks.autoUpgrade
			ha:           digitalocean.doks.ha
			node_pool: [
				{
					name:       "worker-pool-1"
					size:       digitalocean.doks.nodeSize
					auto_scale: digitalocean.doks.nodeAutoScale
					min_nodes:  digitalocean.doks.minSize
					max_nodes:  digitalocean.doks.maxSize
					tags: [
						"worker-pool-1",
					]
				},
			]
		}
	}
}

#AddHelmProvider: v1.#Transformer & {
	traits.#Helm
	k8s: {
		name: string
		...
	}
	digitalocean: {
		providerVersion: string | *"2.28.1"
		...
	}
	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"digitalocean": {
					source:  "digitalocean/digitalocean"
					version: digitalocean.providerVersion
				}
			}
		}
		data: digitalocean_kubernetes_cluster: "\(k8s.name)": name: k8s.name
		provider: helm: kubernetes: {
			host:                   "${data.digitalocean_kubernetes_cluster.\(k8s.name).endpoint}"
			token:                  "${data.digitalocean_kubernetes_cluster.\(k8s.name).kube_config[0].token}"
			cluster_ca_certificate: "${base64decode(data.digitalocean_kubernetes_cluster.\(k8s.name).kube_config[0].cluster_ca_certificate)}"
		}
	}
}

#AddKubernetesProvider: v1.#Transformer & {
	k8s: {
		name: string
		...
	}
	digitalocean: {
		providerVersion: string | *"2.28.1"
		...
	}
	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"digitalocean": {
					source:  "digitalocean/digitalocean"
					version: digitalocean.providerVersion
				}
			}
		}
		data: digitalocean_kubernetes_cluster: "\(k8s.name)": name: k8s.name
		provider: kubernetes: {
			host:                   "${data.digitalocean_kubernetes_cluster.\(k8s.name).endpoint}"
			token:                  "${data.digitalocean_kubernetes_cluster.\(k8s.name).kube_config[0].token}"
			cluster_ca_certificate: "${base64decode(data.digitalocean_kubernetes_cluster.\(k8s.name).kube_config[0].cluster_ca_certificate)}"
		}
	}
}
