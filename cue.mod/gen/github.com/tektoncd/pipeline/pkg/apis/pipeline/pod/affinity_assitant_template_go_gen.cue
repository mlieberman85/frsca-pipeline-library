// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/tektoncd/pipeline/pkg/apis/pipeline/pod

package pod

import corev1 "k8s.io/api/core/v1"

// AffinityAssistantTemplate holds pod specific configuration and is a subset
// of the generic pod Template
// +k8s:deepcopy-gen=true
// +k8s:openapi-gen=true
#AffinityAssistantTemplate: {
	// NodeSelector is a selector which must be true for the pod to fit on a node.
	// Selector which must match a node's labels for the pod to be scheduled on that node.
	// More info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
	// +optional
	nodeSelector?: {[string]: string} @go(NodeSelector,map[string]string)

	// If specified, the pod's tolerations.
	// +optional
	// +listType=atomic
	tolerations?: [...corev1.#Toleration] @go(Tolerations,[]corev1.Toleration)

	// ImagePullSecrets gives the name of the secret used by the pod to pull the image if specified
	// +optional
	// +listType=atomic
	imagePullSecrets?: [...corev1.#LocalObjectReference] @go(ImagePullSecrets,[]corev1.LocalObjectReference)
}
