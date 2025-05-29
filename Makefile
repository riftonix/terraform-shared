MODULE_DIRS := $(shell find . -type f -name '*.tf' -exec dirname {} \; | sort | uniq)

lint:
	tofu fmt -recursive
	@for CURRENT_MODULE_DIR in $(MODULE_DIRS); do \
		terraform-docs markdown table --output-file README.md --output-mode inject $$CURRENT_MODULE_DIR; \
	done
