CURRENT_DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))
KAS_WORK_DIR ?= $(CURRENT_DIR)
KAS_BUILD_DIR ?= $(KAS_WORK_DIR)/build
DL_DIR ?= $(KAS_BUILD_DIR)/dl_dir
TMPDIR ?= $(KAS_BUILD_DIR)/tmp
MC ?= sc573-gen6
DOCKER ?= yes
BUILD_ENV = KAS_BUILD_DIR=$(KAS_BUILD_DIR) DL_DIR=$(DL_DIR) TMPDIR=$(TMPDIR)
ifeq ($(DOCKER), yes)
UID ?= $(shell id -u)
GID ?= $(shell id -g)
BUILD_ENV += USER_ID=$(UID) GROUP_ID=$(GID)
PREFIX ?= $(BUILD_ENV) docker-compose run -e KAS_BUILD_DIR -e DL_DIR -e TMPDIR --rm
else
PREFIX ?= $(BUILD_ENV)
endif
BUILD_CMD = $(PREFIX) kas

release: clean
	$(MAKE) license-compliance
	$(MAKE) release-build
	tar cf release.tar base-sources.tar.gz update_files.tar.gz licenses.tar.gz
	rm -f base-sources.tar.gz update_files.tar.gz licenses.tar.gz

clean-build:
ifneq (,$(wildcard $(KAS_BUILD_DIR)))
	rm -rf $(TMPDIR)
	rm -rf $(DL_DIR)
	rm -rf $(KAS_BUILD_DIR) 
endif

clean:
ifneq (,$(wildcard release.tar))
	rm -rf release.tar
endif

license-compliance: clean-build
	$(MAKE) base-build

base-build-fetch:
	$(BUILD_CMD) shell -c "bitbake mc:$(MC):irma-six-base --runonly=fetch" kas-irma6-base.yml
	rm -rf $(DL_DIR)/git2/*
	touch base-sources.tar.gz
	tar --exclude=release.tar --exclude=update_files.tar.gz --exclude=licenses.tar.gz --exclude=base-sources.tar.gz -czf base-sources.tar.gz .

release-build:
	$(BUILD_CMD) shell -c "bitbake mc:$(MC):irma-six-maintenance mc:$(MC):irma-six-dev mc:$(MC):irma-six-deploy" kas-irma6-base.yml:kas-irma6-pa.yml
	tar czf update_files.tar.gz -C $(TMPDIR)/deploy/images/$(MC) update_files

base-build: base-build-fetch
	$(BUILD_CMD) shell -c "bitbake mc:$(MC):irma-six-base" kas-irma6-base.yml:kas-offline-build.yml
	tar czf licenses.tar.gz -C $(TMPDIR)/deploy/ licenses

build:
	$(BUILD_CMD) shell -c "bitbake mc:$(MC):irma-six-maintenance mc:$(MC):irma-six-dev mc:$(MC):irma-six-deploy" kas-irma6-base.yml:kas-irma6-pa.yml
