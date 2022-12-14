package baseline

import (
    pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
)

frsca: task?: [Name=_]: pipelineV1Beta1.#Task & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Task"
	metadata: name: *Name | string
}

frsca: task?: [_]: pipelineV1Beta1.#Task & {
    spec: #BaselineTaskSpec
}

#BaselineTaskSpec: pipelineV1Beta1.#TaskSpec & {
    description: #BaselineDescription
} 

#BaselineDescription: "FOO"