package digitalocean

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	helpers "stakpak.dev/devx/v1/transformers/terraform/digitalocean/helpers"
	"strconv"
	"strings"
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
	redis: host:           "<unknown>"
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
			version:    strconv.Atoi(strings.SplitN(redis.version, ".", 2)[0]) & <=7 & >=6
			engine:     digitalocean.databaseCluster.engine
			node_count: digitalocean.databaseCluster.nodeCount
			size:       digitalocean.databaseCluster.size
		}

		output: {
			"digitalocean_database_cluster_\(redis.name)_host": value:         "${digitalocean_database_cluster.\(redis.name).host}"
			"digitalocean_database_cluster_\(redis.name)_private_host": value: "${digitalocean_database_cluster.\(redis.name).private_host}"
			"digitalocean_database_cluster_\(redis.name)_uri": {
				value:     "${digitalocean_database_cluster.\(redis.name).uri}"
				sensitive: true
			}
			"digitalocean_database_cluster_\(redis.name)_private_uri": {
				value:     "${digitalocean_database_cluster.\(redis.name).private_uri}"
				sensitive: true
			}
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
		...
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
			cluster_id: "${digitalocean_database_cluster.\(redis.name).id}"
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
