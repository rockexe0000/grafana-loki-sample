#!/bin/bash

set -eux


start_time=$(date +%s);

NOW=$(date +"%Y/%m/%d/%H/%M/%S/%N")
echo "NOW=[$NOW]";

#downdoadDir="/var/data/aws-cli"
downdoadDir="/var/data/p-lcb-backend"
promtailDir="/var/data/p-lcb-backend"


#pip3 install awscli
aws --version
aws configure set aws_access_key_id "${AWS_ACCESS_KEY}"
aws configure set aws_secret_access_key "${AWS_SECRET_KEY}"


echo "$(pwd)"



### remove old Logs
cd ~
rm -rf $promtailDir/fluent-bit-logs/
mkdir -p $promtailDir/fluent-bit-logs





### download 1h new Logs
### 下載指定時間往前 n 小時內的 Log
### 時間轉換網址 https://www.epochconverter.com/

cd $downdoadDir
mkdir -p fluent-bit-logs
cd fluent-bit-logs

one_time=$start_time;
#one_time='1699590000';

echo "one_time=[$one_time]"

one_time_path=$(date -d @$one_time +%Y/%m/%d/%H)
echo "one_time_path=[$one_time_path]"

n=1
n_hour_ago=$((one_time - n * 60 * 60));

n_hour_ago_path=$(date -d @$n_hour_ago +%Y/%m/%d/%H)

for ((i=$n;i>=1;i--))
do
  i_hour_ago=$((one_time - i * 60 * 60));
  i_hour_ago_path=$(date -d @$i_hour_ago +%Y/%m/%d/%H)
  #aws s3 cp s3://${AWS_BUCKET}/p-lcb-backend-fg/fluent-bit-logs/ . --recursive --exclude "*" --include "p-lcb-backend-fg-*/$i_hour_ago_path/*" &
  
  aws s3 cp s3://${AWS_BUCKET}/p-lcb-backend-fg/fluent-bit-logs/ . --recursive --exclude "*" --include "logs.info/$i_hour_ago_path/*" &
  
done

wait



### download new Logs
### 下載指定時間往前 n 分鐘內的 Log
### 時間轉換網址 https://www.epochconverter.com/

#cd $downdoadDir
#mkdir -p fluent-bit-logs
#cd fluent-bit-logs
#
##one_time=$start_time;
#one_time='1699500000';
#
#echo "one_time=[$one_time]"
#
#one_time_path=$(date -d @$one_time +%Y/%m/%d/%H/%M)
#echo "one_time_path=[$one_time_path]"
#
#n=7
#n_minute_ago=$((one_time - n * 60));
#
#n_minute_ago_path=$(date -d @$n_minute_ago +%Y/%m/%d/%H/%M)
#
#for ((i=$n;i>=0;i--))
#do
#  i_minute_ago=$((one_time - i * 60));
#  i_minute_ago_path=$(date -d @$i_minute_ago +%Y/%m/%d/%H/%M)
#  #aws s3 cp s3://${AWS_BUCKET}/t-lcb-backend-fg/fluent-bit-logs/ . --recursive --exclude "*" --include "t-lcb-backend-fg-*/$i_minute_ago_path/*" &
#  aws s3 cp s3://${AWS_BUCKET}/p-lcb-backend-fg/fluent-bit-logs/ . --recursive --exclude "*" --include "p-lcb-backend-fg-*/$i_minute_ago_path/*" &
#
#done
#
#wait


#aws s3 cp s3://${AWS_BUCKET}/t-lcb-backend-fg/fluent-bit-logs/ . --recursive --exclude "*" --include "t-lcb-backend-fg-*/2023/06/07/05/00/*"
    



### move new Logs
#cd ~
#mv $downdoadDir/fluent-bit-logs/ $promtailDir/fluent-bit-logs/





end_time=$(date +%s)
runtime=$((end_time - start_time));
printf "Execution time: %.6f seconds\n" $runtime




#sleep 30m;
#echo "exit_time=[$(date +%s)]";


exit 0



