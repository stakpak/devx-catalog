package resources

import (
	"stakpak.dev/devx/k8s"
	"github.com/argoproj/argo-cd/v2/pkg/apis/application/v1alpha1"
)


#Application: {
	k8s.#KubernetesResource
	v1alpha1.#Application
	apiVersion: "argoproj.io/v1alpha1"
	kind:       "Application"
}