// SPDX-License-Identifier: MIT
// Copyright (C) 2021 iris-GmbH infrared & intelligent sensors


// target multiconfigs for the Jenkins pipeline
def multi_confs = [ "sc573-gen6", "imx8mp-evk" ]

// target images for the Jenkins pipeline
def images = [ "irma6-deploy", "irma6-maintenance", "irma6-dev" ]

// The image used for populating the SDK
def sdk_image = "irma6-maintenance" 

// Make multi_confs parsable as environment variable
def multi_confs_string = multi_confs.join(' ')

// Make images parsable as environment variable
def images_string = images.join(' ')

// Generate parallel & dynamic compile steps
def parallelBaseImageStagesMap = multi_confs.collectEntries {
    ["${it}" : generateBaseImageStages(it)]  
}

def generateBaseImageStages(multi_conf) {
    return {
        stage("Reproduce ${multi_conf} Base Image") {
            awsCodeBuild buildSpecFile: 'buildspecs/reproduce_base_image.yml',
                credentialsType: 'keys',
                downloadArtifacts: 'false',
                region: 'eu-central-1',
                sourceControlType: 'project',
                sourceTypeOverride: 'S3',
                sourceLocationOverride: "${S3_TEMP_LOCATION}/${GIT_TAG}/${BASE_SOURCES_TEMP_ARTIFACT}",
                projectName: 'iris-devops-kas-large-amd-codebuild',
                envVariables: "[ { MULTI_CONF, $multi_conf }, { GIT_TAG, $GIT_TAG }, { HOME, /home/builder } ]"
        }
    }
}

def parallelReleaseImageStagesMap = multi_confs.collectEntries {
    ["${it}" : generateReleaseImageStages(it, images_string, sdk_image)]
}

def generateReleaseImageStages(multi_conf, images_string, sdk_image) {
    return {
        stage("Build ${multi_conf} Firmware Images") {
            awsCodeBuild buildSpecFile: 'buildspecs/build_firmware_images_release.yml',
                credentialsType: 'keys',
                downloadArtifacts: 'false',
                region: 'eu-central-1',
                sourceControlType: 'project',
                sourceTypeOverride: 'S3',
                sourceLocationOverride: "${S3_TEMP_LOCATION}/${GIT_TAG}/${BASE_SOURCES_TEMP_ARTIFACT}",
                artifactTypeOverride: 'S3',
                artifactLocationOverride: "${S3_TEMP_LOCATION}",
                artifactPathOverride: "${GIT_TAG}",
                artifactNamespaceOverride: 'NONE',
                artifactNameOverride: "${multi_conf}-${RELEASE_TEMP_ARTIFACT}",
                artifactPackagingOverride: 'ZIP',
                projectName: 'iris-devops-kas-large-amd-codebuild',
                envVariables: "[ { MULTI_CONF, $multi_conf }, { GIT_TAG, $GIT_TAG }, { HOME, /home/builder }, { IMAGES, $images_string }, { SDK_IMAGE, $sdk_image } ]"
        }
    }
}


pipeline {
    agent any
    options {
        disableConcurrentBuilds()
    }
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
                    env.RELEASE_TEMP_ARTIFACT = sh(script: 'echo -n "$(git describe --tag --always)-release.zip"', returnStdout: true).trim()
                }
            }
        }

        // Download the base sources for copyleft compliance
        stage('Download Base Sources') {
            steps {
                awsCodeBuild buildSpecFile: 'buildspecs/fetch_base_sources.yml',
                    projectName: 'iris-devops-kas-large-arm-codebuild',
                    credentialsType: 'keys',
                    downloadArtifacts: 'false',
                    region: 'eu-central-1',
                    sourceControlType: 'jenkins',
                    sourceTypeOverride: 'S3',
                    sourceLocationOverride: "${S3_TEMP_LOCATION}/${GIT_TAG}/iris-devops-fetch-artifacts.zip",
                    artifactTypeOverride: 'S3',
                    artifactLocationOverride: "${S3_TEMP_LOCATION}",
                    artifactPathOverride: "${GIT_TAG}",
                    artifactNamespaceOverride: 'NONE',
                    artifactNameOverride: "${BASE_SOURCES_TEMP_ARTIFACT}",
                    artifactPackagingOverride: 'ZIP',
                    envVariables: "[{ MULTI_CONFS, $multi_confs_string }, { GIT_TAG, $GIT_TAG }, { HOME, /home/builder }]"
            }
        }
        stage('Build Images') {
            parallel {
                // Validate that the base image compiles for all multiconfigs (copyleft compliance)
                stage('Verify Base Image Reproducibility') {
                    steps {
                        script {
                            parallel parallelBaseImageStagesMap
                        }
                    }
                }
                // Build the firmware releases
                stage('Build Firmware Releases') {
                    steps {
                        script {
                            parallel parallelReleaseImageStagesMap
                        }
                    }
                }
            }
        }

        //// store artifacts in a meaningful manner & prepare caching for future builds
        //stage('Archive Release Artifacts') {
        //    steps {
        //        awsCodeBuild buildSpecFile: 'buildspecs/archive_release.yml',
        //            projectName: 'iris-devops-kas-large-arm-codebuild',
        //            credentialsType: 'keys',
        //            downloadArtifacts: 'false',
        //            region: 'eu-central-1',
        //            sourceControlType: 'jenkins',
        //            sourceTypeOverride: 'S3',
        //            sourceLocationOverride: "${S3_TEMP_LOCATION}/${GIT_TAG}/iris-devops-fetch-artifacts.zip",
        //            artifactTypeOverride: 'S3',
        //            artifactLocationOverride: "${S3_LOCATION}",
        //            artifactPathOverride: "/releases/${GIT_TAG}",
        //            artifactNamespaceOverride: 'NONE',
        //            artifactNameOverride: "${BASE_SOURCES_TEMP_ARTIFACT}",
        //            artifactPackagingOverride: 'NONE',
        //            envVariables: "[{ MULTI_CONFS, $multi_confs_string }, { GIT_TAG, $GIT_TAG }, { HOME, /home/builder }]"
        //    }
        //}
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
