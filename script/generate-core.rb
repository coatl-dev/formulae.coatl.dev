#!/usr/bin/env -S brew ruby
os = "mac"
formula_dir = "formula-core"
bottle_dir = "bottle"
tap_name = "Homebrew/core"

formula_dir = os == "mac" ? "formula-core" : "formula-core-linux"
bottle_dir = os == "mac" ? "bottle-core" : "bottle-core-linux"
tap = Tap.fetch(tap_name)

directories = ["_data/#{formula_dir}", "_data/#{bottle_dir}", "api/#{formula_dir}", "api/#{bottle_dir}", "#{formula_dir}"]
FileUtils.rm_rf directories + ["_data/#{formula_dir}_canonical.json"]
FileUtils.mkdir_p directories

json_template = IO.read "_api_formula.json.in"
bottle_template = IO.read "_api_bottle.json.in"
html_template = IO.read "_formula.html.in"

tap.formula_names.each do |n|
  if ["alsa-lib",
      "autoconf",
      "autoconf@2.13",
      "autoconf@2.69",
      "bzip2",
      "cups",
      "fontconfig",
      "freetype",
      "freetype2",
      "giflib",
      "harfbuzz",
      "jpeg-turbo",
      "libpng",
      "libx11",
      "libxext",
      "libxrandr",
      "libxrender",
      "libxt",
      "libxtst",
      "little-cms2",
      "m4",
      "openjdk",
      "openjdk@8",
      "openjdk@11",
      "openjdk@17",
      "perl",
      "pkg-config",
      "unzip",
      "zlib",
      "zip"].include?(n)
    f = Formulary.factory(n)
    IO.write("_data/#{formula_dir}/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash)}\n")
    IO.write("_data/#{bottle_dir}/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_recursive_bottle_hash)}\n")
    IO.write("api/#{formula_dir}/#{f.name}.json", json_template)
    IO.write("api/#{bottle_dir}/#{f.name}.json", bottle_template)
    IO.write("#{formula_dir}/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
  end
end
IO.write("_data/#{formula_dir}_canonical.json", "#{JSON.pretty_generate(tap.formula_renames.merge(tap.alias_table))}\n")
