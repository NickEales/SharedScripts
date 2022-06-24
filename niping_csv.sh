#!/bin/bash

# This Sample Code is provided for illustration only and is not intended to be used in a production environment.  THIS SAMPLE 
# CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING 
# BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 

#
# reference: https://techcommunity.microsoft.com/t5/running-sap-applications-on-the/niping-8211-a-useful-tool-from-sap/ba-p/367109
#
# niping_csv.sh
#
#!/usr/bin/bash

serversToPing=( "remoteServerName1" "remoteServerName2" )
port=3298
nipingpath="./niping"
virtualhostname=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/name?api-version=2017-08-01&format=text")

echo "target,RTT(ms),TP(kB/s)"
for nipingserver in ${serversToPing[*]};
do
    tmpfilepath="./nipingreport/${virtualhostname}-$nipingserver.csv"
    countbegin=1
    countend=10
    while [[ ${countbegin} -le ${countend} ]];
    do
        if [[ ${countbegin} -eq 1 ]];then
        echo "target,RTT(ms),TP(kB/s)" > ${tmpfilepath}
        fi
        RTT=$(${nipingpath} -c -H $nipingserver -S ${port} -B 1 -L 100|grep -w av2|awk -F" " '{ print $2}')
        TP=$(printf '%.*f\n' 0  $(${nipingpath} -c -H $nipingserver -S ${port} -B 8000000|grep -w tr2|awk -F" " '{ print $2}'))
        echo "$nipingserver,${RTT},${TP}" >> ${tmpfilepath}
        (( countbegin++ ))
    done
    awk -F',' '{target=$1;sumRTT+=$2;sumTP+=$3; ++n} END { print target","sumRTT/n","sumTP/n }' < ${tmpfilepath}
done

