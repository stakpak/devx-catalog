package traits

import (
	"list"
	"stakpak.dev/devx/v1"
)

// a component that runs containers
#Workload: v1.#Trait & {
	$metadata: traits: Workload: null

	containers: [string]: #ContainerSpec & {
		image: string
		command: [...string]
		args: [...string]
		env: [string]: string | v1.#Secret
		mounts: [...{
			volume: #VolumeSpec & {
				local:       string
				secret?:     _|_
				ephemeral?:  _|_
				persistent?: _|_
			} | {
				ephemeral:   string
				local?:      _|_
				secret?:     _|_
				persistent?: _|_
			} | {
				persistent: string
				ephemeral?: _|_
				local?:     _|_
				secret?:    _|_
			} | {
				secret:      v1.#Secret
				ephemeral?:  _|_
				local?:      _|_
				persistent?: _|_
			}
			path:     string
			readOnly: bool | *true
		}]
		resources: {
			requests?: {
				cpu?:    string
				memory?: string
			}
			limits?: {
				cpu?:    string
				memory?: string
			}
		}
	}
	containers: default: _
	restart: "onfail" | "never" | *"always"
	rollout?: {
		maxSurgePercentage?:     uint & <=100 & >=0
		minAvailablePercentage?: uint & <=100 & >=0
	}
}

#ContainerSpec: {
	image: string
	command: [...string]
	args: [...string]
	env: [string]: string | v1.#Secret
	mounts: [...{
		volume: #VolumeSpec & {
			local:       string
			secret?:     _|_
			ephemeral?:  _|_
			persistent?: _|_
		} | {
			ephemeral:   string
			local?:      _|_
			secret?:     _|_
			persistent?: _|_
		} | {
			persistent: string
			ephemeral?: _|_
			local?:     _|_
			secret?:    _|_
		} | {
			secret:      v1.#Secret
			ephemeral?:  _|_
			local?:      _|_
			persistent?: _|_
		}
		path:     string
		readOnly: bool | *true
	}]
	resources: {
		requests?: {
			cpu?:    string
			memory?: string
		}
		limits?: {
			cpu?:    string
			memory?: string
		}
	}
}

// a component that can be horizontally scaled
#Replicable: v1.#Trait & {
	$metadata: traits: Replicable: null

	replicas: {
		min: uint | *1
		max: uint & >=min | *min
	}
}

// a component that can be scheduled as a cron job
#Cronable: v1.#Trait & {
	$metadata: traits: Cronable: null

	cron: {
		// Example of job definition:
		// .---------------- minute (0 - 59)
		// |  .------------- hour (0 - 23)
		// |  |  .---------- day of month (1 - 31)
		// |  |  |  .------- month (1 - 12)
		// |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
		// |  |  |  |  |
		// *  *  *  *  *
		schedule: =~"((((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7})"

		concurrency: {
			enable:  bool | *true
			replace: bool | *false
		}

		startingDeadlineSeconds?: uint
		historyLimit?: {
			successful?: uint
			failed?:     uint
		}
	}
}

// a component that has endpoints that can be exposed
#Exposable: v1.#Trait & {
	$metadata: traits: Exposable: null

	endpoints: [string]: #EndpointSpec & {
		ports: [...{
			name?:  string
			port:   uint
			target: uint | *port
			health?: {
				path?:             string
				protocol?:         string
				periodSeconds?:    uint
				successThreshold?: uint
				failureThreshold?: uint
			}
		}]
		host: string
	}
	endpoints: default: _
}

#EndpointSpec: {
	ports: [...{
		name?:  string
		port:   uint
		target: uint | *port
		health?: {
			path?:             string
			protocol?:         string
			periodSeconds?:    uint
			successThreshold?: uint
			failureThreshold?: uint
		}
	}]
	host: string
}

// work around ambiguous disjunctions by disallowing fields
#VolumeSpec: {
	local:       string
	secret?:     _|_
	ephemeral?:  _|_
	persistent?: _|_
} | {
	ephemeral:   string
	local?:      _|_
	secret?:     _|_
	persistent?: _|_
} | {
	persistent: string
	ephemeral?: _|_
	local?:     _|_
	secret?:    _|_
} | {
	secret:      v1.#Secret
	ephemeral?:  _|_
	local?:      _|_
	persistent?: _|_
}

// a component that has a volume
#Volume: v1.#Trait & {
	$metadata: traits: Volume: null

	volumes: [string]: #VolumeSpec & {
		local:       string
		secret?:     _|_
		ephemeral?:  _|_
		persistent?: _|_
	} | {
		ephemeral:   string
		local?:      _|_
		secret?:     _|_
		persistent?: _|_
	} | {
		persistent: string
		ephemeral?: _|_
		local?:     _|_
		secret?:    _|_
	} | {
		secret:      v1.#Secret
		ephemeral?:  _|_
		local?:      _|_
		persistent?: _|_
	}
}

