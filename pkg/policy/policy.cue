package policy

#Inputs: {
    NAME: string
    IMAGE_GLOB: string
    KEY_REF: string
} 

#Policy: {
    in: #Inputs
    frsca: clusterPolicy: (in.NAME): {
        spec: rules: [{
            verifyImages: [{
                image: in.IMAGE_GLOB
                key:   in.KEY_REF
            },...]
            match: resources: namespaces: ["tekton-pipelines",
                "tekton-chains",
                "default",
                "prod"]
        }]
        metadata: {
            annotations: {
                "policies.kyverno.io/title":       "Verify Image"
                "policies.kyverno.io/category":    "Sample"
                "policies.kyverno.io/severity":    "medium"
                "policies.kyverno.io/subject":     "Pod"
                "policies.kyverno.io/minversion":  "1.4.2"
                "policies.kyverno.io/description": "Using the Cosign project, OCI images may be signed to ensure supply chain security is maintained. Those signatures can be verified before pulling into a cluster. This policy checks the signature of an image repo called ghcr.io/kyverno/test-verify-image to ensure it has been signed by verifying its signature against the provided public key. This policy serves as an illustration for how to configure a similar rule and will require replacing with your image(s) and keys."
            }
        }
    }
}