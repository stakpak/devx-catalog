// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/external-secrets/external-secrets/apis/meta/v1

package v1

// A reference to a specific 'key' within a Secret resource,
// In some instances, `key` is a required field.
#SecretKeySelector: {
	// The name of the Secret resource being referred to.
	name?: string @go(Name)

	// Namespace of the resource being referred to. Ignored if referent is not cluster-scoped. cluster-scoped defaults
	// to the namespace of the referent.
	// +optional
	namespace?: null | string @go(Namespace,*string)

	// The key of the entry in the Secret resource's `data` field to be used. Some instances of this field may be
	// defaulted, in others it may be required.
	// +optional
	key?: string @go(Key)
}

// A reference to a ServiceAccount resource.
#ServiceAccountSelector: {
	// The name of the ServiceAccount resource being referred to.
	name: string @go(Name)

	// Namespace of the resource being referred to. Ignored if referent is not cluster-scoped. cluster-scoped defaults
	// to the namespace of the referent.
	// +optional
	namespace?: null | string @go(Namespace,*string)

	// Audience specifies the `aud` claim for the service account token
	// If the service account uses a well-known annotation for e.g. IRSA or GCP Workload Identity
	// then this audiences will be appended to the list
	// +optional
	audiences?: [...string] @go(Audiences,[]string)
}