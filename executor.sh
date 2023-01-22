#!/bin/bash

# install nvidia driver
if lspci -vnn | grep NVIDIA > /dev/null 2>&1; then
  # Nvidia card found, need to check if driver is up
  if ! nvidia-smi > /dev/null 2>&1; then
    echo "Installing driver"
    /opt/deeplearning/install-driver.sh
  fi
fi

readonly INSTANCE_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/name -H "Metadata-Flavor: Google")
INSTANCE_ZONE="/"$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google")
INSTANCE_ZONE="${INSTANCE_ZONE##/*/}"
readonly INSTANCE_PROJECT_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/project/project-id -H "Metadata-Flavor: Google")

# delete instance
gcloud --quiet compute instances delete "${INSTANCE_NAME}" --zone "${INSTANCE_ZONE}" --project "${INSTANCE_PROJECT_NAME}"