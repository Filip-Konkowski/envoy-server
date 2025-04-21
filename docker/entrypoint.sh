#!/bin/sh
set -e

echo "Setting up certs..."


# Create the TLS directory with proper permissions
mkdir -p /etc/envoy/tls
chmod 700 /etc/envoy/tls

# Ensure proper permissions on certificate files

chmod 600 /etc/envoy/tls/client-cert.pem
chmod 600 /etc/envoy/tls/client-private-key.pem
chmod 600 /etc/envoy/tls/RootCA.pem

# Verify certificate files exist and have content
if [ ! -s /etc/envoy/tls/client-cert.pem] || [ ! -s /etc/envoy/tls/client-private-key.pem ] || [ ! -s /etc/envoy/tls/RootCA.pem ]; then
  echo "One or more certificate files are empty or missing"
  exit 1
fi

echo "Processing Envoy configuration template..."
# Use envsubst to replace environment variables in the template
envsubst < /etc/envoy/envoy.yaml.template > /etc/envoy/envoy.yaml
echo "Envoy configuration generated successfully"

echo "Starting Envoy..."
exec envoy -c /etc/envoy/envoy.yaml --component-log-level upstream:debug,connection:trace,http:debug --log-level debug
