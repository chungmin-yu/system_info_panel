#!/bin/sh

awk 'BEGIN{{for(i=1;i<=9;i++)getline;} \
			npid=$1; ncomd="command"; nuser="user"; nres=$7; ncpu=$11; \
			{for(j=1;j<=5;j++){ getline; pid1[j]=$1; pid2[j]=$1; comd1[j]=$12; comd2[j]=$12; user1[j]=$2; user2[j]=$2; cpu1[j]=$11; res2[j]=$7; } } }  \
	NR>=15{ k=NR-9;pid1[k]=$1; comd1[k]=$12; user1[k]=$2; cpu1[k]=$11;} \
	END{{for(i=0;i<k-1;i++) \
				{for(j=1;j<k-i-1;j++) \
					{if(cpu1[j+1]>cpu1[j]){ \
						temp=pid1[j]; pid1[j]=pid1[j+1]; pid1[j+1]=temp; \
						temp=comd1[j]; comd1[j]=comd1[j+1]; comd1[j+1]=temp; \
						temp=user1[j]; user1[j]=user1[j+1]; user1[j+1]=temp; \
						temp=cpu1[j]; cpu1[j]=cpu1[j+1]; cpu1[j+1]=temp; }}}} \
		{print"Top Five Processes of WCPU over 0.5\n";} \
		{printf"%-10s %-20s %-10s %-10s\n", npid, ncomd, nuser, ncpu;} \
		{for(i=1;i<=5;i++){if(cpu1[i]-0>0.5) \
			{printf"%-10s %-20s %-10s %-10s\n", pid1[i], comd1[i], user1[i], cpu1[i]; num[user1[i]]++; } }} \
		{print"\nTop Five Processes of RES\n";} \
		{printf"%-10s %-20s %-10s %-10s\n", npid, ncomd, nuser, nres;} \
		{for(i=1;i<=5;i++) \
			{printf"%-10s %-20s %-10s %-10s\n", pid2[i], comd2[i], user2[i], res2[i]; num[user2[i]]++;} } \
		{print"\nBad Users:\n"} \
		{for(u in num) \
		{if(u=="root"){printf"\033[32mroot\033[0m\n";}  \
		else{if(num[u]>=2){printf"\033[31m%s\033[0m\n",u;}  \
		else{printf"\033[33m%s\033[0m\n",u;}  }} } }'
