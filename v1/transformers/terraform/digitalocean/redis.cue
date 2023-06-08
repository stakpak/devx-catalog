package digitalocean

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	schema "guku.io/devx/v1/transformers/terraform"
	helpers "guku.io/devx/v1/transformers/terraform/digitalocean/helpers"
	"strconv"
)

#AddRedisCluster: v1.#Transformer & {
	traits.#Redis
	redis: _
	digitalocean: {
		providerVersion: string | *"2.28.1"
		region:          helpers.#Region
		databaseCluster: helpers.#DatabaseCluster & {
			engine: "redis"
		}
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
		resource: digitalocean_database_cluster: "\(redis.name)": {
			name:       redis.name
			region:     digitalocean.region
			version:    strconv.Atoi(redis.version) & <= 7 & >= 6 
			engine:     digitalocean.databaseCluster.engine
			node_count: digitalocean.databaseCluster.nodeCount
			size:       digitalocean.databaseCluster.nodeSize
		}
	}
}

#AddRedisClusterFirewallRules: v1.#Transformer & {
	traits.#Redis
	redis: _
	databaseFirewallRule: [
		...helpers.#DatabaseFirewallRule,
	]
	digitalocean: {
		providerVersion: string | *"2.28.1"
	}
	$resources: terraform: schema.#Terraform & {
		data: {
			for rule in databaseFirewallRule {
				if rule.kubernetes.name != _|_ {
					"digitalocean_kubernetes_cluster": "\(rule.kubernetes.name)": {
						name: "\(rule.kubernetes.name)"
					}
				}
				if rule.droplet.name != _|_ {
					"digitalocean_droplet": "\(rule.droplet.name)": {
						name: "\(rule.droplet.name)"
					}
				}
			}
		}
		terraform: {
			required_providers: {
				"digitalocean": {
					source:  "digitalocean/digitalocean"
					version: digitalocean.providerVersion
				}
			}
		}
		resource: digitalocean_database_firewall: "redis-\(redis.name)-rules": {
			cluster_id: "${data.digitalocean_database_cluster.\(redis.name).id}"
			rule: [
				for rule in databaseFirewallRule {
					{
						if rule.kubernetes.name != _|_ {
							type:  "k8s"
							value: "${data.digitalocean_kubernetes_cluster.\(rule.kubernetes.name).id}"
						}
						if rule.droplet.name != _|_ {
							type:  "droplet"
							value: "${data.digitalocean_droplet.\(rule.droplet.name).id}"
						}
						if rule.ip != _|_ {
							type:  "ip_addr"
							value: rule.ip
						}
					}
				},
			]
		}
	}
}
