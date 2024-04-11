#!/bin/bash

# Create formulae-core files
FORMULAE_CONFLICTS_IN="$CWD/formulae-core-conflicts.in"
echo -n > "$FORMULAE_CONFLICTS_IN"
FORMULAE_CONFLICTS_TXT="$CWD/formulae-core-conflicts.txt"
echo -n > "$FORMULAE_CONFLICTS_TXT"

FORMULAE_CORE_IN="$CWD/formulae-core.in"
echo -n > "$FORMULAE_CORE_IN"
FORMULAE_CORE_TXT="$CWD/formulae-core.txt"
echo -n > "$FORMULAE_CORE_TXT"

FORMULAE_DEPS_IN="$CWD/formulae-core-deps.in"
echo -n > "$FORMULAE_DEPS_IN"
FORMULAE_DEPS_TXT="$CWD/formulae-core-deps.txt"
echo -n > "$FORMULAE_DEPS_TXT"

FORMULAE_FINAL_IN="$CWD/formulae-final.in"
echo -n > "$FORMULAE_FINAL_IN"
FORMULAE_FINAL_TXT="$CWD/formulae-final.txt"
echo -n > "$FORMULAE_FINAL_TXT"

FORMULAE_VERSIONS_IN="$CWD/formulae-core-versions.in"
echo -n > "$FORMULAE_VERSIONS_IN"
FORMULAE_VERSIONS_TXT="$CWD/formulae-core-versions.txt"
echo -n > "$FORMULAE_VERSIONS_TXT"

MERGED_FORMULAE_IN="$CWD/formulae-core-merged.in"
echo -n > "$MERGED_FORMULAE_IN"
MERGED_FORMULAE_TXT="$CWD/formulae-core-merged.txt"
echo -n > "$MERGED_FORMULAE_TXT"

FORMULA_CORE_PATH="formula-core"

