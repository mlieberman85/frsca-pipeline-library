package frsca


_IMAGE: name:  string
_REPOSITORY: *"ttl.sh" | string @tag(repository)
_APP_IMAGE: *"\(_REPOSITORY)/\(_IMAGE.name)" | string @tag(appImage)
_GIT_ORG: *"https://gitea-http.gitea:3000/frsca" | string @tag(gitOrg)
_NAMESPACE: *"default" | string @tag(namespace)

// Below are resources required for all pipelines
frsca: secret: "kube-api-secret": {
	metadata: annotations: "kubernetes.io/service-account.name": "pipeline-account"
	type: "kubernetes.io/service-account-token"
}

frsca: serviceAccount: "pipeline-account": {
}

frsca: clusterRole: "pipeline-role": rules: [{
	apiGroups: [""]
	resources: ["services"]
	verbs: ["get", "create", "update", "patch"]
}, {
	apiGroups: ["apps"]
	resources: ["deployments"]
	verbs: ["get", "create", "update", "patch"]
}]

frsca: clusterRoleBinding: "pipeline-role-binding": {
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "pipeline-role"
	}
	subjects: [{
		kind: "ServiceAccount"
		namespace: "\(_NAMESPACE)"
		name: "pipeline-account"
	}]
}

// generate a PVC for each pipelineRun
for pr in frsca.pipelineRun {
	frsca: persistentVolumeClaim: "\(pr.metadata.generateName)source-ws-pvc": {
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "500Mi"
		}
	}
}

frsca: pipelineRun: [Name=_]: spec: workspaces: [{
	name: *"\(Name)ws" | string
	persistentVolumeClaim: claimName: "\(Name)source-ws-pvc"
}, ...]

// same PVC settings for pipelineRuns within a triggerTemplate
for name, tt in frsca.triggerTemplate {
	frsca: persistentVolumeClaim: "\(name)-source-ws-pvc": {
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "500Mi"
		}
	}
}

frsca: triggerTemplate: [Name=_]: spec: resourcetemplates: [{
	spec: workspaces: [{
		name: *"\(Name)-ws" | string
		persistentVolumeClaim: claimName: "\(Name)-source-ws-pvc"
	}, ...]
}]

frsca: task: [_]: {
	spec: {
		volumes: [{
			configMap: { name: "ca-certs" }
			name: "ca-certs"
		}]
	}
}

frsca: task: [_]: {
	spec: steps: [...{
		volumeMounts: [{
			mountPath: "/etc/ssl/certs/ca-certificates.crt"
			name: "ca-certs"
			subPath: "ca-certificates.crt"
			readOnly: true
		}]
	}]
}