// an automation workflow
#Workflow: v1.#Trait & {
	$metadata: traits: Workflow: null
	// the plan can be anything depending on the implementation
	// this field should be validated by transformers
	plan: _
}

// a component that has secrets
#Secret: v1.#Trait & {
	$metadata: traits: Secret: null

	secrets: [string]: v1.#Secret
}

// a network ingress for web traffic
#Gateway: v1.#Trait & {
	$metadata: traits: Gateway: null
	gateway: #GatewaySpec & {
		name:   string
		public: bool
		addresses: [...string]
		listeners: [string]: {
			hostname?: string
			port:      uint & <65536
			protocol:  *"HTTP" | "HTTPS" | "TCP" | "TLS"

			if protocol == "TLS" || protocol == "HTTPS" {
				tls: {
					mode: *"TERMINATE" | "PASSTHROUGH"
					options: [string]: string
				}
			}
		}
		_validate: [ for _, l in listeners {"\(l.port)/\(l.protocol)"}] & list.UniqueItems()
	}
}

#GatewaySpec: {
	name:   string
	public: bool
	addresses: [...string]
	listeners: [string]: {
		hostname?: string
		port:      uint & <65536
		protocol:  *"HTTP" | "HTTPS" | "TCP" | "TLS"

		if protocol == "TLS" || protocol == "HTTPS" {
			tls: {
				mode: *"TERMINATE" | "PASSTHROUGH"
				options: [string]: string
			}
		}
	}
	_validate: [ for _, l in listeners {"\(l.port)/\(l.protocol)"}] & list.UniqueItems()
}

#BackendSpec: {
	name:     string
	endpoint: #EndpointSpec
	containers?: [string]: #ContainerSpec
	port: uint
	_ports: [
		for p in endpoint.ports {p.port},
		for p in endpoint.ports {p.target},
	]
	"_port not in endpoints": list.Contains(_ports, port) & true
}

// an HTTP ingress route
#HTTPRoute: v1.#Trait & {
	$metadata: traits: HTTPRoute: null
	http: {
		gateway: #GatewaySpec & ({
			listeners: "\(listener)": protocol: "HTTP"
		} | {
			listeners: "\(listener)": {
				protocol: "HTTPS"
				tls: mode: "TERMINATE"
			}
		})
		listener: string

		hostnames: [...string]
		rules: [...{
			match: {
				path: string | *"/*"
				headers: [string]: string
				method?: string
			}
			redirect?: {
				scheme?:                                 "http" | "https"
				hostname?:                               string
				path?:                                   string
				port?:                                   uint & <65536
				statusCode:                              301 | *302
				pathPrefixOnly:                          bool | *false
				"_at least one parameter should be set": (scheme != _|_ || hostname != _|_ || path != _|_ || port != _|_) & true
			}
			backends: [... #BackendSpec & {
				name:     string
				endpoint: #EndpointSpec
				containers?: [string]: #ContainerSpec
				port: uint
				let _ports = [
					for p in endpoint.ports {p.port},
					for p in endpoint.ports {p.target},
				]
				"_port not in endpoints": list.Contains(_ports, port) & true
			}]
		}]
	}
}

// a TCP ingress route
#TCPRoute: v1.#Trait & {
	$metadata: traits: TCPRoute: null
	http: {
		gateway: #GatewaySpec & ({
			listeners: "\(listener)": protocol: "TCP"
		} | {
			listeners: "\(listener)": {
				protocol: "TLS"
				tls: mode: "TERMINATE"
			}
		})
		listener: string

		rules: [...{
			backends: [... #BackendSpec & {
				name:     string
				endpoint: #EndpointSpec
				containers?: [string]: #ContainerSpec
				port: uint
				_ports: [
					for p in endpoint.ports {p.port},
					for p in endpoint.ports {p.target},
				]
				"_port not in endpoints": list.Contains(_ports, port) & true
			}]
		}]
	}
}

// a TLS ingress route
#TLSRoute: v1.#Trait & {
	$metadata: traits: TLSRoute: null
	http: {
		gateway: #GatewaySpec & {
			listeners: "\(listener)": protocol: "HTTPS" | "TLS"
		}
		listener: string

		hostnames: [...string]
		rules: [...{
			backends: [... #BackendSpec & {
				name:     string
				endpoint: #EndpointSpec
				containers?: [string]: #ContainerSpec
				port: uint
				_ports: [
					for p in endpoint.ports {p.port},
					for p in endpoint.ports {p.target},
				]
				"_port not in endpoints": list.Contains(_ports, port) & true
			}]
		}]
	}
}

// an open container initiative compliant repository
#OCIRepository: v1.#Trait & {
	$metadata: traits: OCIRepository: null
	oci: name: string
}
