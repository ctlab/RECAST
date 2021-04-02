#!/bin/bash

pwd=`dirname "$0"`

o="outDir"
w="workDir"
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -k|--k)
    k="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--donor-files)
    d1="$2"
    d2="$3"
    shift # past argument
    shift # past value
    shift # past value
    ;;
    -dk|--donor-kmers)
    dk="$2"
    shift
    shift
    ;;
    -b|--before-files)
    b1="$2"
    b2="$3"
    shift # past argument
    shift # past value
    shift # past value
    ;;
    -bk|--before-kmers)
    bk="$2"
    shift
    shift
    ;;
    -a|--after-files)
    a1="$2"
    a2="$3"
    shift # past argument
    shift # past value
    shift # past value
    ;;
    -ak|--after-kmers)
    ak="$2"
    shift
    shift
    ;;
    -o|--output-dir)
    o="$2"
    shift # past argument
    shift # past value
    ;;
    -corr|--correction)
    corr=true
    shift # past argument
    ;;
    -m|--memory)
    m="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--available-processors)
    p="$2"
    shift # past argument
    shift # past value
    ;;
    -w|--work-dir)
    w="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--verbose)
    v=true
    shift # past argument
    ;;
    -interval95|--interval95)
    interval95=true
    shift
    ;;
    -found|--found-threshold)
    foundThresh="$2"
    shift
    shift
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

mkdir $o

cmd="java "
if [[ $m ]]; then
    cmd+="-Xmx${m} -Xms${m} "
fi
cmd+="-jar ${pwd}/metacherchant.jar -t reads-classifier "
if [[ $k ]]; then
    cmd+="-k $k "
fi
if [[ $m ]]; then
    cmd+="-m $m "
fi
if [[ $p ]]; then
    cmd+="-p $p "
fi
if [[ $corr ]]; then
    cmd+="-corr "
fi
if [[ $v ]]; then
    cmd+="-v "
fi
if [[ $interval95 ]]; then
    cmd+="-interval95 "
fi
if [[ $foundThresh ]]; then
    cmd+="-found $foundThresh "
fi

cmd1=$cmd
if [[ ${ak} ]]; then
    cmd1+="-i ${ak} "
elif [[ ${a1} ]]; then
    cmd1+="-i ${a1} ${a2} "
fi
if [[ ${d1} ]]; then
    cmd1+="-r ${d1} ${d2} "
fi
cmd1+="-w $w/1/"

echo "$cmd1"
$cmd1
if [[ $? -eq 0 ]]; then
    cp "$w/1/reads_classifier/found_1.fastq" "$o/settle_1.fastq"
    cp "$w/1/reads_classifier/found_2.fastq" "$o/settle_2.fastq"
    cp "$w/1/reads_classifier/found_s.fastq" "$o/settle_s.fastq"
    cp "$w/1/reads_classifier/not_found_1.fastq" "$o/not_settle_1.fastq"
    cp "$w/1/reads_classifier/not_found_2.fastq" "$o/not_settle_2.fastq"
    cp "$w/1/reads_classifier/not_found_s.fastq" "$o/not_settle_s.fastq"
    echo "Donor reads processed"
else
    echo "error while donor reads processing"
    exit -1
fi


cmd2=$cmd
if [[ ${ak} ]]; then
    cmd2+="-i ${ak} "
elif [[ ${a1} ]]; then
    cmd2+="-i ${a1} ${a2} "
fi
if [[ ${b1} ]]; then
    cmd2+="-r ${b1} ${b2} "
fi
cmd2+="-w $w/2/"

echo "$cmd2"
$cmd2
if [[ $? -eq 0 ]]; then
    cp "$w/2/reads_classifier/found_1.fastq" "$o/stay_1.fastq"
    cp "$w/2/reads_classifier/found_2.fastq" "$o/stay_2.fastq"
    cp "$w/2/reads_classifier/found_s.fastq" "$o/stay_s.fastq"
    cp "$w/2/reads_classifier/not_found_1.fastq" "$o/gone_1.fastq"
    cp "$w/2/reads_classifier/not_found_2.fastq" "$o/gone_2.fastq"
    cp "$w/2/reads_classifier/not_found_s.fastq" "$o/gone_s.fastq"
    echo "Before reads processed"
