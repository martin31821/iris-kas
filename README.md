# iris-kas

## What is KAS?
KAS is a bitbake wrapper developed and maintained by Siemens.
It minimises build setup steps and repository management.

## How does it work?
- The file `kas-irma6.yml` is the main configuration file for our custom Linux distribution and describes how KAS should prepare our build environment. It is also used to generate various config files, such as yocto's `local.conf`.
- The file `kas-irma6-pa.yml` contains the recipes and configuration for building our proprietary platform application on top of the iris Linux distribution.
- The file `kas-developer.yml` contains build environment specific configurations, e.g. where caches are saved.

For a detailed documentation, please visit [https://kas.readthedocs.io/en/latest/](https://kas.readthedocs.io/en/latest/)


## Example usages

### Using a native KAS installation

#### Building the base Linux distribution for the ADI sharc
As a IRIS customer you might be interested in building our base Linux distribution, which is configured for running our proprietary platform application (not included). This can be done by running the following:
`kas shell -c "bitbake mc:sc573-gen6:irma-six-base" kas-irma6.yml`

#### Building the current gen6 deploy firmware for the ADI sharc using the developer specific config
`kas shell -c "bitbake mc:sc573-gen6:irma-six-deploy" kas-irma6.yml:kas-irma6-pa.yml::kas-developer.yml`

#### Building all the gen6 firmwares for the ADI sharc
`kas shell -c "bitbake mc:sc573-gen6:irma-six-maintenance mc:sc573-gen6:irma-six-dev mc:sc573-gen6:irma-six-deploy" kas-irma6.yml:kas-irma6-pa.yml:kas-developer.yml`

#### Building for other machine configs
Replace the multiconfig string in your build command (e.g. mc:sc573-gen6:irma-six-maintenance -> mc:imx8mp-evk:irma-six-maintenance).
Available multiconfigs are listed in the *target* section of the `kas-irma6.yml` file.

### Using Docker

Make sure you have Docker and docker-compose installed. Then prepend the commands from above with the following:
`USER_ID=$UID docker-compose run --rm `

## License
This repository is licensed under the terms of the MIT (see LICENSE file).
