#!/usr/bin/env -S brew ruby

tap = Tap.fetch("Homebrew/core")

directories = ["_data/formula-core", "api/formula-core", "formula-core"]
FileUtils.rm_rf directories + ["_data/formula-core_canonical.json"]
FileUtils.mkdir_p directories

json_template = IO.read "_api_formula.json.in"
html_template = IO.read "_formula.html.in"

tap.formula_names.each do |n|
  if ["alsa-lib",
      "autoconf",
      "autoconf@2.13",
      "autoconf@2.69",
      "automake",
      "berkeley-db",
      "berkeley-db@4",
      "berkeley-db@5",
      "bison",
      "brotli",
      "bzip2",
      "c-ares",
      "ca-certificates",
      "cairo",
      "cmake",
      "cups",
      "docutils",
      "emscripten",
      "fontconfig",
      "freetype",
      "freetype2",
      "gdbm",
      "gettext",
      "giflib",
      "glib",
      "gobject-introspection",
      "graphite2",
      "harfbuzz",
      "icu4c",
      "jpeg-turbo",
      "libnghttp2",
      "libpng",
      "libtermkey",
      "libtiff",
      "libtool",
      "libuv",
      "libvterm",
      "libx11",
      "libxau",
      "libxcb",
      "libxdmcp",
      "libxext",
      "libxrandr",
      "libxrender",
      "libxt",
      "libxtst",
      "little-cms2",
      "lua",
      "lua@5.1",
      "lua@5.3",
      "luajit",
      "luarocks",
      "luv",
      "lzo",
      "lz4",
      "macos-term-size",
      "m4",
      "meson",
      "msgpack",
      "mpdecimal",
      "nasm",
      "neovim",
      "ninja",
      "node",
      "node@10",
      "node@12",
      "node@14",
      "node@16",
      "node@18",
      "openjdk",
      "openjdk@8",
      "openjdk@11",
      "openjdk@17",
      "openssl@1.1",
      "openssl@3",
      "page",
      "pcre2",
      "perl",
      "perl@5.18",
      "pixman",
      "pkg-config",
      "pygments",
      "python@3.7",
      "python@3.8",
      "python@3.9",
      "python@3.10",
      "python@3.11",
      "readline",
      "rust",
      "sphinx-doc",
      "sqlite",
      "tcl-tk",
      "tree-sitter",
      "unibilium",
      "unzip",
      "util-macros",
      "xcb-proto",
      "xorgproto",
      "xtrans",
      "xz",
      "zlib",
      "zip",
      "zstd"].include?(n)
    f = Formulary.factory(n)
    IO.write("_data/formula-core/#{f.name.tr("+", "_")}.json", "#{JSON.pretty_generate(f.to_hash_with_variations)}\n")
    IO.write("api/formula-core/#{f.name}.json", json_template)
    IO.write("formula-core/#{f.name}.html", html_template.gsub("title: $TITLE", "title: \"#{f.name}\""))
  end
end
IO.write("_data/formula-core_canonical.json", "#{JSON.pretty_generate(tap.formula_renames.merge(tap.alias_table))}\n")
