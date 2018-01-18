#!/bin/bash
# 'SubmitMatching.sh'
# Derek Anderson
#
# Use this to create xml scripts and submit them via
# 'star-submit'.  This will automatically generate a
# list of files to analyze.  The variable 'Path' will
# is the directory where the desired files are.
#
# NOTE: requires the script 'GenerateXMLnew.sh' (to generate
#       the job description file)


# job parameters
Path="/projecta/projectdirs/starprod/embedding/production2009_200GeV/Jet_pp200_2009.elz17/SL11d_embed"
MuList="pt7.mudst.list"
GeList="pt7.geant.list"
Prefix="pt7_9"
Label="thirdmaker"
Suffix=".root"
Nevnt=200000
Nfile=1

# submission parameters
sim="false"
num="1"
cwd=$PWD
sub=$PWD"/submit"
ver="SL14a"
mac="doFullJetTree.C"
opd=$PWD"/output/"$Prefix
log=$PWD"/logs"
# do not modify
ge='\\\"$FILEBASENAME.geant.root\\\"'
mu='\\\"$filename\\\"'
lst=$MuList



# generate lists
printf "\n  Running submission script...\n"
declare -a Runs
declare -a Files

# loop over days
(( nRdir=0 ))
cd $Path
for rDir in {.*,*}; do
  if [ $rDir != "." ]; then
    if [ $rDir != ".." ]; then
      Runs[nRdir]=$(echo $rDir)
      (( nRdir++ ))
    fi
  fi
done  # end of run loop

# at most there will be 26 files in a run
(( nFiles=0 ))
for f in `seq 0 26`; do
  Files[nFiles]=$f;
  (( nFiles++ ))
done
printf "    Generated input lists...\n"



# loop over days
cd $cwd
touch $MuList
touch $GeList
(( nFiles=0 ))
# loop over runs
for run in ${Runs[@]}; do

  runDir=$Path"/"$run
  if [ ! -d $runDir ]; then
    continue
  fi

  # check if bad run
  if [[ $runDir == *"do_not_use"* ]]; then
    continue
  fi


  # loop over files
  for file in ${Files[@]}; do

    muFile=$Prefix"_"$run"_"$file".MuDst"$Suffix
    muPath=$runDir"/"$muFile
    if [ ! -f $muPath ]; then
      continue
    fi

    geFile=$Prefix"_"$run"_"$file".geant"$Suffix
    gePath=$runDir"/"$geFile
    if [ ! -f $gePath ]; then
      continue
    fi

    # generate input list
    printf "$muPath" >> $MuList
    printf "$gePath" >> $GeList
    printf "\n" >> $MuList
    printf "\n" >> $GeList
    (( nFiles++ ))

  done  # end file loop
done  # end run loop
printf "    Generated file list '$GeList'...\n"
printf "      nFiles = $nFiles\n"


# generate output directory
./GenerateDir.sh $opd
printf "    Generated output directory '$opd'...\n"

# generate xml file
job=$Prefix"_"$Label
xml=$job".job.xml"
out='\\\"'$opd"/"'$FILEBASENAME.'$Label'.root\\\"'
arg=$(echo -e "\($Nevnt,$out,$mu\)")
./GenerateXML.sh $xml $sim $num $sub $ver $mac $arg $lst $log
printf "    Generated xml '$xml'...\n"

# generate log directory
if [ ! -d $log ]; then
  printf "  SubmitMatching.sh: Creating directory '$log'\n"
  mkdir $log
fi

# submit job
if [ ! -d $sub ]; then
  printf "  SubmitMatching.sh: Creating directory '$sub'\n"
  mkdir $sub
fi
cp $mac $sub
mv $xml $sub
mv $MuList $sub
mv $GeList $sub
cd $sub
star-submit $job".job.xml"
cd $cwd
printf "    Submited job '$job'...\n"


# delete input lists
unset Runs
unset Files

printf "  Finished submitting!\n\n"
