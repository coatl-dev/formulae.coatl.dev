#!/bin/bash
# shellcheck source=/dev/null

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly CWD

source "$CWD/main.sh"

# Global variables
TAP_FORMULAE="$CWD/formulae-tap.txt"
FORMULA_PATH="formula"

if [ $# -eq 0 ]; then
    echo "Error: No argument provided. Usage: $0 <TAP>"
    exit 1
fi

function init() {
	echo "Preparing _data..."
	rm -f _data/*.json
	rm -f _data/formula/*.json
	rm -f _data/formula-core/*.json
	echo "Preparing api..."
	rm -f api/formula/*.json
	rm -f api/formula-core/*.json
	echo "Preparing tap formulae..."
	rm -f formula/*.html
	rm -f formula-core/*.html
}

function init_tap() {
  if [ $# -ne 1 ]; then
    echo "Usage: init_tap <TAP>"
    return 1
  fi

  local TAP="$1"

  find_tap=$(brew tap | grep "$TAP")

  if [[ -z $find_tap ]]; then
      echo "Tap $TAP not found..."
      brew tap "$TAP"
  fi
}

function cleanup() {
	echo "Cleaning up temporary files..."
	rm -f scripts/*.in
	rm -f scripts/*.txt
}

function find_replace() {
  keys=(
    "dependencies"
    "build_dependencies"
    "test_dependencies"
  )

  for key in "${keys[@]}"
  do
    find "_data/$FORMULA_PATH" -name "*.json" -type f -exec sed -i '' "s/\"$key\"/\"core_$key\"/g" {} +
  done
}

function get_tap_formulae() {
  if [ $# -ne 1 ]; then
    echo "Usage: get_tap_formulae <TAP>"
    return 1
  fi

  local TAP="$1"
  local grep_tap="${TAP//\//\\/}"

  brew tap-info --json "$TAP" | jq -r '.[]|(.formula_names[])' | sed "s/$grep_tap\///g" > "$TAP_FORMULAE"
}

function generate_tap_formulae() {
  while IFS= read -r formula; do
    echo "Generating data for $formula..."
    # Get formula info in JSON format
    brew info --json --formula "$formula" | sed -E 's/^\[//; s/\]$//' | jq . > "_data/$FORMULA_PATH/$formula.json"

    # Make HTML file
    create_html formula "$formula"

    # Make JSON file
    create_json formula "$formula"

    # Get homebrew-core references
    get_formula_deps "$formula"

  done < "$TAP_FORMULAE"
}

function main() {
  if [ $# -ne 1 ]; then
    echo "Usage: main <TAP>"
    return 1
  fi

  local TAP="$1"

  # Reset directories, in case some formulae are no longer required
  init
  # Create directories
  init_dirs "$FORMULA_PATH"
  # brew tap <TAP>
  init_tap "$TAP"
  # Get <TAP> formulae
  get_tap_formulae "$TAP"
  # Create HTML and JSON files for <TAP> formulae and get build dependencies
  generate_tap_formulae
  # Genenerate versioned formulae for core
  get_formulae_versions
  # Generate conflicts file
  get_formulae_conflicts
  # Get deps for all formulae
  get_formulae_deps
  # Generate core formulae file
  generate_core_formulae_txt
  # Generate core formulae HTML and JSON files
  generate_core_formulae
  # Replace elements in JSON files
  find_replace
  # Final cleanup
  cleanup
}

if [ $# -ne 1 ]; then
  echo "Usage: ./$CWD/tap.sh <TAP>"
  return 1
fi

main "$1"
