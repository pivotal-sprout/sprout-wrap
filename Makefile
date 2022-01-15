SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

REPO_NAME := sprout-wrap
REPO := $(REPO_NAME)
#REV := $(shell TZ=UTC date +'%Y%m%dT%H%M%S')-$(shell git rev-parse --short HEAD)

# If in CI, use soloistrc from ./test/fixtures
ifeq ($(CI),true)
  SOLOIST_PREFIX := ./test/fixtures/
else
  SOLOIST_PREFIX := ./
endif
TEMP_PATH := $(SOLOIST_PREFIX)/tmp/
BREWFILE_PATH ?= $(TEMP_PATH)Brewfile
SOLOISTRC_PATH ?= $(SOLOIST_PREFIX)soloistrc

.PHONY: clean librarian-clean librarian-clean-install librarian-update bootstrap test sprout

include $(SELF_DIR)/main.mk

test: soloistrc* ## Run test to validate soloistrc files
	for f in $? ; do bundle exec ruby -r yaml -e 'YAML.load_file ARGV[0];printf(".")' "$$f" ; done


$(SELF_DIR)/cookbooks Cheffile.lock: ## no-help
	bundle exec librarian-chef install

librarian-clean: ## Cleans up all cookbooks & librarian cache files
	bundle exec librarian-chef clean
	rm -rf tmp/librarian/
	rm -rf cookbooks/

librarian-install: $(SELF_DIR)/cookbooks Cheffile.lock ## Runs librarian-chef install, if needed

librarian-clean-install: librarian-clean librarian-install ## Runs librarian-clean then install

ifeq (librarian-update,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "librarian-update"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

librarian-update: ## Update librarian managed cookbook(s)
	bundle exec librarian-chef update $(RUN_ARGS)

bootstrap: ## Run bootstrap & soloist on this node
	./bootstrap-scripts/bootstrap.sh

sprout: ## Run soloist on this node via sprout helper script
	caffeinate ./sprout

# Testing in /tmp first...
.PHONY: brewfile
brewfile: $(BREWFILE_PATH) ## Convert soloistrc to Brewfile
$(BREWFILE_PATH): $(SOLOISTRC_PATH)
	mkdir -p $(TEMP_PATH)
	export SOLOISTRC_PATH=$(SOLOISTRC_PATH) BREWFILE_PATH=$(BREWFILE_PATH); \
    bundle exec ruby ./bin/convert_soloistrc_to_brewfile.rb

clean:: ## Remove temporary/cache files.
	[ -d '$(TEMP_PATH)' ] && rm -rf $(TEMP_PATH) || true
	[ -d 'tmp/librarian/' ] && rm -rf tmp/librarian/ || true
	[ -d '$(TEMP_PATH)' ] && rmdir $(TEMP_PATH) || true
	[ -d 'nodes/' ] && sudo rm -rf nodes/ || true
