#!/bin/bash -eu

trap catch ERR
trap finally EXIT

function catch {
  echo "Experiment failed."
}
function finally {
  echo "Stop instance."
  gcloud compute instances stop "${INSTANCE_NAME}" \
    --zone "${INSTANCE_ZONE}" \
    --project "${INSTANCE_PROJECT_NAME}"
}

# set variable
readonly INSTANCE_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/instance/name -H "Metadata-Flavor: Google")
INSTANCE_ZONE="/"$(curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google")
INSTANCE_ZONE="${INSTANCE_ZONE##/*/}"
readonly INSTANCE_PROJECT_NAME=$(curl http://metadata.google.internal/computeMetadata/v1/project/project-id -H "Metadata-Flavor: Google")
readonly EXECUTE_FILE=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/execute_file -H "Metadata-Flavor: Google")

# install gpu driver (なんですぐcuda壊れてしまうん???)
echo "Installing driver"
# curl https://raw.githubusercontent.com/GoogleCloudPlatform/compute-gpu-installation/main/linux/install_gpu_driver.py --output install_gpu_driver.py
# sudo python3 install_gpu_driver.py
sudo /opt/deeplearning/install-driver.sh

# set environment
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/environment-setting -H "Metadata-Flavor: Google" > .env
export $(cat .env| grep -v "#" | xargs)

# git clone
if [ -e ${GIT_REPO} ]; then
  cd ${GIT_REPO}
  git pull
else
  git clone https://${GIT_USER}:${GIT_TOKEN}@github.com/${GIT_USER}/${GIT_REPO}
  cd ${GIT_REPO}
  pip3 install --upgrade pip setuptools wheel
fi

pip3 install -r requirements.txt
pip3 install ipython

# set environment
mv ../.env .env

# sync gcs bucket
python3 gcs-rsync.py

# execute experiment
cd `dirname ${EXECUTE_FILE}`

# remove output directory
if [ -e output ]; then
  rm -r output
fi

echo ${PWD##*/}
python3 `basename ${EXECUTE_FILE}`

echo "Experiment finished successfully."