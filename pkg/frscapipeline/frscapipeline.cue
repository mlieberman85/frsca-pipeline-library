package frscapipeline

import (
    pipelineV1Beta1 "github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1"
    frscaclonetask "github.com/buildsec/frsca-pipeline-library/pkg/catalog/frscaclonetask"
    frscatask "github.com/buildsec/frsca-pipeline-library/pkg/frscatask"
)

#baselinePrebuildTasks: [frscaclonetask.task, ...frscatask.#baselineTask]
// TODO: There should be at least one baseline task
#baselineBuildTasks: [...frscatask.#baselineTask]
#baselinePostbuildTasks: [...frscatask.#baselineTask]

// TODO: Figure out an input naming scheme
#Inputs: {
    PIPELINE_NAME: string
    DESCRIPTION: string
    APP_IMAGE: string
    OUTPUT_ARTIFACT: string
    GIT_ORG: string
    GIT_REPO: string
    frscaPreBuildTasks: #baselinePrebuildTasks
    frscaBuildTasks: #baselineBuildTasks
    frscaPostbuildTasks: #baselinePostbuildTasks
}

frsca: pipeline?: [Name=_]: pipelineV1Beta1.#Pipeline & {
	apiVersion: "tekton.dev/v1beta1"
	kind:       "Pipeline"
	metadata: name: *Name | string
}

//frscaTotalTasks: frscaPreBuildTasks + frscaBuildTasks + frscaPostbuildTasks

#baselinePipeline: {
    in: #Inputs
    let frscaTotalTasks = in.frscaPreBuildTasks + in.frscaBuildTasks + in.frscaPostbuildTasks
    for frscaTask in frscaTotalTasks {
        frsca: task: frscaTask
    }
    frsca: pipeline: (in.PIPELINE_NAME): pipelineV1Beta1.#Pipeline & {
        spec: {
        workspaces: [{
            name:     "pipeline-pvc"
            optional: false
        }]
        params: [{
            name:        "image"
            type:        "string"
            description: "reference of the image to build"
        }, {
            name:        "SOURCE_URL"
            type:        "string"
            description: "git repo"
        }, {
            name:        "SOURCE_SUBPATH"
            type:        "string"
            default:     "."
            description: "path within git repo"
        }, {
            name:        "SOURCE_REFERENCE"
            type:        "string"
            description: "git commit branch, or tag"
        }, {
            name:        "ARGS"
            type:        "array"
            description: "The Arguments to be passed to Trivy command for file system scan"
        }, {
            name:        "IMAGEARGS"
            type:        "array"
            description: "The Arguments to be passed to Trivy command for image scan"
        }, {
            name:        "package"
            type:        "string"
            default:     "."
            description: "Go package to build and test"
        }]
        results: [{
            name:        "commit-sha"
            description: "the sha of the commit that was used"
            value:       "$(tasks.clone.results.commit)"
        }]
        description: in.DESCRIPTION
        tasks: [{
            name: "clone"
            taskRef: name: "git-clone"
            workspaces: [{
                name:      "output"
                workspace: "pipeline-pvc"
            }]
            params: [{
                name:  "url"
                value: "$(params.SOURCE_URL)"
            }, {
                name:  "revision"
                value: "$(params.SOURCE_REFERENCE)"
            }, {
                name:  "subdirectory"
                value: "$(params.SOURCE_SUBPATH)"
            }, {
                name:  "deleteExisting"
                value: "true"
            }]
        }, {
            name: "run-test"
            taskRef: name: "golang-test"
            runAfter: [
                "clone",
            ]
            workspaces: [{
                name:      "source"
                workspace: "pipeline-pvc"
            }]
            params: [{
                name:  "package"
                value: "$(params.package)"
            }, {
                name:  "GOARCH"
                value: ""
            }]
        }, {
            name: "run-build"
            taskRef: name: "golang-build"
            runAfter: [
                "clone",
            ]
            workspaces: [{
                name:      "source"
                workspace: "pipeline-pvc"
            }]
            params: [{
                name:  "package"
                value: "$(params.package)"
            }, {
                name:  "packages"
                value: "./"
            }]
        }, {
            name: "kaniko"
            taskRef: name: "kaniko"
            runAfter: [
                "trivy-scan-local-fs",
            ]
            workspaces: [{
                name:      "source"
                workspace: "pipeline-pvc"
            }]
            params: [{
                name:  "IMAGE"
                value: "$(params.image)"
            }, {
                name: "EXTRA_ARGS"
                value: [
                    "--skip-tls-verify",
                ]
            }]
        }, {
            name: "trivy-scan-local-fs"
            taskRef: {
                name: "trivy-scanner"
                kind: "Task"
            }
            runAfter: [
                "clone",
            ]
            params: [{
                name: "ARGS"
                value: ["$(params.ARGS[*])"]
            }, {
                name:  "IMAGE_PATH"
                value: "."
            }]
            workspaces: [{
                name:      "manifest-dir"
                workspace: "pipeline-pvc"
            }]
        }, {
            name: "trivy-scan-image"
            taskRef: {
                name: "trivy-scanner"
                kind: "Task"
            }
            runAfter: [
                "kaniko",
            ]
            params: [{
                name: "ARGS"
                value: ["$(params.IMAGEARGS[*])"]
            }, {
                name:  "IMAGE_PATH"
                value: "$(params.image)"
            }]
            workspaces: [{
                name:      "manifest-dir"
                workspace: "pipeline-pvc"
            }]
        }]
    }
    }

    frsca: trigger: "example-golang": {
        pipelineRun: spec: {
            params: [{
                name:  "image"
                value: "\(in.APP_IMAGE):$(tt.params.gitrevision)"
            }, {
                name:  "SOURCE_URL"
                value: "\(in.GIT_ORG)/example-golang"
            }, {
                name:  "SOURCE_SUBPATH"
                value: "."
            }, {
                name: "SOURCE_REFERENCE"
                value: "$(tt.params.gitrevision)"
            }, {
                name: "ARGS"
                value: [
                    "fs",
                    "--exit-code",
                    "1",
                ]
            }, {
                name: "IMAGEARGS"
                value: [
                    "image",
                    "--exit-code",
                    "0",
                ]
            }]
            pipelineRef: name: "example-golang"
            timeout: "1h0m0s"
            workspaces: [{
                name: "pipeline-pvc"
            }]
        }
    }
}



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