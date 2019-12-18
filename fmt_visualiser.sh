#!/bin/bash

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
    -ext|--ext)
    ext="$2"
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
    -b|--before-files)
    b1="$2"
    b2="$3"
    shift # past argument
    shift # past value
    shift # past value
    ;;
    -a|--after-files)
    a1="$2"
    a2="$3"
    shift # past argument
    shift # past value
    shift # past value
    ;;
    -o|--output-dir)
    o="$2"
    shift # past argument
    shift # past value
    ;;
    -w|--work-dir)
    w="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--input-dir)
    i="$2"
    shift # past argument
    shift # past value
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
    -v|--verbose)
    v=true
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

cmd="java "
if [[ $m ]]; then
    cmd+="-Xmx${m} -Xms${m} "
fi
cmd+="-jar metacherchant.jar -t fmt-visualizer "
if [[ $k ]]; then
    cmd+="-k $k "
fi
if [[ $m ]]; then
    cmd+="-m $m "
fi
if [[ $p ]]; then
    cmd+="-p $p "
fi
if [[ $v ]]; then
    cmd+="-v "
fi
cmd+="-w $w -o $o "
if [[ ${d1} ]]; then
    cmd+="-donor ${d1} ${d2} "
fi
if [[ ${b1} ]]; then
    cmd+="-before ${b1} ${b2} "
fi
if [[ ${a1} ]]; then
    cmd+="-after ${a1} ${a2} "
fi
if [[ $i ]]; then
    cmd+="-i $i "
fi
if [[ ${ext} ]]; then
    cmd+="-ext ${ext} "
fi

echo "$cmd"
$cmd
if [[ $? -eq 0 ]]; then
    echo "SUCCESS"
else
    echo "error while after reads processing"
    exit -1
fi
