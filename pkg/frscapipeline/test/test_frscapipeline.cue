package frscapipeline

testInputs: #Inputs & {
    PIPELINE_NAME: "test-pipeline"
    DESCRIPTION: "This is a test pipeline"
    APP_IMAGE: "test-image"
    OUTPUT_ARTIFACT: "test-artifact"
    GIT_ORG: "test-org"
    GIT_REPO: "test-repo"
}

test: #baselinePipeline & {in: testInputs}