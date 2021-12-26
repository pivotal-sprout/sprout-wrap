SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

define SELF_DIR_NAME
$(shell printf '%s' $${PWD##*/})
endef

DEFAULT_GOAL: help ## no-help

.PHONY: help
help: ## Shows this generated help info for Makefile targets
	@grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | awk '{ c=split($$0,resultArr,/:+/) ; if ( !(resultArr[c-1] in targets) ) { if ( /:.*##/ ) { if ( ! /no-help/ ) { sub(/^.*## ?/," ",resultArr[c]); targets[resultArr[c-1]] = resultArr[c]; } } else { targets[resultArr[c-1]] = "" } } } END { for (target in targets) { printf "\033[36m%-30s\033[0m %s\n", target, targets[target] } }' | sort

#.PHONY: clean
#clean:: ## Remove tepmorary/build files.
#	rm -rf $(GENERATED_OUT)
