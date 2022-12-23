package frsca

import (
    buildpacks "github.com/buildsec/frsca-pipeline-library/pkg/catalog/pipelines/buildpacks"
)

frsca: buildpacks.frsca & {
    REPOSITORY: "test"
    APP_IMAGE: "test"
    GIT_ORG: "test"
    NAMESPACE: "test"
}