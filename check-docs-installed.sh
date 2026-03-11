#!/bin/sh
set -eu

raco setup --pkgs scribble-tools
raco scribble +m --html --dest html scribble-tools/scribblings/example.scrbl

echo "Docs check complete (installed-package mode + example render)."
