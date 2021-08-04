// SPDX-License-Identifier: MIT
// Copyright (C) 2021 iris-GmbH infrared & intelligent sensors

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
        SDK_IMAGE = 'irma6-maintenance'
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
                    envVariables: "[{ MULTI_CONFS, 'sc573-gen6 imx8mp-evk' }, { GIT_TAG, $GIT_TAG }, { HOME, /home/builder }]"
            }
        }

        stage('Reproduce Base Images') {
            matrix {
                axes {
                    axis {
                        name 'MULTI_CONF'
                        values 'sc573-gen6', 'imx8mp-evk'
                    }
                }
                stages {
                    stage("Reproduce ${MULTI_CONF} Base Image") {
                        steps {
                            awsCodeBuild buildSpecFile: 'buildspecs/reproduce_base_image.yml',
                                credentialsType: 'keys',
                                downloadArtifacts: 'false',
                                region: 'eu-central-1',
                                sourceControlType: 'project',
                                sourceTypeOverride: 'S3',
                                sourceLocationOverride: "${S3_TEMP_LOCATION}/${GIT_TAG}/${BASE_SOURCES_TEMP_ARTIFACT}",
                                projectName: 'iris-devops-kas-large-amd-codebuild',
                                envVariables: "[ { MULTI_CONF, $MULTI_CONF }, { GIT_TAG, $GIT_TAG }, { HOME, /home/builder } ]"
                        }
                    }
                }
            }
        }

        stage('Build Firmware Images') {
            matrix {
                axes {
                    axis {
                        name 'MULTI_CONF'
                        values 'sc573-gen6', 'imx8mp-evk'
                    }
                    axis {
                        name 'IMAGES'
                        values 'irma6-deploy irma6-maintenance irma6-dev'
                    }
                }
                stages {
                    stage("Build ${MULTI_CONF} Firmware Images") {
                        steps {
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
                                envVariables: "[ { MULTI_CONF, $MULTI_CONF }, { GIT_TAG, $GIT_TAG }, { HOME, /home/builder }, { IMAGES, $IMAGES }, { SDK_IMAGE, $sdk_image } ]"
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
