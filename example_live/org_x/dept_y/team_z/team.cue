package frsca

import (
    policy "github.com/buildsec/frsca-pipeline-library/pkg/policy"
)

team: "team_z"
buildType: "go"

_policy3: policy.#Policy & {in: {NAME: "baz", IMAGE_GLOB: "baz/*", KEY_REF: "{{ keys.data.mykey3 }}"}}
frsca: _policy3.frsca