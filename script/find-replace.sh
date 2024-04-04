#!/bin/bash

keys=(
  "dependencies"
  "build_dependencies"
  "test_dependencies"
)

for key in "${keys[@]}"
do
  find _data/formula -name "*.json" -type f -exec sed -i '' "s/\"$key\"/\"core_$key\"/g" {} +
done
