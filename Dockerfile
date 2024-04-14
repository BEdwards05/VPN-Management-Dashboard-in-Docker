# Base image
FROM ubuntu:22.04

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add the Caddy official Debian repository
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list

# Update and install necessary packages
RUN apt-get update && apt-get install -y curl python3-pip bash wget caddy python3 iproute2 net-tools && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory for any subsequent ADD, COPY, CMD, ENTRYPOINT, or RUN commands
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .
RUN chmod +x setup.sh
ENTRYPOINT ["/app/setup.sh"]