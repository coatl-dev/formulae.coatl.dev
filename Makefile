TAP := coatl-dev/coatl-dev

all: tap core cleanup

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  <none|all>: Generate formulae information for homebrew-core and $(TAP)."
	@echo "  core:       Generate formulae information for homebrew-core."
	@echo "  tap:        Generate formulae information for $(TAP)."
	@echo "  cleanup:    Remove intermediate files."
	@echo "  help:       Display this help message."

core:
	@echo "Getting homebrew/core referenced formulae data..."
	@./script/generate-core.sh

tap:
	@echo "Generating formulae data for $(TAP)..."
	@./script/generate-tap.sh $(TAP)

cleanup:
	@echo "Cleaning up temporary files..."
	@rm -f script/*.txt
