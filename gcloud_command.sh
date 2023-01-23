while getopts i:z:t:g:c:m: opt; do
    case ${opt} in
        i ) INSTANCE_NAME=$OPTARG;;
        z ) ZONE=$OPTARG;;
        t ) INSTANCE_TYPE=$OPTARG;;
        g ) GPU_TYPE=$OPTARG;;
        c ) GPU_COUNT=$OPTARG;;
        m ) META_DATA=$OPTARG;; 
    esac
done

INSTANCE_STATUS=$(gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="value(status)")

if -n ${INSTANCE_STATUS}; then
    if ${INSTANCE_STATUS}=TERMINATED; then
        echo "Instance is terminated"
        echo "restart instance..."
        gcloud compute instances start ${INSTANCE_NAME} \
            --zone=${ZONE} \
            --metadata=${META_DATA}
            --metadata-from-file startup-script=executor.sh,environment-setting=.env \
    else
        echo "Instance is running"
        echo "Waiting for instance ${INSTANCE_NAME} to be ready or create new instance..."
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