else
    echo "error while before reads processing"
    exit -1
fi

cmd3=$cmd
if [[ ${dk} ]]; then
    cmd3+="-i ${dk} "
elif [[ ${d1} ]]; then
    cmd3+="-i ${d1} ${d2} "
fi
if [[ ${a1} ]]; then
    cmd3+="-r ${a1} ${a2} "
fi
cmd3+="-w $w/3/"

echo "$cmd3"
$cmd3
if [[ $? -eq 0 ]]; then
    #cp "$w/3/reads_classifier/found_1.fastq" "$o/came_from_donor_1.fastq"
    #cp "$w/3/reads_classifier/found_2.fastq" "$o/came_from_donor_2.fastq"
    #cp "$w/3/reads_classifier/found_s.fastq" "$o/came_from_donor_s.fastq"
    echo ""
else
    echo "error while after reads processing"
    exit -1
fi


cat $w/3/reads_classifier/found_s.fastq >> $w/3/reads_classifier/found_1.fastq
counts=`wc -l $w/3/reads_classifier/found_s.fastq`
counts_num=(`echo $counts | tr " " "\n"`)
for i in `seq 4 4 $counts_num`; do
echo $'@\r\n\r\n+\r\n' >> $w/3/reads_classifier/found_2.fastq
done

cmd4=$cmd
if [[ ${bk} ]]; then
    cmd4+="-i ${bk} "
elif [[ ${b1} ]]; then
    cmd4+="-i ${b1} ${b2} "
fi
cmd4+="-r $w/3/reads_classifier/found_1.fastq $w/3/reads_classifier/found_2.fastq "
cmd4+="-w $w/4/"

echo "$cmd4"
$cmd4
if [[ $? -eq 0 ]]; then
    cp "$w/4/reads_classifier/found_1.fastq" "$o/came_from_both_1.fastq"
    cp "$w/4/reads_classifier/found_2.fastq" "$o/came_from_both_2.fastq"
    cp "$w/4/reads_classifier/found_s.fastq" "$o/came_from_both_s.fastq"
    cp "$w/4/reads_classifier/not_found_1.fastq" "$o/came_from_donor_1.fastq"
    cp "$w/4/reads_classifier/not_found_2.fastq" "$o/came_from_donor_2.fastq"
    cp "$w/4/reads_classifier/not_found_s.fastq" "$o/came_from_donor_s.fastq"
    echo "After reads processed 1/2"
else
    echo "error while after reads processing"
    exit -1
fi
# ================================

cat $w/3/reads_classifier/not_found_s.fastq >> $w/3/reads_classifier/not_found_1.fastq
counts=`wc -l $w/3/reads_classifier/not_found_s.fastq`
counts_num=(`echo $counts | tr " " "\n"`)
for i in `seq 4 4 $counts_num`; do
echo $'@\r\n\r\n+\r\n' >> $w/3/reads_classifier/not_found_2.fastq
done

cmd5=$cmd
if [[ ${bk} ]]; then
    cmd5+="-i ${bk} "
elif [[ ${b1} ]]; then
    cmd5+="-i ${b1} ${b2} "
fi
cmd5+="-r $w/3/reads_classifier/not_found_1.fastq $w/3/reads_classifier/not_found_2.fastq "
cmd5+="-w $w/5/"

echo "$cmd5"
$cmd5
if [[ $? -eq 0 ]]; then
    cp "$w/5/reads_classifier/found_1.fastq" "$o/came_from_baseline_1.fastq"
    cp "$w/5/reads_classifier/found_2.fastq" "$o/came_from_baseline_2.fastq"
    cp "$w/5/reads_classifier/found_s.fastq" "$o/came_from_baseline_s.fastq"
    cp "$w/5/reads_classifier/not_found_1.fastq" "$o/came_itself_1.fastq"
    cp "$w/5/reads_classifier/not_found_2.fastq" "$o/came_itself_2.fastq"
    cp "$w/5/reads_classifier/not_found_s.fastq" "$o/came_itself_s.fastq"
    echo "After reads processed 2/2"
else
    echo "error while after reads processing"
    exit -1
fi

echo "SUCCESS"
