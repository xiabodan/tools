#!/bin/bash
  # set -x

  function log_info()
  {
      DATE=`date --rfc-3339=ns`
      USER=$(whoami)
      echo “${DATE} ${USER} [INFO] : $@” >> ~/log_info.log
  }

  log_info "--- start static crash log ---"

  cd ~/tool/crashlog

  # download and unzip file
  version=459 # ?? how to get version auto
  now=`date -d 'yesterday'  --rfc-3339=date`
  netfile=$now.tar.gz
  wget http://log.gplayspace.com/multi_account/$netfile
  # check the download file success or not
  if [ ! -f "$netfile" ]; then
    log_info "first download is not exist"
    wget http://log.gplayspace.com/multi_account/$netfile
  fi

  if [ ! -f "$netfile" ]; then
    log_info "download is not exist 2 times, exit"
    exit 0
  fi

  tar -xf $netfile $now/com.excean.gspace/$version/

  # static crash log
  gmsdir=`find $now -name com.google.android.gms`

  # current version gms total crash number
  num=`find $now -name *.log | wc`
  echo "current version $version has $num crash" > $now.crash.txt
  num1=`find $gmsdir -name *.log | wc`
  echo "current version $version gms has $num1 crash" >> $now.crash.txt

  emptyfile=`find $gmsdir -name "*" -type f -size 0c`
  rm "$emptyfile"
  python static1.py $gmsdir 0 >> $now.crash.txt

  # send mail to me
  mail -s "crash log of $now" xiabodan@163.com < $now.crash.txt

  # delete file before 2 day
  day2=`date -d '-2day'  --rfc-3339=date`
  rm $day2 $day2.tar.gz -rf

  log_info "--- end static crash log ---"
