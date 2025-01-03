FROM ocaml/opam:ubuntu-20.04-ocaml-4.14

# Install the necessary packages

# Switch to root to install system packages
USER root

# Install necessary system packages
RUN apt-get update && \
    apt-get install -y python3 lsb-release wget software-properties-common gnupg cmake

# Install LLVM 14
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 14

# Copy the source code
COPY . /app

# Set the working directory
WORKDIR /app

# Change the owner of the directory
RUN chown -R opam:opam /app
USER opam

# Install opam packages
RUN opam install -y dune llvm.14.0.6 menhir && \
    eval $(opam env) && \
    make
