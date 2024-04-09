#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly CWD

formulae="$CWD/formulae-core.txt"
formulae_conflicts="$CWD/formulae-core-conflicts.txt"

if [ ! -f "$formulae" ]; then
  echo "File '$formulae' does not exist."
  touch "$formulae"
fi

# Create formulae-core file
formulae_conflicts_in="$CWD/formulae-core-conflicts.in"
echo -n > "$formulae_conflicts_in"

while IFS= read -r formula; do
  # Download and format JSON
  mkdir -p _data/formula-core
  curl -s "https://formulae.brew.sh/api/formula/$formula.json" | jq . > "_data/formula-core/$formula.json"

  # Get conflicting formulae
  brew info --json --formula "$formula" | jq -r '.[]|(.conflicts_with[])' >> "$formulae_conflicts_in"

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
done < "$formulae"

# Format formulae-core-conflicts.txt
formulae_conflicts_txt="$CWD/formulae-core-conflicts.txt"
sort "$formulae_conflicts_in" | uniq > "$formulae_conflicts_txt"
rm -f "$formulae_conflicts_in"

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
done < "$formulae_conflicts"
