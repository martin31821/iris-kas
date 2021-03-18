# Yocto-KAS

## What is KAS?
KAS is a bitbake wrapper developed and maintained by Siemens.
It enables easier management, minimises build setup steps and repository management.

## How does it work?
The file `kas-irma6.yml` is the main configuration file and describes how KAS should prepare our build environment. It is also used to generate various config files, such as yocto's `local.conf`.
The file `kas-developer.yml` contains build environment specific configurations, e.g. where caches are saved.

For a detailed documentation, please visit [https://kas.readthedocs.io/en/latest/](https://kas.readthedocs.io/en/latest/)


### Example usages

#### building the current gen6 deploy firmware for the ADI sharc using the developer specific config
`kas shell -c "bitbake mc:sc573-gen6:irma-six-deploy" kas-irma6.yml:kas-developer.yml`

#### building all the gen6 firmwares for the ADI sharc
`kas shell -c "bitbake mc:sc573-gen6:irma-six-maintenance mc:sc573-gen6:irma-six-dev mc:sc573-gen6:irma-six-deploy" kas-irma6.yml:kas-developer.yml`
