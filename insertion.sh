#!/bin/sh

set -eux


start_time=$(date +%s);

NOW=$(date +"%Y/%m/%d/%H/%M/%S/%N")
echo "NOW=[$NOW]";



echo "AWS_S3_ENDPOINT=[$AWS_S3_ENDPOINT]"


mc alias set s3 "${AWS_S3_ENDPOINT}" "${AWS_ACCESS_KEY}" "${AWS_SECRET_KEY}"

### refer: https://medium.com/@y4m4/introducing-modern-find-alternative-b2fa15393481

#mc find s3/"${AWS_BUCKET}"/t-lcb-backend-ecsec2/fluent-bit-logs -path "*/2023/03/07/02/56/*" --name "*" --exec "mc cp -q {} /data/{dir}/{base}"



#mc find s3/"${AWS_BUCKET}"/t-lcb-backend-fg/fluent-bit-logs -path "*/$ONE_HOURS_AGO/*" --name "*" --exec "mc cp -q {} /data/{dir}/{base}"

### 抓前一個小時的 log

#ONE_HOURS_AGO=$(date --date='1 hours ago' +"%Y/%m/%d/%H")
#echo "ONE_HOURS_AGO=[$ONE_HOURS_AGO]"
#
#mc find s3/"${AWS_BUCKET}" -path "*/$ONE_HOURS_AGO/*" --name "*" --exec "mc cp -q {} /data/{dir}/{base}"




### 抓前 ｎ 分鐘內的 log

### 1684293613
### GMT: 2023年5月17日Wednesday 03:20:13
### 1684293913
### GMT: 2023年5月17日Wednesday 03:25:13

n=10
n_minute_ago=$((start_time - n * 60));

n_minute_ago_path=$(date -d @$n_minute_ago +%Y/%m/%d/%H/%M)

for ((i=$n;i>=0;i--))
do
  i_minute_ago=$((start_time - i * 60));
  i_minute_ago_path=$(date -d @$i_minute_ago +%Y/%m/%d/%H/%M)
  mc find s3/"${AWS_BUCKET}"/t-lcb-backend-fg/fluent-bit-logs -path "*/$i_minute_ago_path/*" --name "*" --exec "mc cp -q {} /data/{dir}/{base}" &
  #mc find s3/"${AWS_BUCKET}"/t-lcb-backend-fg/fluent-bit-logs -path "*/$i_minute_ago_path/*" --name "*" --exec "mc mirror --overwrite {} /data/{dir}/{base}"
done

wait



#mc alias set myminio "${MINIO_ENDPOINT}" "${MINIO_ACCESS_KEY}" "${MINIO_SECRET_KEY}" --api S3v4
#mc mb myminio/"data" --ignore-existing;
#mc cp --recursive /data/s3/ myminio/data/







#mc alias set s3 "${MINIO_ENDPOINT}" "${MINIO_ACCESS_KEY}" "${MINIO_SECRET_KEY}" --api S3v4
#
#mc mb s3/"${BUCKET}" --ignore-existing;
#
#for day in 01 02 03 04 05 06 07 08 09 10
#do
#  dd if=/dev/zero of=temp_file.data  bs=${day}K  count=1
#  mc cp /temp_file.data s3/"${BUCKET}"/client=1000/date=2021-09-${day}/temp_file.data
#  rm /temp_file.data
#done
#
#for day in 01 02 03 04 05 
#do
#  for hour in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
#  do
#    dd if=/dev/zero of=temp_file.data  bs=1K  count=1
#    mc cp /temp_file.data s3/"${BUCKET}"/client=2000/date=2021-09-${day}/hour=${hour}/temp_file.data
#    rm /temp_file.data
#  done
#done







end_time=$(date +%s)
runtime=$((end_time - start_time));
printf "Execution time: %.6f seconds\n" $runtime


