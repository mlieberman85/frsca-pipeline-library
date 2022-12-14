// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/triggers/pkg/apis/triggers/v1beta1

package v1beta1

// ParamSpec defines an arbitrary named  input whose value can be supplied by a
// `Param`.
#ParamSpec: {
	// Name declares the name by which a parameter is referenced.
	name: string @go(Name)

	// Description is a user-facing description of the parameter that may be
	// used to populate a UI.
	// +optional
	description?: string @go(Description)

	// Default is the value a parameter takes if no input value via a Param is supplied.
	// +optional
	default?: null | string @go(Default,*string)
}

// Param defines a string value to be used for a ParamSpec with the same name.
#Param: {
	name:  string @go(Name)
	value: string @go(Value)
}
