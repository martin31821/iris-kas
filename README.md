# iris-kas

## Maintainers
- Jasper Orschulko <Jasper [dot] Orschulko [att] iris-sensing.com>
- Erik Schumacher <Erik [dot] Schumacher [att] iris-sensing.com>

## What is KAS?
KAS is a bitbake wrapper developed and maintained by Siemens.
It minimises build setup steps and repository management.

## How does it work?
- The file `kas-irma6-base.yml` is the main configuration file for our custom Linux distribution and describes how KAS should prepare our build environment. It is also used to generate various config files, such as yocto's `local.conf`.
- The file `kas-irma6-pa.yml` contains the recipes and configuration for building our proprietary platform application on top of the iris Linux distribution.
- The file `kas-developer.yml` contains build environment specific configurations, e.g. where caches are saved.

For a detailed documentation, please visit [https://kas.readthedocs.io/en/latest/](https://kas.readthedocs.io/en/latest/)

## Prerequisites
### Native Installation
- [native KAS installation](https://kas.readthedocs.io/en/latest/userguide.html#dependencies-installation) on a [supported host system prepared for yocto builds](https://www.yoctoproject.org/docs/3.1/mega-manual/mega-manual.html#brief-compatible-distro)
- as IRIS developer: SSH key (without password protection) configured for accessing our private git repositories

### Docker
- Linux, Mac or WSL in Windows (officially we only support Linux)
- [installed and running docker daemon](https://docs.docker.com/engine/install/)
- [installed docker-compose](https://docs.docker.com/compose/install/)
- as IRIS developer: SSH folder containing a SSH key (without password protection) configured for accessing our private git repositories, as well as a known_host file containing our private git server
- currently no SELinux support


## Example usages

### As an IRIS developer

#### Building the current gen6 deploy firmware for the ADI sharc using the developer specific config
`kas shell -c "bitbake mc:sc573-gen6:irma-six-deploy" kas-irma6-base.yml:kas-irma6-pa.yml:kas-developer.yml`

#### Building all the gen6 firmwares for the ADI sharc
`kas shell -c "bitbake mc:sc573-gen6:irma-six-maintenance mc:sc573-gen6:irma-six-dev mc:sc573-gen6:irma-six-deploy" kas-irma6-base.yml:kas-irma6-pa.yml:kas-developer.yml`

#### Building for other machine configs
Replace the multiconfig string in your build command (e.g. `mc:sc573-gen6:irma-six-maintenance` -> `mc:imx8mp-evk:irma-six-maintenance`).
Available multiconfigs are listed in the *target* section of the `kas-irma6-base.yml` file.

### As an IRIS customer

#### Build our current base Linux distribution
As an IRIS customer you might be interested in building our base Linux distribution, which is configured for running our proprietary platform application (not included). This can be done by running the following command:

`kas shell -c "bitbake mc:sc573-gen6:irma-six-base" kas-irma6-base.yml`

#### Build our base Linux distribution from a source dump
As an IRIS customer you might want to build the base Linux image belonging to a specific firmware version using a provided source code dump. This can be done using the following from within the source code dump command:

`kas shell -c "bitbake mc:sc573-gen6:irma-six-base" kas-irma6-base.yml:kas-offline-build.yml`

### Using Docker

Make sure your setup meets the [docker prerequisites](#prerequisites), then simply prepend the desired command with the following:
`USER_ID=$UID docker-compose run --rm `
