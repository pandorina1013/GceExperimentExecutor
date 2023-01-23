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

# custom here
gcloud compute instances create ${INSTANCE_NAME} \
    --zone=${ZONE} \
    --machine-type=${INSTANCE_TYPE} \
    --accelerator=type=nvidia-tesla-${GPU_TYPE},count=${GPU_COUNT} \
    --metadata=${META_DATA} \
    --metadata-from-file startup-script=executor.sh,environment-setting=.env \