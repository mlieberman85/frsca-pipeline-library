package frsca


_IMAGE: name:  string
_REPOSITORY: *"ttl.sh" | repository | string @tag(repository)
_APP_IMAGE: *"\(_REPOSITORY)/\(_IMAGE.name)" | string @tag(appImage)
_GIT_ORG: *"https://gitea-http.gitea:3000/frsca" | string @tag(gitOrg)
_NAMESPACE: *"default" | string @tag(namespace)

buildType: string