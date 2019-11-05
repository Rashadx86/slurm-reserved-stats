# slurm-reserved-stats
Script to produce slurm wait time statistics in human-readable and csv formats

Written in bash, run ./WaitTimes 

Usage: ./WaitTimes.sh -t $(date -d "-30 days" +%D) -p 'cpu_partition,gpu_partition' -a 'abclab xyzlab admin,admin2' 

Sample output:

```
Account: abclab
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

...

Account: admin,admin2
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
cmlab,50530,44964,893,2259,757,2,1487,140,9,19
admin+admin2,877,608,50,73,43,0,78,12,13,0

,=B2/$B2
---CSV END---
