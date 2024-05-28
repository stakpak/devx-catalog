// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/external-secrets/external-secrets/apis/generators/v1alpha1

package v1alpha1

import (
	esmeta "github.com/external-secrets/external-secrets/apis/meta/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

#ECRAuthorizationTokenSpec: {
	// Region specifies the region to operate in.
	region: string @go(Region)

	// Auth defines how to authenticate with AWS
	// +optional
	auth?: #AWSAuth @go(Auth)

	// You can assume a role before making calls to the
	// desired AWS service.
	// +optional
	role?: string @go(Role)
}

// AWSAuth tells the controller how to do authentication with aws.
// Only one of secretRef or jwt can be specified.
// if none is specified the controller will load credentials using the aws sdk defaults.
#AWSAuth: {
	// +optional
	secretRef?: null | #AWSAuthSecretRef @go(SecretRef,*AWSAuthSecretRef)

	// +optional
	jwt?: null | #AWSJWTAuth @go(JWTAuth,*AWSJWTAuth)
}

// AWSAuthSecretRef holds secret references for AWS credentials
// both AccessKeyID and SecretAccessKey must be defined in order to properly authenticate.
#AWSAuthSecretRef: {
	// The AccessKeyID is used for authentication
	accessKeyIDSecretRef?: esmeta.#SecretKeySelector @go(AccessKeyID)

	// The SecretAccessKey is used for authentication
	secretAccessKeySecretRef?: esmeta.#SecretKeySelector @go(SecretAccessKey)

	// The SessionToken used for authentication
	// This must be defined if AccessKeyID and SecretAccessKey are temporary credentials
	// see: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html
	// +Optional
	sessionTokenSecretRef?: null | esmeta.#SecretKeySelector @go(SessionToken,*esmeta.SecretKeySelector)
}

// Authenticate against AWS using service account tokens.
#AWSJWTAuth: {
	serviceAccountRef?: null | esmeta.#ServiceAccountSelector @go(ServiceAccountRef,*esmeta.ServiceAccountSelector)
}

// ECRAuthorizationTokenSpec uses the GetAuthorizationToken API to retrieve an
// authorization token.
// The authorization token is valid for 12 hours.
// The authorizationToken returned is a base64 encoded string that can be decoded
// and used in a docker login command to authenticate to a registry.
// For more information, see Registry authentication (https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth) in the Amazon Elastic Container Registry User Guide.
// +kubebuilder:object:root=true
// +kubebuilder:storageversion
// +kubebuilder:subresource:status
// +kubebuilder:resource:scope=Namespaced,categories={ecrauthorizationtoken},shortName=ecrauthorizationtoken
#ECRAuthorizationToken: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta         @go(ObjectMeta)
	spec?:     #ECRAuthorizationTokenSpec @go(Spec)
}

// ECRAuthorizationTokenList contains a list of ExternalSecret resources.
#ECRAuthorizationTokenList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#ECRAuthorizationToken] @go(Items,[]ECRAuthorizationToken)
}