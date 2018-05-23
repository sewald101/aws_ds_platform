#!/usr/bin/env bash
set -e
echo "Spinning up EC2 instance . . . "
aws ec2 run-instances \
    --image-id ami-b5ed9ccd \
    --security-groups Agile_DS_SW \
    --key-name Agile_DS_SW \
    --instance-type t2.micro \
    --block-device-mappings '[
    {"DeviceName":"/dev/sda1","Ebs":{"DeleteOnTermination":true,"VolumeSize":32}}
    ]' \
    --count 1
sleep 10
echo "Working . . . "
sleep 10
echo "Instance spun up. Wait about 4 minutes for it to initialize, then SSH in."


##--block-device-mappings '[
##{"DeviceName":"/dev/sda1","Ebs":{"DeleteOnTermination":true,"VolumeSize":128}},
##{"DeviceName":"/dev/xvda","Ebs":{"DeleteOnTermination":true,"VolumeSize":60}}
##]' \
