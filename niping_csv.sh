#!/bin/bash
# set -x

# This script is intended to provide additional options to ths sample scripts provided here:
# https://techcommunity.microsoft.com/t5/running-sap-applications-on-the/collecting-and-displaying-niping-network-latency-measurements/ba-p/1833979
#
# reference: https://techcommunity.microsoft.com/t5/running-sap-applications-on-the/niping-8211-a-useful-tool-from-sap/ba-p/367109

#first parameter is the remote host to ping - it must be running the niping server. Exit if not provided.
if [[ -z $1 ]];
then
    echo "no target specified"
    exit
else
    TARGET="$1"
fi

# Check for presence of second parameter and assign it to the variable, otherwise use a default. This is the size of data to use in each ping loop.
if [[ -z $2 ]];
then
    SIZE=10
else
    SIZE=$2
fi

#Check for presence of third parameter and assign it to the variable, otherwise use a default.
if [[ -z $3 ]];
then
    LOOPS=1
else
    LOOPS=$3
fi

#Check for presence of fourth parameter and assign it to the variable, otherwise use a default.
if [[ -z $4 ]];
then
    VALUENAME="avg"
else
    VALUENAME=$4
fi

#echo "niping -c -H $TARGET -B $SIZE -L $LOOPS  -D 15 | tail -n 8  | head -n 7 | grep $VALUENAME"

./niping -c -H $TARGET -B $SIZE -L $LOOPS  -D 15 | tail -n 8  | head -n 7 | grep $VALUENAME | awk -v target_var="$TARGET" '
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    a[2,1]="target"
    a[2,2]=target_var
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR+1; i++){
            str=str","a[i,j];
        }
        print str
    }
}' | head -n2