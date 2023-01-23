#!/bin/bash -eu

# execute experiment
EXECUTE_FILE=""
INSTANCE_NAME=""
ZONE="us-west1-b"
INSTANCE_TYPE="n1-standard-4"
GPU_TYPE="t4"
GPU_COUNT=1

usage() {
    echo "Usage: "
    echo "   sh experiment.sh -i [INSTANCE_NAME] -e [EXECUTE_FILE] -g [GPU_TYPE] -c [GPU_COUNT] -z [ZONE] -t [INSTANCE_TYPE]"
    echo ""
    echo "example:"
    echo "   sh experiment.sh -i experiment-executor-1 -e exp001/main.py -g p100 -z us-west1-b -t n1-standard-8"
    echo ""
    echo "default values:"
    echo "   zone: us-west1-b"
    echo "   instance-type: n1-standard-4"
    echo "   gpu type: t4"
    echo "   gpu count: 1"
    echo ""
    echo "required keys:"
    echo "   i,e"
    echo ""
}

while getopts i:e:z:g:c:t: opt; do
    case ${opt} in
        i ) INSTANCE_NAME=$OPTARG;;
        e ) EXECUTE_FILE=$OPTARG;;
        z ) ZONE=$OPTARG;;
        g ) GPU_TYPE=$OPTARG;;
        c ) GPU_COUNT=$OPTARG;;
        t ) INSTANCE_TYPE=$OPTARG;;
        h ) usage;;
        \?) usage;;
    esac
done
echo "Excution of the experiment initiated with the following input arguments: $@"

if [ -z "$INSTANCE_NAME" ]; then
    echo "instance name field is empty (use key -i)"
    exit 1
fi
if [ -z "$EXECUTE_FILE" ]; then
    echo "experiment file name field is empty (use key -e)"
    exit 1
fi

META_DATA="execute_file=${EXECUTE_FILE}"

echo "Instance name: ${INSTANCE_NAME}"
echo "Excute file: ${EXECUTE_FILE}"
echo "Instance type ${INSTANCE_TYPE}"
echo "GPU type: ${GPU_TYPE}"
echo "GPU count: ${GPU_COUNT}"
echo "Metadata: ${META_DATA}"

INSTANCE_STATUS=$(gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="value(status)")

if [ -n "${INSTANCE_STATUS}" ]; then
    if [ "${INSTANCE_STATUS}"=TERMINATED ]; then
        echo "Instance is terminated"
        echo "restart instance..."
        gcloud compute instances add-metadata ${INSTANCE_NAME} \
            --zone=${ZONE} \
            --metadata=${META_DATA} \
            --metadata-from-file startup-script=executor.sh,environment-setting=.env
        gcloud compute instances start ${INSTANCE_NAME} --zone=${ZONE}
    else
        echo "Instance is running"
        echo "Waiting for instance ${INSTANCE_NAME} to be ready or create new instance..."
        exit 1
    fi
else
    echo "Instance does not exist"
    echo "creating instance..."
    # custom here
    gcloud compute instances create ${INSTANCE_NAME} \
        --zone=${ZONE} \
        --machine-type=${INSTANCE_TYPE} \
        --accelerator=type=nvidia-tesla-${GPU_TYPE},count=${GPU_COUNT} \
        --metadata=${META_DATA} \
        --metadata-from-file startup-script=executor.sh,environment-setting=.env \
        --no-restart-on-failure \
        --maintenance-policy=TERMINATE \
        --preemptible \
        --provisioning-model=SPOT \
fi