#!/bin/bash
# shellcheck source=/dev/null

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly CWD

source "$CWD/main.sh"

# Global variables
TAP="$1"
TAP_FORMULAE="$CWD/formulae-tap.txt"
FORMULA_PATH="formula"

if [ $# -eq 0 ]; then
    echo "Error: No argument provided. Usage: $0 <TAP>"
    exit 1
fi

function init_tap() {
  find_tap=$(brew tap | grep "$TAP")

  if [[ -z $find_tap ]]; then
      echo "Tap $TAP not found..."
      brew tap "$TAP"
  fi
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
  grep_tap="${TAP//\//\\/}"

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
  # 1. Create directories
  init_dirs "$FORMULA_PATH"
  # 2. brew tap <TAP>
  init_tap
  # 3. Get <TAP> formulae
  get_tap_formulae
  # 4. Create HTML and JSON files for <TAP> formulae and get build dependencies
  generate_tap_formulae
  # >========================================<
  echo "Preparing homebrew-core formulae..."
  # >========================================<
  # 5. Genenerate versioned formulae for core
  get_formulae_versions
  # # 6. Generate conflicts file
  get_formulae_conflicts
  # 7. Get deps for all formulae
  get_formulae_deps
  # 8. Generate core formulae file
  generate_core_formulae_txt
  # 9. Generate core formulae HTML and JSON files
  generate_core_formulae # second to last
  # 10.cleanup
  find_replace # last step
}

main
