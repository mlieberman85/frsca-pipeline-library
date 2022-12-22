package frscatask

import (
    pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
)

frscaTask: [Name=_]: pipelineV1Beta1.#Task & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Task"
	metadata: name: *Name | string
}

// TODO: Other generation/constraints for a frscatask should go below
#baselineTask: frscaTask