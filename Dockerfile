# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.148.1/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="latest"
FROM heisengarg/devbox:${VARIANT}
ARG USER="heisengarg"

WORKDIR /home/${USER}/comdb2

ENV PATH $PATH:/opt/bb/bin

RUN sudo apt-get update && sudo apt-get -y install --no-install-recommends \ 
    bison \
    build-essential      \
    cmake                \
    flex                 \
    libevent-dev         \
    liblz4-dev           \
    libprotobuf-c-dev    \
    libreadline-dev      \
    libsqlite3-dev       \
    libssl-dev           \
    libunwind-dev        \
    ncurses-dev          \
    protobuf-c-compiler  \
    tcl                  \
    uuid-dev             \
    zlib1g-dev           \
    dialog               \
    jq tcl-dev           \
    ninja-build          \
    gawk                 \
    valgrind             \
    cscope               \
    figlet

COPY ./entrypoint.sh /usr/local/bin/
