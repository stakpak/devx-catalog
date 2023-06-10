package helpers

import "net"

#Region: "nyc1" | "nyc3" | "ams3" | "sfo3" | "sgp1" | "lon1" | "fra1" | "tor1" | "blr1" | "syd1"

#DatabaseCluster: {
	engine:    "pg" | "mysql" | "redis" | "mongodb"
	size:      *"db-s-1vcpu-1gb" | "db-s-1vcpu-2gb" | "db-s-2vcpu-4gb" | "db-s-4vcpu-8gb" | "db-s-6vcpu-16gb" | "db-s-8vcpu-32gb" | "db-s-16vcpu-64gb" | "gd-2vcpu-8gb" | "gd-4vcpu-16gb" | "gd-8vcpu-32gb" | "gd-16vcpu-64gb" | "gd-32vcpu-128gb" | "gd-40vcpu-160gb" | "so1_5-2vcpu-16gb" | "so1_5-4vcpu-32gb" | "so1_5-8vcpu-64gb" | "so1_5-16vcpu-128gb" | "so1_5-24vcpu-192gb" | "so1_5-32vcpu-256gb" | "m-2vcpu-16gb" | "m-4vcpu-32gb" | "m-8vcpu-64gb" | "m-16vcpu-128gb" | "m-24vcpu-192gb" | "m-32vcpu-256gb"
	nodeCount: int | *1
}

#DatabaseFirewallRule: {
	kubernetes: name: string
} | {
	droplet: name: string
} | {
	ip: net.IP
}
