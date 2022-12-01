package base

#Inputs: {
	IMAGE: name: string
	REPOSITORY: *"ttl.sh" | string @tag(repository)
	APP_IMAGE: *"\(REPOSITORY)/\(IMAGE.name)" | string @tag(appImage)
	GIT_ORG: *"https://gitea-http.gitea:3000/frsca" | string @tag(gitOrg)
	NAMESPACE: *"default" | string @tag(namespace)
}

