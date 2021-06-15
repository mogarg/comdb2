#!/bin/zsh

set -e

build() {
	cd build && cmake -GNinja ..
	ninja && sudo ninja install
}

clean_build() {
	[[ -d build ]] && rm -rf build && mkdir build
	build
}

case "$1" in
build)
	build
	;;
clean)
	clean_build
	;;
default)
	figlet "$hostname"
	/bin/zsh
	;;
*)
	exec "$@"
	;;
esac
