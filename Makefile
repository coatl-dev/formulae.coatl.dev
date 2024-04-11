TAP := coatl-dev/coatl-dev

tap:
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
	@echo "Generating formulae data for $(TAP)..."
	@./scripts/tap.sh $(TAP)
	@echo "Cleaning up temporary files..."
	@rm -f scripts/*.in
	@rm -f scripts/*.txt

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  <none|tap>: Generate formulae information for homebrew-core and $(TAP)."
	@echo "  help:       Display this help message."
