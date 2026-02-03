FROM ubuntu:latest

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies needed to bootstrap
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user (simulates typical user environment)
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

# Default shell is bash (as user mentioned)
CMD ["/bin/bash", "-l"]
