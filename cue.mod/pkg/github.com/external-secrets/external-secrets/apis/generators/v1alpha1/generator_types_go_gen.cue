// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/external-secrets/external-secrets/apis/generators/v1alpha1

package v1alpha1

#ControllerClassResource: {
	spec: {
		controller: string @go(ControllerClass)
	} @go(Spec,"struct{ControllerClass string \"json:\\\"controller\\\"\"}")
}
