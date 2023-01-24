package traits

import (
	"guku.io/devx/v1"
)

_#HelmCommon: {
	k8s: version: {
		major: uint | *1
		minor: uint
	}
	chart:   string @guku(required)
	url:     string @guku(required)
	version: string @guku(required)
	values: [string]: _
	namespace:       string
	timeout:         uint | *600
	atomic:          bool | *true
	createNamespace: bool | *true
	dependsOn: [...#Helm]
}

// a helm chart using helm repo
#Helm: v1.#Trait & {
	$metadata: traits: Helm: null
	helm: _#HelmCommon & {
		k8s: version: {
			major: uint | *1
			minor: uint
		}
		chart:   string @guku(required)
		url:     string @guku(required)
		version: string @guku(required)
		values: [string]: _
		namespace:       string
		timeout:         uint | *600
		atomic:          bool | *true
		createNamespace: bool | *true
		dependsOn: [...#Helm]
	}
}

// a helm chart using git
#HelmGit: v1.#Trait & {
	$metadata: traits: HelmGit: null
	helm: _#HelmCommon & {
		k8s: version: {
			major: uint | *1
			minor: uint
		}
		chart:   string @guku(required)
		url:     string @guku(required)
		version: string @guku(required)
		values: [string]: _
		namespace:       string
		timeout:         uint | *600
		atomic:          bool | *true
		createNamespace: bool | *true
		dependsOn: [...#Helm]
	}
}

// a helm chart using oci
#HelmOCI: v1.#Trait & {
	$metadata: traits: HelmOCI: null
	helm: _#HelmCommon & {
		k8s: version: {
			major: uint | *1
			minor: uint
		}
		chart:   string @guku(required)
		url:     string @guku(required)
		version: string @guku(required)
		values: [string]: _
		namespace:       string
		timeout:         uint | *600
		atomic:          bool | *true
		createNamespace: bool | *true
		dependsOn: [...#Helm]
	}
}
