#!/bin/bash

formulae=(
  "autoconf"
  "autoconf@2.13"
  "autoconf@2.69"
  "automake"
  "bison@2.7"
  "bison"
  "ca-certificates"
  "cairo"
  "certifi"
  "cmake"
  "fontconfig"
  "freetype"
  "gawk"
  "gdbm"
  "gettext"
  "giflib"
  "glib"
  "gmp"
  "gobject-introspection"
  "graphite2"
  "harfbuzz"
  "icu4c"
  "jpeg-turbo"
  "libgit2@1.5"
  "libgit2@1.6"
  "libgit2"
  "libpng"
  "libssh2"
  "libtermkey"
  "libtiff"
  "libtool"
  "libuv"
  "libvterm"
  "libx11"
  "libxau"
  "libxcb"
  "libxdmcp"
  "libxext"
  "libxrender"
  "little-cms2"
  "llvm@8"
  "llvm@9"
  "llvm@11"
  "llvm@12"
  "llvm@13"
  "llvm@14"
  "llvm@15"
  "llvm@16"
  "llvm"
  "lpeg"
  "lua"
  "lua@5.1"
  "lua@5.3"
  "luajit"
  "luarocks"
  "luv"
  "lz4"
  "lzo"
  "m4"
  "meson"
  "mpdecimal"
  "mpfr"
  "msgpack"
  "nasm"
  "neovim"
  "ninja"
  "openjdk@11"
  "openjdk@17"
  "openjdk@8"
  "openssl@1.1"
  "openssl@3"
  "openssl@3.0"
  "page"
  "pcre"
  "pcre2"
  "pixman"
  "pkg-config"
  "pkgconf"
  "python-setuptools"
  "python@3.10"
  "python@3.11"
  "python@3.12"
  "python@3.7"
  "python@3.8"
  "python@3.9"
  "readline"
  "rust"
  "sphinx-doc"
  "sqlite"
  "swig@3"
  "swig"
  "tcl-tk"
  "tree-sitter"
  "unibilium"
  "unzip"
  "util-macros"
  "xcb-proto"
  "xorgproto"
  "xtrans"
  "xz"
  "z3"
  "zstd"
)

for formula in "${formulae[@]}"
do
  # Download and format JSON
  mkdir -p _data/formula-core
  curl --silent --output-dir _data/formula-core --output "$formula_raw.json" "https://formulae.brew.sh/api/formula/$formula.json"
  jq '.' "_data/formula-core/$formula_raw.json" > "_data/formula-core/$formula.json"
  rm -f "_data/formula-core/$formula_raw.json"

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
done
