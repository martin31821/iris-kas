// SPDX-License-Identifier: MIT
// Copyright (C) 2021 iris-GmbH infrared & intelligent sensors


// Target multiconfigs for the Jenkins pipeline
def targets = [ "sc573-gen6", "imx8mp-evk" ]

// Make parsable as environment variable
def targets_string = targets.join(' ')

// Generate parallel & dynamic compile steps
def parallelBaseImageStagesMap = targets.collectEntries {
    ["${it}" : generateBaseImageStages(it)]  
}

def generateBaseImageStages(target) {
    return {
        stage("Reproduce ${target} Base Image") {
            awsCodeBuild buildSpecFile: 'buildspecs/reproduce_base_image.yml',
                credentialsType: 'keys',
                downloadArtifacts: 'false',
                region: 'eu-central-1',
                sourceControlType: 'project',
                sourceTypeOverride: 'S3',
                sourceLocationOverride: "${S3_TEMP_LOCATION}/${GIT_TAG}/${BASE_SOURCES_TEMP_ARTIFACT}",
                projectName: 'iris-devops-kas-build-codebuild',
                envVariables: "[ { MULTI_CONF, $target }, { GIT_TAG, $GIT_TAG } ]"
        }
    }
}

pipeline {
    agent any
    environment {
        // S3 for permanent artifacts
        S3_LOCATION = 'iris-devops-artifacts-693612562064'
        // S3 with auto-expiration enabled
        S3_TEMP_LOCATION = 'iris-devops-tempartifacts-693612562064'
    }
    stages {
        stage('Preparation Stage') {
            steps {
                // Clean workspace
                cleanWs disableDeferredWipeout: true, deleteDirs: true
                // We need to explicitly checkout from SCM here
                checkout scm
                // Set environment variables dependent on the git checkout
                script {
                    env.GIT_TAG = sh(script: 'git describe --tag --always', returnStdout: true).trim()
                    env.BASE_SOURCES_TEMP_ARTIFACT = sh(script: 'echo -n "$(git describe --tag --always)-base-sources.zip"', returnStdout: true).trim()
                }
            }
        }

        // Archive the base sources for copyleft compliance
        stage("Archive Base Sources") {
            steps {
                awsCodeBuild buildSpecFile: 'buildspecs/fetch_base_sources.yml',
                    projectName: 'iris-devops-kas-fetch-codebuild',
                    credentialsType: 'keys',
                    downloadArtifacts: 'false',
                    region: 'eu-central-1',
                    sourceControlType: 'jenkins',
                    sourceTypeOverride: 'S3',
                    sourceLocationOverride: "${S3_TEMP_LOCATION}/${GIT_TAG}/iris-devops-fetch-artifacts.zip",
                    artifactTypeOverride: 'S3',
                    artifactLocationOverride: "${S3_LOCATION}",
                    artifactPathOverride: "releases",
                    artifactNameOverride: "${GIT_TAG}",
                    artifactNamespaceOverride: 'NONE',
                    secondaryArtifactsOverride: """[
                        {
                            \"type\": \"S3\",
                            \"location\": \"${S3_TEMP_LOCATION}\",
                            \"artifactIdentifier\": \"temp_base_sources\",
                            \"path\": \"${GIT_TAG}\",
                            \"namespaceType\": \"NONE\",
                            \"name\": \"${BASE_SOURCES_TEMP_ARTIFACT}\",
                            \"packaging\": \"ZIP\"
                        }
                    ]""",
                    envVariables: "[{ TARGETS, $targets_string }, { GIT_TAG, $GIT_TAG }]"
            }
        }

        // Validate that the base image compiles for all multiconfigs (copyleft compliance)
        stage('Verify Base Image Reproducibility') {
            steps {
                script {
                    parallel parallelBaseImageStagesMap
                }
            }
        }
    }

    post {
        // Clean after build
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true)
        }
    }
}
