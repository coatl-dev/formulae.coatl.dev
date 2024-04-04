TAP ?=

all: tap core

help:
	@echo "Usage: make [target] TAP=<[user|org]/repo>"
	@echo ""
	@echo "Targets:"
	@echo "  <none>: A blank, or no target will run 'all' target."
	@echo "  all:    Run 'get-tap' and 'get-core' targets."
	@echo "  core:   Generate formulae information for homebrew-core."
	@echo "  tap:    Generate formulae information for TAP."
	@echo "  help:   Display this help message."

core:
	@echo "Getting homebrew/core referenced formulae data..."
	@./script/generate-core.sh

tap:
ifeq ($(strip $(TAP)),)
	$(error "Argument TAP is required. E.g., make [all|tap] TAP=<[user|org]/repo>")
endif
	@echo "Tapping $(TAP)..."
	@$(shell brew tap $(TAP))
	@echo "Generating formulae data for $(TAP)..."
	@./script/generate.rb $(TAP)
	@echo "Updating core dependencies on $(TAP) formulae..."
	@./script/find-replace.sh
