# Bashi Test Runner Makefile
#
# This Makefile provides convenient targets for running Bashi tests.
#
# Usage:
#   make              - Show help message with available targets
#   make test         - Run all tests in ./tests folder
#   make test OPTS='--tap --trace' - Run all tests with additional options
#   make test FILE=./tests/basic.bashi.yaml - Run a specific test file
#   make test FILE=./tests/basic.bashi.yaml OPTS='--tap' - Run specific test with options
#   make lint         - Run shellcheck on all shell scripts
#   make install-bats - Install bats-core from GitHub releases
#   make install-bats BATS_VERSION=1.12.0 - Install a specific version of bats-core
#
# Variables:
#   OPTS         - Additional command-line options to pass to bashi
#   FILE         - Path to a specific test file (if not set, runs all tests in ./tests)
#   BATS_VERSION - Version of bats-core to install (default: 1.13.0)
#   PREFIX       - Installation prefix for bats-core (default: $HOME/.local)

# Default variables
BATS_VERSION ?= 1.13.0
PREFIX ?= $(HOME)/.local

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make test [OPTS='--tap --trace'] [FILE=path/to/test.bashi.yaml] - Run all tests or specific test file"
	@echo "  make lint                                                       - Run shellcheck on all shell scripts"
	@echo "  make install-bats [BATS_VERSION=1.13.0] [PREFIX=\$$HOME/.local]    - Install bats-core from GitHub"
	@echo "  make help                                                       - Show this help message"

.PHONY: test 
test:
ifdef FILE
	@echo "Running test: $(FILE)"
	@./src/bashi $(OPTS) "$(FILE)"
else
	@for test_file in ./tests/*.bashi.yaml; do \
		echo "Running test: $$test_file"; \
		./src/bashi $(OPTS) "$$test_file"; \
	done
	@for test_file in ./docs/examples/*.bashi.yaml; do \
		echo "Running test: $$test_file"; \
		./src/bashi $(OPTS) "$$test_file"; \
	done
endif

.PHONY: lint
lint:
	@echo "Running shellcheck on all shell scripts..."
	@shellcheck src/bashi src/lib/*.sh

.PHONY: install-bats
install-bats:
	@echo "Installing bats-core v$(BATS_VERSION) to $(PREFIX)..."
	@if [ "$(PREFIX)" = "/usr/local" ] || [ "$(PREFIX)" = "/usr" ]; then \
		echo "Note: Installing to $(PREFIX) requires sudo privileges"; \
	fi
	@TEMP_DIR=$$(mktemp -d) && \
	cd "$$TEMP_DIR" && \
	echo "Downloading bats-core v$(BATS_VERSION)..." && \
	wget -q https://github.com/bats-core/bats-core/archive/refs/tags/v$(BATS_VERSION).tar.gz && \
	echo "Extracting archive..." && \
	tar -xzf v$(BATS_VERSION).tar.gz && \
	cd bats-core-$(BATS_VERSION) && \
	echo "Running install.sh..." && \
	if [ "$(PREFIX)" = "/usr/local" ] || [ "$(PREFIX)" = "/usr" ]; then \
		sudo ./install.sh $(PREFIX); \
	else \
		./install.sh $(PREFIX); \
	fi && \
	cd - > /dev/null && \
	cd - > /dev/null && \
	rm -rf "$$TEMP_DIR" && \
	echo "Successfully installed bats-core v$(BATS_VERSION) to $(PREFIX)/bin/bats"
