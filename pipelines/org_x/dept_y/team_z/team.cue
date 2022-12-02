package frsca

import (
    buildpacks "github.com/buildsec/frsca-pipeline-library/templates/buildpacks"
)

team: "team_z"
buildType: "buildpacks" | "go"

if buildType == "buildpacks" {buildpacks & {
        REPOSITORY: _REPOSITORY
        APP_IMAGE: _APP_IMAGE
        GIT_ORG: _GIT_ORG
        NAMESPACE: _NAMESPACE
        IMAGE: _IMAGE
}}