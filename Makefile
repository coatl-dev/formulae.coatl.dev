TAP := coatl-dev/coatl-dev

all: init tap core cleanup

cleanup:
	@echo "Cleaning up temporary files..."
	@rm -f script/*.txt

core:
	@echo "Getting homebrew/core referenced formulae data..."
	@./script/generate-core.sh

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  <none|all>: Generate formulae information for homebrew-core and $(TAP)."
	@echo "  core:       Generate formulae information for homebrew-core."
	@echo "  tap:        Generate formulae information for $(TAP)."
	@echo "  cleanup:    Remove intermediate files."
	@echo "  help:       Display this help message."

init:
	@echo "Preparing _data..."
	@rm -f _data/*.json
	@rm -f _data/formula/*.json
	@rm -f _data/formula-core/*.json
	@echo "Preparing api..."
	@rm -f api/formula/*.json
	@rm -f api/formula-core/*.json
	@echo "Preparing tap formulae..."
	@rm -f formula/*.html
	@rm -f formula-core/*.html

tap:
	@echo "Generating formulae data for $(TAP)..."
	@./script/generate-tap.sh $(TAP)
