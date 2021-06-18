#!/bin/zsh

# sets up cluster stuff for comdb2 
# - creats a host directory in the current location as a volumes
# folder. creates subdirectory for the master copy and directories
# for the replica copies.
#
# volumes/master-copy
#     |--/node1-dbs
#     |--/node2-dbs
#     |--/node3-dbs
#      and so on...
#
# emits a cluster nodes node1 node2 node3 to the lrl file in the master copy container 
# 


HOMEDIR="/home/heisengarg"
DBS="$HOMEDIR/dbs" # dbs volume location in the container
DBSMNTVOL="comdb2-dbs" # host volume name that mounts to the DBS dir
IMAGE="heisengarg/devbox"
VERSION="latest"

LOCALVOL="volumes" # directory to store must db data on host

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <dbname> <hosts>" >&2
    exit 1
fi

DBNAME="$1"

if ! DOCKER="$(command -v docker)"; then
    echo "docker not found"
    exit 1
fi

if ! COPYCOMDB2="$(PATH=$PATH:/opt/bb/bin command -v copycomdb2)"; then
    echo "docker not found"
    exit 1
fi


IFS="," read -rA hosts <<< "$2"

$DOCKER run --rm --mount type=volume,source="$DBSMNTVOL",target="$DBS" \
    $IMAGE:$VERSION -e DBNAME="$DBNAME" -e HOSTS="$2" clust "$DBNAME" "$HOSTS"

mkdir -p "$VOLUMES/master"
for host in ${hosts[@]}; do
    mkdir -p "$VOLUMES/$host-dbs"
done    

$DOCKER run --rm --mount type=volume,source="$DBSMNTVOL",target="$DBS" \
    -w "$HOME" $IMAGE:$VERSION cp dbs ./volumes/master 

for host in ${hosts[@]}; do
    $COPYCOMDB2 -m "$VOLUMES/master/$DBNAME/$DBNAME.lrl" "$VOLUMES/master/$DBNAME/" "$VOLUMES/$host-dbs"
done



