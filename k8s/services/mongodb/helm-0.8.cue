package mongodb

import "k8s.io/api/core/v1"

#KubeVersion: [=~"^0\\.8\\."]: minor: >=16
#Values: [=~"^0\\.8\\."]: {
	imagePullSecrets: [...v1.#LocalObjectReference]
	//# Operator
	operator: {
		// Name that will be assigned to most of internal Kubernetes objects like
		// Deployment, ServiceAccount, Role etc.
		name: string | *"mongodb-kubernetes-operator"

		// Name of the operator image
		operatorImageName: string | *"mongodb-kubernetes-operator"

		// Name of the deployment of the operator pod
		deploymentName: string | *"mongodb-kubernetes-operator"

		// Version of mongodb-kubernetes-operator
		version: string | *"0.8.0"

		// Uncomment this line to watch all namespaces
		watchNamespace: null | string | *"*"

		// Resources allocated to Operator Pod
		resources: v1.#ResourceRequirements | *{
			limits: {
				cpu:    "1100m"
				memory: "1Gi"
			}
			requests: {
				cpu:    "500m"
				memory: "200Mi"
			}
		}

		// Additional environment variables
		extraEnvs: [...{
			name:  string
			value: string
		}]
	}

	//# Operator's database
	database: {
		name: string | *"mongodb-database"
		// set this to the namespace where you would like
		// to deploy the MongoDB database,
		// Note if the database namespace is not same
		// as the operator namespace,
		// make sure to set "watchNamespace" to "*"
		// to ensure that the operator has the
		// permission to reconcile resources in other namespaces
		namespace: string | *null
	}

	agent: {
		name:    string | *"mongodb-agent"
		version: string | *"12.0.21.7698-1"
	}
	versionUpgradeHook: {
		name:    string | *"mongodb-kubernetes-operator-version-upgrade-post-start-hook"
		version: string | *"1.0.7"
	}
	readinessProbe: {
		name:    string | *"mongodb-kubernetes-readinessprobe"
		version: string | *"1.0.14"
	}
	mongodb: {
		name: string | *"mongo"
		repo: string | *"docker.io"
	}

	registry: {
		agent:              string | *"quay.io/mongodb"
		versionUpgradeHook: string | *"quay.io/mongodb"
		readinessProbe:     string | *"quay.io/mongodb"
		operator:           string | *"quay.io/mongodb"
		pullPolicy:         v1.#enumPullPolicy | *"Always"
	}

	// Set to false if CRDs have been installed already. The CRDs can be installed
	// manually from the code repo: github.com/mongodb/mongodb-kubernetes-operator or
	// using the `community-operator-crds` Helm chart.
	"community-operator-crds": enabled: bool | *true

	// Deploys MongoDB with `resource` attributes.
	createResource: bool | *false
	resource: {
		name:    string | *"mongodb-replica-set"
		version: string | *"4.4.0"
		members: uint | *3
		tls: {
			enabled: bool | *false

			// Installs Cert-Manager in this cluster.
			useCertManager:          bool | *true
			certificateKeySecretRef: string | *"tls-certificate"
			caCertificateSecretRef:  string | *"tls-ca-key-pair"
			certManager: {
				certDuration:    string | *"8760h" // 365 days
				renewCertBefore: string | *"720h"  // 30 days
			}
		}

		// if using the MongoDBCommunity Resource, list any users to be added to the resource
		users: [...{
			name: string
			db:   string
			// a reference to the secret that will be used to generate the user's password
			passwordSecretRef: v1.#LocalObjectReference
			roles: [...{
				db:   string
				name: string
			}]
			scramCredentialsSecretName: string
		}]
	}
}
