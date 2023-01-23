#!/bin/bash -eu

trap catch ERR
trap finally EXIT

function catch {
  echo "Experiment failed."
  # gcloud --quiet compute instances delete "${INSTANCE_NAME}" --zone "${INSTANCE_ZONE}" --project "${INSTANCE_PROJECT_NAME}"
}
function finally {
  echo "Delete instance."
  gcloud --quiet compute instances delete "${INSTANCE_NAME}" --zone "${INSTANCE_ZONE}" --project "${INSTANCE_PROJECT_NAME}"
}

# set variable
readonly INSTANCE_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/name -H "Metadata-Flavor: Google")
INSTANCE_ZONE="/"$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google")
INSTANCE_ZONE="${INSTANCE_ZONE##/*/}"
readonly INSTANCE_PROJECT_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/project/project-id -H "Metadata-Flavor: Google")
readonly EXECUTE_FILE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/execute_file -H "Metadata-Flavor: Google")

# set environment
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/environment-setting -H "Metadata-Flavor: Google" > .env
export $(cat .env| grep -v "#" | xargs)

# git clone
git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/${GIT_USER}/${GIT_REPO}
cd ${GIT_REPO}

# set environment
mv ../.env .env

# sync gcs bucket
pip3 install -r requirements.txt --user
# python gcs_sync.py

# execute experiment
# python EXECUTE_FILE

# upload result to gcs bucket
# python gcs_sync.py -u

echo "Experiment finished successfully."