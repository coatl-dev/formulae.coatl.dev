TAP := coatl-dev/coatl-dev

tap:
	@echo "Generating formulae data for $(TAP)..."
	@./scripts/tap.sh $(TAP)

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  <none|tap>: Generate formulae information for homebrew-core and $(TAP)."
	@echo "  help:       Display this help message."
