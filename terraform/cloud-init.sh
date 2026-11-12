#!/bin/bash
set -euo pipefail

# Docker + Compose plugin (https://docs.docker.com/engine/install/ubuntu/)
curl -fsSL https://get.docker.com | sh
usermod -aG docker azureuser

# Pré-requisitos do SonarQube (Elasticsearch embutido)
cat > /etc/sysctl.d/99-sonarqube.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF
sysctl --system
