#!/bin/bash -eu

trap catch ERR
trap finally EXIT

function catch {
  echo "Experiment failed."
  gcloud --quiet compute instances delete "${INSTANCE_NAME}" --zone "${INSTANCE_ZONE}" --project "${INSTANCE_PROJECT_NAME}"
}
function finally {
  echo "Experiment finished successfully, delete instance."
  gcloud --quiet compute instances delete "${INSTANCE_NAME}" --zone "${INSTANCE_ZONE}" --project "${INSTANCE_PROJECT_NAME}"
}

# set variable
readonly INSTANCE_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/name -H "Metadata-Flavor: Google")
INSTANCE_ZONE="/"$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google")
INSTANCE_ZONE="${INSTANCE_ZONE##/*/}"
readonly INSTANCE_PROJECT_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/project/project-id -H "Metadata-Flavor: Google")
readonly ENVIRONMENT=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/environment-setting -H "Metadata-Flavor: Google")
readonly EXECUTE_FILE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/execute_file -H "Metadata-Flavor: Google")

# install nvidia driver
if lspci -vnn | grep NVIDIA > /dev/null 2>&1; then
  if ! nvidia-smi > /dev/null 2>&1; then
    echo "Installing driver"
    /opt/deeplearning/install-driver.sh
  fi
fi

# git clone
export $(cat ${ENVIRONMENT} | grep -v ^\#)
git clone https://${GIT_USER}:${GIT_PASS}@https://github.com/${GIT_USER}/${GIT_REPO}.git
cd ${GIT_REPO}

# set environment
cat ${ENVIRONMENT} > .env

# sync gcs bucket
pip install -r requirements.txt --user
# python gcs_sync.py

# execute experiment
python EXECUTE_FILE

# upload result to gcs bucket
# python gcs_sync.py -u
