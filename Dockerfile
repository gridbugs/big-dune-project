FROM ubuntu

# Install tools and system dependencies of packages
RUN apt-get update -y && apt-get install -y \
  build-essential \
  pkg-config \
  opam \
  neovim \
  curl \
  sudo \
  z3 \
  autoconf \
  libipc-system-simple-perl \
  libstring-shellquote-perl \
  libasound2-dev \
  libssl-dev \
  picosat \
  libmp3lame-dev \
  libkrb5-dev \
  libtidy-dev \
  libqrencode-dev \
  libsybdb5 \
  libfdk-aac-dev \
  libsqlite3-dev \
  liblmdb-dev \
  libpapi-dev \
  zlib1g-dev \
  libgoogle-perftools-dev \
  libjemalloc-dev \
  librdkafka-dev \
  libgmp-dev \
  liblo-dev \
  libpng-dev \
  ;

RUN useradd --create-home --shell /bin/bash --gid users --groups sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user
WORKDIR /home/user

RUN opam init --disable-sandboxing --auto-setup
RUN opam switch remove default -y
RUN opam switch create default 4.14.0
RUN opam install -y dune camlp5 tiny_json why3 coq

RUN git clone https://github.com/tarides/opam-monorepo.git
RUN cd opam-monorepo && git checkout d15938759ecc21f4a8fb506b2e86707c003bae05
RUN opam install -y ./opam-monorepo/opam-monorepo.opam

RUN mkdir src
WORKDIR src
ADD --chown=user:users . ./

RUN bash -c 'cp -v $(uname -m)/* .'

# Running `opam monorepo pull` with a large package set is very likely to fail on at least
# one package in a non-deterministic manner. Repeating it several times reduces the chance
# that all attempts fail.
RUN opam monorepo pull || opam monorepo pull || opam monorepo pull

RUN ./apply-patches.sh
RUN . ~/.profile && dune exec ./hello.exe
