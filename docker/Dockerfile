# Use an official Envoy image as the base
FROM envoyproxy/envoy:v1.33.0

# Install dependencies & AWS CLI v2 (including gettext-base for envsubst)
# Also install dnsutils (for nslookup) and iputils-ping (for ping).
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    gettext-base \
    dnsutils \
    iputils-ping \
    luarocks \
    build-essential \
    liblua5.1-dev


# Notice the URL is for ARM64 (aarch64) instead of x86_64
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

RUN luarocks install lua-cjson
RUN luarocks install luasocket

# Create a directory for TLS certificates
RUN mkdir -p /etc/envoy/tls

# Copy the Envoy configuration template
ADD envoy.yaml.template /etc/envoy/envoy.yaml.template

# Copy the entrypoint script
ADD entrypoint.sh /entrypoint.sh

ADD "certs/client.crt" /etc/envoy/tls/client-cert.pem
ADD "certs/client.key" /etc/envoy/tls/client-private-key.pem
ADD "certs/RootCA.pem" /etc/envoy/tls/RootCA.pem


# Create non-root user for security
RUN chown -R envoy:envoy /etc/envoy && chmod -R 700 /etc/envoy
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER envoy

# Set the entrypoint script as the container's entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD curl -f http://localhost:15000/healthz