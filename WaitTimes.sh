#!/bin/bash

set -e
##Script to produce wait time statistics. 
##Edit $Accounts below to specify which Slurm accounts to query.
##Edit $Partitions to specify partitions; comment out to query all partitions.

##Ex. ./WaitTimes.sh -t 10/20/19 -p 'cryo-cpu,cryo-gpu' -a 'xyzlab abclab'

#Update variables below to change default query options. Runtime flags will override
export TimeFrame=$(date -d "-3 days" +%D)
#export Partitions='-r cryo-cpu,cryo-gpu'
#export Accounts=(xyzlab abclab)

while getopts 't:p:a:o:h' arg
do
        case "${arg}" in
                t) unset TimeFrame && TimeFrame=${OPTARG};;
                p) unset Partitions && Partitions='-r '${OPTARG};;
                a) unset Accounts && Accounts=($OPTARG);;
                o) unset OutputType && OutputType=($OPTARG);;
                h) echo "  Script to produce slurm wait time statistics in human-readable and csv formats"
                   echo
                   echo "   Default options are to display wait times for all accounts in all "
                   echo "   partitions over the past 90 days (each lab having it's own section)"
                   echo "   The timeframe, partitions, and accounts to query can be specified "
                   echo "   with the 't','p',and 'a' flags respectively."
                   echo "   CSV and human-readable both displayed by default, select which with '-o' flag"
                   echo
                   echo "   Ex: ./WaitTimes.sh -t MM/DD/YY -p 'PARTITION1,PARTITION2,PARTITION3' -a 'LAB1 LAB2 LAB3' -o hr"
                   echo 
                   echo "   Options: See example above for usage"
                   echo "        -t                Specify the Start time in slurm readable time format."
                   echo "        -p                Specify the partitions to query; separated by commas"
                   echo "        -a                Specify which accounts to query; separate by spaces"
                   echo "        -o                Display either csv or  human-readable. Selected by '-o csv' or '-o hr'"
                   echo "        -h                Display this help message"
                   exit 1
        esac
done

#Retrieve all slurm accounts if $Accounts is not defined
if [ -z "$Accounts" ]; then
        mapfile -t Accounts < <(sshare --noheader | awk '{print $1}' | uniq | grep -v root)
fi

#Confirm $Accounts is defined as an array
if [[ "$(declare -p Accounts)" =~ "declare -a" ]]; then
        true
else
        echo "ERROR: Accounts is not defined as an array" ; exit 1
fi


#Get wait times; convert days to hours; convert to digits in HHMMSS format
for i in ${Accounts[*]}
do
        sudo sacct $Partitions -A $i -S $TimeFrame -o "reserved" --noheader |
        awk 'NF' |
        sed 's/^[ \t]*//' |
        sed 's/-/ - /g' |
        awk '$2 ~ "-" {$1 = ($1 * 24 + $3 )}  1' |
        sed -E 's/ - [0-9][0-9]//g' |
        sed 's/://g' |
        sort > $i.parsed
done

##Count the jobs in each category
TotalJobs () { awk 'END{print NR}' $i.parsed; }
one_min () { awk '$1<=60{c++} END{print c+0}' $i.parsed; }
five_min () { awk '$1<=500 && $1>60{c++} END{print c+0}' $i.parsed ;}
thirty_min () { awk '$1<=3000 && $1>500{c++} END{print c+0}' $i.parsed ;}
one_hour () { awk '$1<=6000 && $1>3000{c++} END{print c+0}' $i.parsed ;}
four_hour () { awk '$1<=10000 && $1>6000{c++} END{print c+0}' $i.parsed ;}
eight_hour () { awk '$1<=80000 && $1>10000{c++} END{print c+0}' $i.parsed ;}
one_day () { awk '$1<=240000 && $1>80000{c++} END{print c+0}' $i.parsed ;}
two_day () { awk '$1<=480000 && $1>240000{c++} END{print c+0}' $i.parsed ;}
gttwo_day () { awk '$1>480000{c++} END{print c+0}' $i.parsed ;}


#Display stats in human-readable
output_hr () {
        for i in ${Accounts[*]}
        do
                echo "Account: $i"
                printf "Total Jobs: " && TotalJobs
                printf "1 Min: " && one_min
                printf "5 Min: " && five_min
                printf "30 Min: " && thirty_min
                printf "1 Hour: " && one_hour
                printf "4 Hours: " && four_hour
                printf "8 Hours: " && eight_hour
                printf "1 Day: " && one_day
                printf "2 Days: " && two_day
                printf ">2 Days: " && gttwo_day
        echo
        done
}

#Display stats in csv 
output_csv () {
        echo "---CSV BEGIN---"
        echo "Lab,Total Jobs,<1 Min,1 Min < x < 5 Mins,5 Mins < x < 30 Mins,30 Mins < x < 1 Hour,1 Hour < x < 4 Hours,4 Hours < x < 8 Hours,8 Hours < x < 1 Day,1 Day < x < 2 Days, > 2 Days"

        for i in ${Accounts[*]}
        do
                csv="${i//,/+},$(TotalJobs),$(one_min),$(five_min),$(thirty_min),$(one_hour),$(four_hour),$(eight_hour),$(one_day),$(two_day),$(gttwo_day)"
                echo "$csv"
        done

        echo -e '\n'',=B2/$B2'
        echo "---CSV END---"
}


if [[ $OutputType = "csv" ]]; then
        output_csv
elif [[ $OutputType = "hr" ]] || [[ $OutputType = "human-readable" ]]; then
        output_hr
elif [[ -n $OutputType ]] && [[ $OutputType != "hr" ]] && [[ $OutputType != "human-readable" ]] && [[ $OutputType != "csv" ]]; then
        echo "ERROR: Output type must be either 'csv' or 'hr', you entered $OutputType"
else
        output_hr
        output_csv
fi


#cleanup
for i in ${Accounts[*]}
do
        rm $i.parsed
done
