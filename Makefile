PROJECT_DIR := $(CURDIR)

.PHONY: help docs website verify

help:
	@echo "NebulaOS project helpers"
	@echo "  make docs       - open the documentation overview"
	@echo "  make website    - preview the website entrypoint"
	@echo "  make verify     - confirm the project files exist"

docs:
	@echo "Documentation is in docs/"

website:
	@echo "Website entrypoint: website/index.html"

verify:
	@ls -1 $(PROJECT_DIR)
	@find $(PROJECT_DIR)/docs $(PROJECT_DIR)/scripts $(PROJECT_DIR)/themes $(PROJECT_DIR)/website -maxdepth 2 -type f | sort
