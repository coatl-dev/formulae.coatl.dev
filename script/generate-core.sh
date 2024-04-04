#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly CWD

file="$CWD/formulae.txt"

if [ ! -f "$file" ]; then
  echo "File '$file' does not exist."
  exit 1
fi

while IFS= read -r formula; do
  # Download and format JSON
  mkdir -p _data/formula-core
  curl -s "https://formulae.brew.sh/api/formula/$formula.json" | jq . > "_data/formula-core/$formula.json"

  # Make HTML file
  mkdir -p formula-core
  html="formula-core/$formula.html"
  cat << EOF > "$html"
---
title: "$formula"
layout: formula
---
{{ content }}
EOF

  # Make JSON file
  mkdir -p api/formula-core
  json="api/formula-core/$formula.json"
  cat << EOF > "$json"
---
layout: formula_json
---
{{ content }}
EOF
done < "$file"
