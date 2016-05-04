#!/bin/bash
#This is simple script to help move Kafka partitions from one path to another and also edit the appropriate checkpoint files in each directory.

# Help 

if [[ $# <  6 ]]
then
  echo "When running this script, please make sure the broker is stopped!"
  echo "-sd|--source-directory         Source directory for partition move"
  echo "-dd|--destination-directory    Destination directory for partition move"
  echo "-p|--partitions                Space seperated list of partitions to move"
  echo "Example: ./test1.sh -sd /vol1/kafka -dd /vol2/kafka --partitions topic1 topic2"
exit 0
fi
# Getting opts
while [[ $# > 1 ]]
do
# Quick path checks
function testDir { if [[ ! -e $1 ]]; then echo "$1 path not found!"; exit 1; fi }
function testPar { for i in $parts; do if [[ ! -e $srcDir/$i ]]; then echo "$srcDir/$i partition path not found!"; exit 1; fi; done }
case $1 in 
  -sd|--source-directory)
  testDir $2
  srcDir="$2"
  shift
  ;;
  -dd|--destination-directory)
  testDir $2
  destDir="$2"
  shift
  ;;
  -p|--partitions)
  shift
  parts="$@"
  testPar
  shift
  ;;
  *)
  shift
  ;;
esac
done

# Confirming opts with user

echo "Input directory: $srcDir"
echo "Output directory: $destDir"
echo "Partition(s) to move: $parts"
echo "Proceed? [Y/n]"
read safe
case $safe in
  Y|Yes|yes)
  ;;
  *)
  echo "Exiting"
  exit 0
  ;;
esac

# Moving partitions

for i in $parts
do
  echo "Copying srcDir/$i"
  cp -pR $srcDir/$i $destDir/ || exit 1
  echo "Updating checkpoint files"
  # Checkpoint file change

  for checkFile in recovery-point-offset-checkpoint replication-offset-checkpoint
  do
    # making backups
    cp -p $srcDir/$checkFile /tmp/$checkFile.orig.$( echo $srcDir | sed "s/\//_/g" ).$RANDOM
    cp -p $destDir/$checkFile /tmp/$checkFile.orig.$( echo $destDir | sed "s/\//_/g" ).$RANDOM
    for i in $parts
    do
      chkPntName=$( echo $i | sed 's/\(.*\)-/\1 /' )
      pCntSrcOrig=$[ $( wc -l < $srcDir/$checkFile ) -2 ]
      pCntDestOrig=$[ $( wc -l < $destDir/$checkFile ) -2 ]   
      grep "$chkPntName" $srcDir/$checkFile >> $destDir/$checkFile 
      if (( $? > 0 ))
      then 
         echo "Could not move parition to new checkpoint file, exiting"
         exit 1
      fi
      pCntSrcNew=$[ $( wc -l < $srcDir/$checkFile ) -3 ]
      sed -e "2s/$pCntSrcOrig/$pCntSrcNew/" -e "/$chkPntName/d" -i.bak $srcDir/$checkFile || exit 1
      mv $srcDir/$checkFile.bak /tmp/$checkFile.bak.src
      pCntDestNew=$[ $( wc -l < $destDir/$checkFile ) -2 ]   
      sed -e "2s/$pCntDestOrig/$pCntDestNew/" -i.bak $destDir/$checkFile || exit 1
      mv $destDir/$checkFile.bak /tmp/$checkFile.bak.dest
    done
  done
  echo "Removing $srcDir/$i"
  rm -rf $srcDir/$i
done

