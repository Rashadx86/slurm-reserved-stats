# slurm-reserved-stats
Script to produce slurm wait time statistics in human-readable and csv formats

Written in bash, run ./WaitTimes.sh

Usage: `./WaitTimes.sh -s $(date -d "-30 days" +%D) -p 'PARTITION1,PARTITION2,PARTITION3' -a 'LAB1 LAB3,LAB4' `

Running ./WaitTimes.sh with no options will call on the default options in the script. This is to query all labs in all partitions over the last 3 days.

Options include the following:
```
-s                Specify the start time in any slurm readable time format. End time is until current time if undefined.
-e                Specify the end time in any slurm readable time format. Start time must be defined if end time is used.
-p                Specify the partitions to query; separated by commas
-a                Specify which accounts to query; separate by spaces. Accounts separated by commas will have their data aggregated together.
-o                Display either csv or  human-readable. Selected by '-o csv' or '-o hr'. Default is to display both
-h                Display this help message
```

Sample output:

```
[user@host ~]$ ./WaitTimes.sh -s MM/DD/YY -e MM/DD/YY -p 'PARTITION1,PARTITION2,PARTITION3' -a 'LAB1 LAB3,LAB4'
Account: LAB1
Total Jobs: 50530
1 Min: 44964
5 Min: 893
30 Min: 2259
1 Hour Min: 757
4 Hours: 2
8 Hours: 1487
1 Day: 140
2 Days: 9
>2 Days: 19

Account: LAB3,4
Total Jobs: 877
1 Min: 608
5 Min: 50
30 Min: 73
1 Hour Min: 43
4 Hours: 0
8 Hours: 78
1 Day: 12
2 Days: 13
>2 Days: 0


---CSV BEGIN---
Lab,Total Jobs,<1 Min,1 Min < x < 5 Mins,5 Mins < x < 30 Mins,30 Mins < x < 1 Hour,1 Hour < x < 4 Hours,4 Hours < x < 8 Hours,8 Hours < x < 1 Day,1 Day < x < 2 Days, >2 Days
LAB1,50530,44964,893,2259,757,2,1487,140,9,19
LAB3+LAB4,877,608,50,73,43,0,78,12,13,0

,=B2/$B2
---CSV END---
```

