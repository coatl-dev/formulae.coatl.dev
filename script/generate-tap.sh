#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly CWD

formulae="$CWD/formulae-tap.txt"

if [ $# -eq 0 ]; then
    echo "Error: No argument provided. Usage: $0 <TAP>"
    exit 1
fi

TAP=$1

find_tap=$(brew tap | grep "$TAP")

if [[ -z $find_tap ]]; then
    echo "Tap $TAP not found..."
    brew tap "$TAP"
fi

grep_tap="${TAP//\//\\/}"

brew tap-info --json "$TAP" | jq -r '.[]|(.formula_names[])' | sed "s/$grep_tap\///g" > "$formulae"

if [ ! -f "$formulae" ]; then
  echo "File '$formulae' does not exist."
  exit 1
fi

# Create formulae-core file
formulae_core_txt="$CWD/formulae-core.txt"
formulae_core_in="$CWD/formulae-core.in"
echo -n > "$formulae_core_in"

while IFS= read -r formula; do
  # Get formulae info in JSON format
  mkdir -p _data/formula
  brew info --json --formula "$formula" | sed -E 's/^\[//; s/\]$//' | jq . > "_data/formula/$formula.json"

  # Get homebrew-core references formulae
  brew deps --include-build "$formula" >> "$formulae_core_in"

  # Make HTML file
  mkdir -p formula-core
  html="formula/$formula.html"
  cat << EOF > "$html"
---
title: "$formula"
layout: formula
---
{{ content }}
EOF

  # Make JSON file
  mkdir -p api/formula
  json="api/formula/$formula.json"
  cat << EOF > "$json"
---
layout: formula_json
---
{{ content }}
EOF
done < "$formulae"

keys=(
  "dependencies"
  "build_dependencies"
  "test_dependencies"
)

for key in "${keys[@]}"
do
  case $OSTYPE in
    darwin*)
      find _data/formula -name "*.json" -type f -exec sed -i '' "s/\"$key\"/\"core_$key\"/g" {} +
      ;;
    linux*)
      find _data/formula -name "*.json" -type f -exec sed -i "s/\"$key\"/\"core_$key\"/g" {} +
      ;;
  esac
done

# Format formulae-core.txt
sort "$formulae_core_in" | uniq > "$formulae_core_txt"
rm -f "$formulae_core_in"
