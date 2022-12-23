package frscabuildpackstask

import (
    frscatask "github.com/buildsec/frsca-pipeline-library/pkg/frscatask"
)

task: frscatask.frscaTask & {
    "buildpacks": {
        spec: {
	description: "The Buildpacks task builds source into a container image and pushes it to a registry, using Cloud Native Buildpacks."

	workspaces: [{
		name:        "source"
		description: "Directory where application source is located."
	}, {
		name:        "cache"
		description: "Directory where cache is stored (when no cache image is provided)."
		optional:    true
	}, {
		name:        "dockerconfig"
		description: "An optional workspace that allows providing a .docker/config.json file for Buildpacks lifecycle binary to access the container registry. The file should be placed at the root of the Workspace with name config.json."

		optional: true
	}]

	params: [{
		name:        "APP_IMAGE"
		description: "The name of where to store the app image."
	}, {
		name:        "BUILDER_IMAGE"
		description: "The image on which builds will run (must include lifecycle and compatible buildpacks)."
	}, {
		name:        "SOURCE_SUBPATH"
		description: "A subpath within the `source` input where the source to build is located."
		default:     ""
	}, {
		name:        "ENV_VARS"
		type:        "array"
		description: "Environment variables to set during _build-time_."
		default: []
	}, {
		name:        "PROCESS_TYPE"
		description: "The default process type to set on the image."
		default:     "web"
	}, {
		name:        "RUN_IMAGE"
		description: "Reference to a run image to use."
		default:     ""
	}, {
		name:        "CACHE_IMAGE"
		description: "The name of the persistent app cache image (if no cache workspace is provided)."
		default:     ""
	}, {
		name:        "SKIP_RESTORE"
		description: "Do not write layer metadata or restore cached layers."
		default:     "false"
	}, {
		name:        "USER_ID"
		description: "The user ID of the builder image user."
		default:     "1000"
	}, {
		name:        "GROUP_ID"
		description: "The group ID of the builder image user."
		default:     "1000"
	}, {
		name:        "PLATFORM_DIR"
		description: "The name of the platform directory."
		default:     "empty-dir"
	}]

	results: [{
		name:        "APP_IMAGE_DIGEST"
		description: "The digest of the built `APP_IMAGE`."
	}, {
		name:        "APP_IMAGE_URL"
		description: "The URL of the built `APP_IMAGE`."
	}]

	stepTemplate: {
        name: "DNM"  // NOTE: This is deprecated and should go away.
        env: [{
		name:  "CNB_PLATFORM_API"
		value: "0.4"
	}]}

	steps: [{
		name:  "prepare"
		image: "docker.io/library/bash:5.1.4@sha256:b208215a4655538be652b2769d82e576bc4d0a2bb132144c060efc5be8c3f5d6"
		args: [
			"--env-vars",
			"$(params.ENV_VARS[*])",
		]
		script: """
			#!/usr/bin/env bash
			set -e

			if [[ \"$(workspaces.cache.bound)\" == \"true\" ]]; then
			  echo \"> Setting permissions on '$(workspaces.cache.path)'...\"
			  chown -R \"$(params.USER_ID):$(params.GROUP_ID)\" \"$(workspaces.cache.path)\"
			fi

			for path in \"/tekton/home\" \"/layers\" \"$(workspaces.source.path)\"; do
			  echo \"> Setting permissions on '$path'...\"
			  chown -R \"$(params.USER_ID):$(params.GROUP_ID)\" \"$path\"

			  if [[ \"$path\" == \"$(workspaces.source.path)\" ]]; then
			      chmod 775 \"$(workspaces.source.path)\"
			  fi
			done

			echo \"> Parsing additional configuration...\"
			parsing_flag=\"\"
			envs=()
			for arg in \"$@\"; do
			    if [[ \"$arg\" == \"--env-vars\" ]]; then
			        echo \"-> Parsing env variables...\"
			        parsing_flag=\"env-vars\"
			    elif [[ \"$parsing_flag\" == \"env-vars\" ]]; then
			        envs+=(\"$arg\")
			    fi
			done

			echo \"> Processing any environment variables...\"
			ENV_DIR=\"/platform/env\"

			echo \"--> Creating 'env' directory: $ENV_DIR\"
			mkdir -p \"$ENV_DIR\"

			for env in \"${envs[@]}\"; do
			    IFS='=' read -r key value <<< \"$env\"
			    if [[ \"$key\" != \"\" && \"$value\" != \"\" ]]; then
			        path=\"${ENV_DIR}/${key}\"
			        echo \"--> Writing ${path}...\"
			        echo -n \"$value\" > \"$path\"
			    fi
			done

			"""

		volumeMounts: [{
			name:      "layers-dir"
			mountPath: "/layers"
		}, {
			name:      "$(params.PLATFORM_DIR)"
			mountPath: "/platform"
		}]
	}, {
		name:            "create"
		image:           "$(params.BUILDER_IMAGE)"
		imagePullPolicy: "Always"
		command: ["/cnb/lifecycle/creator"]
		env: [{
			name:  "DOCKER_CONFIG"
			value: "$(workspaces.dockerconfig.path)"
		}]
		args: [
			"-app=$(workspaces.source.path)/$(params.SOURCE_SUBPATH)",
			"-cache-dir=$(workspaces.cache.path)",
			"-cache-image=$(params.CACHE_IMAGE)",
			"-uid=$(params.USER_ID)",
			"-gid=$(params.GROUP_ID)",
			"-layers=/layers",
			"-platform=/platform",
			"-report=/layers/report.toml",
			"-process-type=$(params.PROCESS_TYPE)",
			"-skip-restore=$(params.SKIP_RESTORE)",
			"-previous-image=$(params.APP_IMAGE)",
			"-run-image=$(params.RUN_IMAGE)",
			"$(params.APP_IMAGE)",
		]
		volumeMounts: [{
			name:      "layers-dir"
			mountPath: "/layers"
		}, {
			name:      "$(params.PLATFORM_DIR)"
			mountPath: "/platform"
		}]
		securityContext: {
			runAsUser:  1000
			runAsGroup: 1000
		}
	}, {
		name:  "results"
		image: "docker.io/library/bash:5.1.4@sha256:b208215a4655538be652b2769d82e576bc4d0a2bb132144c060efc5be8c3f5d6"
		script: """
			#!/usr/bin/env bash
			set -e
			grep \"digest\" /layers/report.toml | cut -d'\"' -f2 | cut -d'\"' -f2 | tr -d '\\n' | tee \"$(results.APP_IMAGE_DIGEST.path)\"
			echo -n \"$(params.APP_IMAGE)\" | tee \"$(results.APP_IMAGE_URL.path)\"

			"""

		volumeMounts: [{
			name:      "layers-dir"
			mountPath: "/layers"
		}]
	}]

	volumes: [{
		name: "empty-dir"
		emptyDir: {}
	}, {
		name: "layers-dir"
		emptyDir: {}
	}]
}

    }
}