function _cleanup_file() {
  if [ $# -ne 2 ]; then
    echo "Usage: _cleanup_file <in_file> <out_file>"
    return 1
  fi

  local in_file="$1"
  local out_file="$2"

  sort "$in_file" | uniq > "$out_file"
  rm -f "$in_file"
}

function _get_json_elements() {
  if [ $# -ne 2 ]; then
    echo "Usage: _get_json_elements <formula> <action>"
    return 1
  fi

  local formula="$1"
  local action="$2"

  if [[ "$action" == "conflicts" ]]; then
    output_file="$FORMULAE_CONFLICTS_IN"
    selector='.[] | .conflicts_with[]'
  elif [[ "$action" == "versions" ]]; then
    output_file="$FORMULAE_VERSIONS_IN"
    selector='.[] | .versioned_formulae[]'
  else
    echo "Invalid action. Use 'conflicts' or 'versions'."
    exit 1
  fi

  brew info --json --formula "$formula" | jq -r "$selector" >> "$output_file"
}

function _merge_files() {
  if [ $# -ne 3 ]; then
    echo "Usage: merge_files <file1> <file2> <output_file>"
    return 1
  fi

  local file1="$1"
  local file2="$2"
  local output_file="$3"

  # Check if both input files exist
  if [ ! -f "$file1" ]; then
    echo "Error: File '$file1' not found."
    return 1
  fi

  if [ ! -f "$file2" ]; then
    echo "Error: File '$file2' not found."
    return 1
  fi

  # Concatenate contents of file1 and file2 into output_file
  cat "$file1" "$file2" > "$output_file"
}

function create_html() {
  if [ $# -ne 2 ]; then
    echo "Usage: create_html <formulae_path> <formula>"
    return 1
  fi

  local formulae_path="$1"
  local formula="$2"
  local html_in="_formula.html.in"
  local html_out="$formulae_path/$formula.html"

  cp "$html_in" "$html_out"
  sed -i '' "s/TITLE/$formula/g" "$html_out"
}

function create_json() {
  if [ $# -ne 2 ]; then
    echo "Usage: create_json <formulae_path> <formula>"
    return 1
  fi

  local formulae_path="$1"
  local formula="$2"
  local json_in="_api_formula.json.in"
  local json_out="api/$formulae_path/$formula.json"

  cp "$json_in" "$json_out"
}

function generate_conflicts_txt_file() {
  _merge_files "$FORMULAE_VERSIONS_TXT" "$FORMULAE_CONFLICTS_IN" "$MERGED_FORMULAE_IN"
  _cleanup_file "$MERGED_FORMULAE_IN" "$FORMULAE_CONFLICTS_TXT"
}

function generate_formulae_txt() {
  _merge_files "$FORMULAE_DEPS_TXT" "$FORMULAE_FINAL_TXT" "$FORMULAE_CORE_IN"
  _cleanup_file "$FORMULAE_CORE_IN" "$FORMULAE_CORE_TXT"
}

function generate_versions_txt_file() {
  _merge_files "$FORMULAE_DEPS_TXT" "$FORMULAE_VERSIONS_IN" "$MERGED_FORMULAE_IN"
  _cleanup_file "$MERGED_FORMULAE_IN" "$FORMULAE_VERSIONS_TXT"
}

function generate_core_formulae_txt() {
  echo "Preparing homebrew-core formulae..."
  _merge_files "$FORMULAE_DEPS_TXT" "$FORMULAE_VERSIONS_TXT" "$MERGED_FORMULAE_IN"
  _cleanup_file "$MERGED_FORMULAE_IN" "$MERGED_FORMULAE_TXT"
}

function get_formula_deps() {
  if [ $# -ne 1 ]; then
    echo "Usage: get_formula_deps <formula>"
    return 1
  fi

  local formula="$1"
  brew deps --include-build --formula "$formula" >> "$FORMULAE_DEPS_IN"
  _cleanup_file "$FORMULAE_DEPS_IN" "$FORMULAE_DEPS_TXT"
}

function get_formula_info() {
  if [ $# -ne 1 ]; then
    echo "Usage: get_formula_info <formula>"
    return 1
  fi

  local formula="$1"
  brew info --json --formula "$formula" | sed -E 's/^\[//; s/\]$//' | jq . > "_data/formula/$formula.json"
}

function get_formula_conflicts() {
  if [ $# -ne 1 ]; then
    echo "Usage: get_formula_versions <formula>"
    return 1
  fi

  local formula="$1"
  local action="conflicts"

  _get_json_elements "$formula" "$action"
}

function get_formulae_conflicts() {
  echo "Getting formulae conflicts..."
  while IFS= read -r formula; do

    # Get homebrew-core references
    get_formula_conflicts "$formula"

  done < "$FORMULAE_VERSIONS_TXT"
  generate_conflicts_txt_file
}

function get_formulae_deps() {
  echo "Getting formulae dependencies..."
  cp "$FORMULAE_CONFLICTS_TXT" "$FORMULAE_FINAL_TXT"
  while IFS= read -r formula; do

    # Get homebrew-core references
    get_formula_deps "$formula"

  done < "$FORMULAE_FINAL_TXT"
}

function get_formula_versions() {
  if [ $# -ne 1 ]; then
    echo "Usage: get_formula_versions <formula>"
    return 1
  fi

  local formula="$1"
  local action="versions"

  _get_json_elements "$formula" "$action"
}

function get_formulae_versions() {
  echo "Getting formulae versions..."
  while IFS= read -r formula; do

    # Get homebrew-core references
    get_formula_versions "$formula"

  done < "$FORMULAE_DEPS_TXT"

  generate_versions_txt_file
}

function init_dirs() {
  if [ $# -ne 1 ]; then
    echo "Usage: init_dirs <formulae_path>"
    return 1
  fi

  local formulae_path="$1"
  local directories=( "$formulae_path" "_data/$formulae_path" "api/$formulae_path" )

  for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
      mkdir -p "$dir"
    fi
  done
}

function _get_json() {
  while IFS= read -r formula; do
    echo "Generating data for $formula..."
    # Download and format JSON
    curl -s "https://formulae.brew.sh/api/formula/$formula.json" | jq . > "_data/$FORMULA_CORE_PATH/$formula.json"

    # Make HTML file
    create_html "$FORMULA_CORE_PATH" "$formula"

    # Make JSON file
    create_json "$FORMULA_CORE_PATH" "$formula"

  done < "$FORMULAE_CORE_TXT"
}

function generate_core_formulae() {
  init_dirs "$FORMULA_CORE_PATH"
  generate_formulae_txt
  _get_json
}
