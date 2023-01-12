package components

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

#Minio: v1.#Trait & {
	traits.#Workload
	traits.#Volume
	traits.#Exposable

	minio: {
		version:    string | *"RELEASE.2023-01-02T09-40-09Z.fips"
		persistent: bool | *true

		urlScheme: *"https" | "http"
		url:       "\(urlScheme)://\(endpoints.default.host):\(endpoints.default.ports[0].port)"

		userKeys: [string]: {
			accessKey:    string | v1.#Secret
			accessSecret: string | v1.#Secret
		}
		userKeys: default: _
	}

	restart: "always"
	containers: default: {
		image: "minio/minio:\(minio.version)"
		command: ["server", "/data", "-console-address", ":9001"]
		env: {
			MINIO_ACCESS_KEY: minio.userKeys.default.accessKey
			MINIO_SECRET_KEY: minio.userKeys.default.accessSecret
		}
		mounts: [{
			volume:   volumes.default
			path:     "/data"
			readOnly: false
		}]
	}
	volumes: default: {
		if minio.persistent {
			persistent: "miniodata"
		}
		if !minio.persistent {
			ephemeral: "miniodata"
		}
	}
	endpoints: default: ports: [
		{
			port: 9000
		},
		{
			port: 9001
		},
	]
}
