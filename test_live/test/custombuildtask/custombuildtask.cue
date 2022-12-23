package frsca

import (
    frscapipeline "github.com/buildsec/frsca-pipeline-library/pkg/frscapipeline"
    frscabuildpackstask "github.com/buildsec/frsca-pipeline-library/pkg/catalog/tasks/frscabuildpackstask"
)

testInputs: frscapipeline.#Inputs & {
    PIPELINE_NAME: "test-pipeline"
    DESCRIPTION: "This is a test pipeline"
    APP_IMAGE: "test-image"
    OUTPUT_ARTIFACT: "test-artifact"
    GIT_ORG: "test-org"
    GIT_REPO: "test-repo"
    frscaBuildTasks: [frscabuildpackstask.task]
}

_pipeline: frscapipeline.#baselinePipeline & {in: testInputs}
frsca: _pipeline.frsca