#!/bin/bash -eu

# execute experiment
EXECUTE_FILE=""
ZONE="us-west1-b"
INSTANCE_TYPE="n1-standard-4"
GPU_TYPE="t4"
GPU_COUNT=1
BUILD_ID=$(date +%s)

usage() {
    echo "Usage: "
    echo "   sh experiment.sh -i [EXECUTE_FILE] -g [GPU_TYPE] -c [GPU_COUNT] -z [ZONE] -t [INSTANCE_TYPE]"
    echo ""
    echo "example:"
    echo "   sh experiment.sh -i exp001/main.py -g p100 -z us-west1-b -t n1-standard-8"
    echo ""
    echo "default values:"
    echo "   zone: us-west1-b"
    echo "   instance-type: n1-standard-4"
    echo "   gpu type: t4"
    echo "   gpu count: 1"
    echo ""
    echo "required keys:"
    echo "   i"
    echo ""
}

while getopts i:z:g:c:t: opt; do
    case ${opt} in
        i ) EXECUTE_FILE=$OPTARG;;
        z ) ZONE=$OPTARG;;
        g ) GPU_TYPE=$OPTARG;;
        c ) GPU_COUNT=$OPTARG;;
        t ) INSTANCE_TYPE=$OPTARG;;
        h ) usage;;
        \?) usage;;
    esac
done
echo "Excution of the experiment initiated with the following input arguments: $@"

if [[ -z "$EXECUTE_FILE" ]]; then
    echo "input experiment field is empty (use key -i)"
    exit 1
fi

INSTANCE_NAME="experiment-${BUILD_ID}"
META_DATA="execute_file=${EXECUTE_FILE}"

echo "Build id: ${BUILD_ID}"
echo "Instance name: ${INSTANCE_NAME}"
echo "Excute file: ${EXECUTE_FILE}"
echo "Instance type ${INSTANCE_TYPE}"
echo "GPU type: ${GPU_TYPE}"
echo "GPU count: ${GPU_COUNT}"
echo "Metadata: ${META_DATA}"

sh gcloud_command.sh -i ${INSTANCE_NAME} -z ${ZONE} -t ${INSTANCE_TYPE} -g ${GPU_TYPE} -c ${GPU_COUNT} -m ${META_DATA}
