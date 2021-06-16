#!/bin/zsh

set -e

# The script runs the comdb dev container and persists
# using three directories
# comdb2-opt-bb-bin:/opt/bb/bin/
# comdb2-dbs:/home/heisengarg/dbs
# binds the comdb2 top level directory to /home/heisengarg/comdb2
#
# The binding is only relevant for building

DBSDIR="/home/heisengarg/dbs/"
DBNAME="testdb" 

build() {
	cd build && cmake -GNinja ..
	ninja && sudo ninja install
}

clean_build() {
	[[ -d build ]] && rm -rf build && mkdir build
	build
}

new_db() {
	if ! COMDB2="$(command -v comdb2)"; then
		echo "Failed to find comdb2"
		exit 1
	fi
    if [ ! -d "$DBSDIR" ]; then
        echo "The $DBSDIR doesn't exist. Forgot to mount?"
        exit 2
    fi
    # when we mount a directory, the current user
    # might not have permissions to write to the directory
    # since it is mounted with root access
    if [ -w "$DBSDIR" ]; then
        sudo chown -R $(whoami) "$DBSDIR"
    fi
    
    if [ -z "$1" ]; then
        echo "no dbname passed using testdb" 
    else
        DBNAME="$1"
    fi

    # make a directory for logs
    sudo mkdir -p /opt/bb/var/log/cdb2 && sudo chown -R $(whoami) /opt/bb/
	$COMDB2 --create --dir "$DBSDIR/$DBNAME" "$DBNAME"
}

run_db() {
	if ! COMDB2="$(command -v comdb2)"; then
		echo "Failed to find comdb2"
		exit 1
	fi
    if [ -z "$1" ]; then
        echo "no dbname passed using testdb" 
    else
        DBNAME="$1"
    fi

    if [ ! -f "$DBSDIR/$DBNAME/$DBNAME.lrl" ]; then
        echo "$DBNAME.lrl file doesn't exist. Did you build db?"
        exit 2
    fi

	pmux -n && $COMDB2 --lrl "$DBSDIR/$DBNAME/$DBNAME.lrl" "$DBNAME"
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
db)
	shift
	new_db "$*"
	;;
run)
	shift
    run_db "$*"
    ;;
*)
	exec "$@"
	;;
esac
