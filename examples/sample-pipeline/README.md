# FRSCA Sample Tekton Pipeline

This is a sample tekton based application build pipeline.

> :warning: This pipeline is not intended to be used in production

Follow these instructions to setup this pipeline and run it against your sample
application repository. In this example, we are going to build and deploy
[tekton-tutorial-openshift](https://github.com/IBM/tekton-tutorial-openshift)
application. You can use `minikube` to run your tekton pipeline and deploy this
application.

## Starting Demo

```bash
# Only if a cluster is needed.
make setup-minikube

# Setup FRSCA environment
make setup-frsca

# Run a new pipeline.
make setup-examples
make example-sample-pipeline

# Wait until it completes.
tkn pr logs --last -f

# Export the value of IMAGE_URL from the last taskrun and the taskrun name:
export IMAGE_URL=$(tkn pr describe --last -o jsonpath='{..taskResults}' | jq -r '.[] | select(.name | match("IMAGE_URL$")) | .value')
export TASK_RUN=$(tkn pr describe --last -o json | jq -r '.status.taskRuns | keys[] as $k | {"k": $k, "v": .[$k]} | select(.v.status.taskResults[]?.name | match("IMAGE_URL$")) | .k')

## If using the registry-proxy
# export IMAGE_URL="$(echo "${IMAGE_URL}" | sed 's#'${REGISTRY}'#127.0.0.1:5000#')"

export REPO="$(echo -n ${IMAGE_URL} | sed 's|:[^/]*$||')"

# Double check that the attestation and the signature were uploaded to the OCI.
crane ls ${REPO}
export SBOM=$(crane ls ${REPO} | grep \.sbom)
export ATTESTATION=$(crane ls ${REPO} | grep \.att)
#export SBOM_DIGEST=$(crane digest ${REPO}:${SBOM})
#sget ${REPO}:${SBOM}@${SBOM_DIGEST} > outputs/${SBOM}.json
#cat outputs/${SBOM}.json | jq


# Verify the image and the attestation.
cosign verify --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
cosign verify-attestation --type slsaprovenance --key k8s://tekton-chains/signing-secrets "${IMAGE_URL}"
cosign download attestation "${IMAGE_URL}" | jq -r .payload | base64 --decode > outputs/${ATTESTATION}.json
cat outputs/${ATTESTATION}.json | jq

# Download the SBOM
export OUTPUT_LOC=outputs/${SBOM}.json
cosign download sbom "${IMAGE_URL}" > ${OUTPUT_LOC}
export TMPFILE=$(mktemp)
jq --arg r "${REPO}" '.name=$r' ${OUTPUT_LOC} > ${TMPFILE} && mv ${TMPFILE} ${OUTPUT_LOC}
jq "" outputs/${SBOM}.json 
../artifact-ff/bin/guacone files --creds neo4j:test1234 --db-addr neo4j://localhost:7687 outputs/

# Verify the signature and attestation with tkn.
tkn chain signature "${TASK_RUN}"
tkn chain payload "${TASK_RUN}"
```

Once successfully completed. You should be able to see your application deployed
on the cluster

```bash
% kubectl get all -n prod
NAME                          READY   STATUS    RESTARTS   AGE
pod/picalc-576dd6b788-sszmh   1/1     Running   0          32s

NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/picalc   NodePort   10.107.77.128   <none>        8080:30907/TCP   37s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/picalc   1/1     1            1           38s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/picalc-576dd6b788   1         1         1       38s
```