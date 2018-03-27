#
PACKAGENAME ?= ansible-role-service-ci-tool-stack
VERSION ?= latest

version:
	@echo $(PACKAGENAME) $(VERSION)
package: build
	@echo '# $@ STARTING'
	@bash ./tools/package.sh $(PACKAGENAME) $(VERSION)
	@echo '# $@ SUCCESS'
clean: clean-dist clean-build
clean-dist:
	rm -rf dist ||true
clean-build:
	rm -rf build ||true

.PHONY: test build
build: clean build-step

build-step:
	@echo '# $@ STARTING'
	bash ./tools/build.sh $(PACKAGENAME) $(VERSION) ANSIBLE_GALAXY_FORCE="-f"
	@echo '# $@ SUCCESS'

test: build unit-test
	@echo '# $@ SUCCESS'

unit-test:
	@echo '# $@ STARTING'
	( cd build/tests && bash unit-test.sh $(PACKAGENAME) $(VERSION) )
	@echo '# $@ SUCCESS'

publish: dist/$(PACKAGENAME)-$(VERSION).tar.gz
	@echo "# $@ STARTING"
	bash ./tools/publish.sh $(PACKAGENAME) $(VERSION)
	@echo '# $@ SUCCESS'
