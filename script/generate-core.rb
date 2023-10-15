#!/usr/bin/env -S brew ruby

tap = Tap.fetch("Homebrew/core")

directories = ["_data/formula-core", "api/formula-core", "formula-core"]
FileUtils.rm_rf directories + ["_data/formula-core_canonical.json"]
FileUtils.mkdir_p directories

json_template = IO.read "_api_formula.json.in"
html_template = IO.read "_formula.html.in"

tap.formula_names.each do |n|
  if ["bzip2",
      "unzip",
      "xz"].include?(n)
    f = Formulary.factory(n)
    IO.write("_data/formula-core/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash_with_variations)}\n")
    IO.write("api/formula-core/#{f.name}.json", json_template)
    IO.write("formula-core/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
  end
end
IO.write("_data/formula-core_canonical.json", "#{JSON.pretty_generate(tap.formula_renames.merge(tap.alias_table))}\n")
