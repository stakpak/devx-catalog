// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/external-secrets/external-secrets/apis/externalsecrets/v1beta1

package v1beta1

import esmeta "github.com/external-secrets/external-secrets/apis/meta/v1"

// Passbolt contains a secretRef for the passbolt credentials.
#PassboltAuth: {
	passwordSecretRef?:   null | esmeta.#SecretKeySelector @go(PasswordSecretRef,*esmeta.SecretKeySelector)
	privateKeySecretRef?: null | esmeta.#SecretKeySelector @go(PrivateKeySecretRef,*esmeta.SecretKeySelector)
}

#PassboltProvider: {
	// Auth defines the information necessary to authenticate against Passbolt Server
	auth?: null | #PassboltAuth @go(Auth,*PassboltAuth)

	// Host defines the Passbolt Server to connect to
	host: string @go(Host)
}
