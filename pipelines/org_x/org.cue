package frsca

import (
    buildpacks "github.com/buildsec/frsca-pipeline-library/templates/buildpacks"
    go "github.com/buildsec/frsca-pipeline-library/templates/go"
    policy "github.com/buildsec/frsca-pipeline-library/pkg/policy"
    //baseline "github.com/buildsec/frsca-pipeline-library/pkg/baseline"
)

_IMAGE: name: "\(org)-\(dept)-\(team)-\(project)"

org: "org_x"

let allowedBuilds = {
    "buildpacks": buildpacks & {
        REPOSITORY: _REPOSITORY
        APP_IMAGE: _APP_IMAGE
        GIT_ORG: _GIT_ORG
        NAMESPACE: _NAMESPACE
        IMAGE: _IMAGE
    }

    "go": go & {
        REPOSITORY: _REPOSITORY
        APP_IMAGE: _APP_IMAGE
        GIT_ORG: _GIT_ORG
        NAMESPACE: _NAMESPACE
        IMAGE: _IMAGE
    }
}

allowedBuilds[buildType]

_policy1: policy.#Policy & {in: {NAME: "foo", IMAGE_GLOB: "foo/bar/*", KEY_REF: "{{ keys.data.mykey }}"}}
frsca: _policy1.frsca

_policy2: policy.#Policy & {in: {NAME: "bar", IMAGE_GLOB: "bar/baz/*", KEY_REF: "{{ keys.data.mykey2 }}"}}
frsca: _policy2.frsca

