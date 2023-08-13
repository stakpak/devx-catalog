package azure

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	helpers "stakpak.dev/devx/v1/transformers/terraform/azure/helpers"
)

#AddKubernetesCluster: v1.#Transformer & {
	traits.#KubernetesCluster
	k8s: _
	k8s: version: major: 1
	k8s: version: minor: <=26 & >=24
	azure: {
		providerVersion:   string | *"3.69.0"
		location:          helpers.#Location
		resourceGroupName: string | *"k8s-rg"
		aks: {
			nodeSize:      string | *"Standard_D2_v2"
			nodeCount:     uint | *1
			nodeAutoScale: bool | *true
		}
		...
	}
	$resources: terraform: schema.#Terraform & {
		data: "azurerm_kubernetes_service_versions": "\(k8s.name)": {
			version_prefix: "\(k8s.version.major).\(k8s.version.minor)."
			location:       azure.location
		}
		terraform: {
			required_providers: {
				"azurerm": {
					source:  "hashicorp/azurerm"
					version: azure.providerVersion
				}
			}
		}
		resource: {
			azurerm_resource_group: "\(k8s.name)-resource-group": {
				name:     azure.resourceGroupName
				location: azure.location
			}
			azurerm_kubernetes_cluster: "\(k8s.name)": {
				name:                k8s.name
				location:            azure.location
				resource_group_name: "${azurerm_resource_group.\(k8s.name).name}"
				version:             "${data.azurerm_kubernetes_service_versions.\(k8s.name).latest_version}"
				default_node_pool: {
					{
						name:                "worker-pool-1"
						vm_size:             azure.aks.nodeSize
						node_count:          azure.aks.nodeCount
						enable_auto_scaling: azure.aks.nodeAutoScale
						tags: [
							"worker-pool-1",
						]
						temporary_name_for_rotation: "temp-worker-pool-1"
					}
				}
			}
		}
	}
}

#AddHelmProvider: v1.#Transformer & {
	traits.#Helm
	k8s: {
		name: string
		...
	}
	azure: {
		providerVersion:   string | *"3.69.0"
		resourceGroupName: string | *"k8s-rg"
		...
	}
	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"azurerm": {
					source:  "hashicorp/azurerm"
					version: azure.providerVersion
				}
			}
		}
		data: azurerm_kubernetes_cluster: "\(k8s.name)": {
			name:                k8s.name
			resource_group_name: azure.resourceGroupName
		}
		provider: helm: kubernetes: {
			host:                   "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].host}"
			username:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].username}"
			password:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].password}"
			client_certificate:     "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_certificate)}"
			client_key:             "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_key)}"
			cluster_ca_certificate: "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].cluster_ca_certificate)}"
		}
	}
}

#AddKubernetesProvider: v1.#Transformer & {
	k8s: {
		name: string
		...
	}
	azure: {
		providerVersion:   string | *"3.69.0"
		resourceGroupName: string | *"k8s-rg"
		...
	}
	$resources: terraform: schema.#Terraform & {
		terraform: {
			required_providers: {
				"azurerm": {
					source:  "hashicorp/azurerm"
					version: azure.providerVersion
				}
			}
		}
		data: azurerm_kubernetes_cluster: "\(k8s.name)": {
			name:                k8s.name
			resource_group_name: azure.resourceGroupName
		}
		provider: kubernetes: {
			host:                   "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].host}"
			username:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].username}"
			password:               "${data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].password}"
			client_certificate:     "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_certificate)}"
			client_key:             "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].client_key)}"
			cluster_ca_certificate: "${base64decode(data.azurerm_kubernetes_cluster.\(k8s.name).kube_config[0].cluster_ca_certificate)}"
		}
	}
}
