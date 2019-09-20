SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

REPO_NAME := sprout-wrap
REPO := $(REPO_NAME)
#REV := $(shell TZ=UTC date +'%Y%m%dT%H%M%S')-$(shell git rev-parse --short HEAD)

.PHONY: clean librarian-clean librarian-clean-install bootstrap test

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

bootstrap: ## Run bootstrap & soloist on this node
	./bootstrap-scripts/bootstrap.sh

clean:: ## Remove temporary/cache files.
	rm -rf tmp/librarian/ 
	rmdir tmp/ || true
	sudo rm -rf nodes/
	rm -f cookies
