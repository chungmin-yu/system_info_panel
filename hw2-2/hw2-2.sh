#!/bin/bash

showLoginRank(){
	local user=`last |  cut -d ' ' -f1 | sort | uniq -c|sort -n -r|\
		awk 'BEGIN{print"Rank Name      Times";temp1="wtmp";temp2="";}\
		NR<=5{if($2 != temp1){if($2 != temp2) printf"%1s    %-10s%-5s\n",NR,$2,$1}}'`
	
	dialog --title "LOGIN RANK" \
	--msgbox "${user}" 30 60
}
showPORTinfo(){
while true; do
	local port=`sockstat -4 -l|awk 'NR>2{printf"%-7s%4s_%-30s\n",$3,$5,$6}'`	
	#local pid=`sockstat -4 -l|awk 'NR>1{printf$3"\n"}'`
	
	pid=`dialog --stdout --menu "PORT INFO(PID and Port)" 30 60 25 ${port}`	
	if [ $? -ne 0 ]; then
		break
	fi

	#local state=`ps -u -j -p ${pid} |awk 'NR==2{print \
	#"USER: " $1 "\nPID: " $2 "\nPPID: " $12 "\nSTAT: " $8 "\n%CPU: " $3 "\n%MEM: " $4;}'`
	local user=`ps -u -j -p ${pid} |awk 'NR==2{print$1}'`
	local ppid=`ps -u -j -p ${pid} |awk 'NR==2{print$12}'`
	local stat=`ps -u -j -p ${pid} |awk 'NR==2{print$8}'`
	local cpu=`ps -u -j -p ${pid} |awk 'NR==2{print$3}'`
	local mem=`ps -u -j -p ${pid} |awk 'NR==2{print$4}'`	
	local command=`ps -u -j -p ${pid} |awk 'NR==2{print$11}'|\
	awk 'BEGIN{FS=":"}{print$1}'`
	
	dialog --title "Process Status: ${pid}" \
	--msgbox \
	"USER: ${user}\nPID: ${pid}\nPPID: ${ppid}\nSTAT: ${stat}\n%CPU: ${cpu}\n%MEM: ${mem}\nCOMMAND: ${command}" 30 60
done
}
showMOUNTinfo(){
while true;do
	local mount=`df -h -T|grep '[zn]fs'|awk '{printf"%-30s%-30s\n",$1,$7}'`
	
	filesystem=`dialog --stdout --menu "MOUNTPOINT INFO" 30 60 25 ${mount}`	
	if [ $? -ne 0 ]; then
		break
	fi
	
	local mountpoint=`df -h -T ${filesystem}| awk 'NR==2{print \
	"Filesystem: " $1 "\nType: " $2 "\nSize: " $3 "\nUsed: " $4 \
	"\nAvail: " $5 "\nCapacity: " $6 "\nMounted_on: " $7}'`
	
	dialog --title "${filesystem}" \
	--msgbox "${mountpoint}" 30 60
done
}
showSAVESYSTEMinfo(){
while true; do
	sroute=`dialog --stdout --title "Save to file" --inputbox "Enter the path:" 10 50`
	if [ $? -ne 0 ]; then
		break
	fi

	local sfile=`echo "${sroute}" | awk 'BEGIN{FS ="/"}{print $NF}'`
	local path=`echo "${sroute}" | sed "s/\/${sfile}$//g"`

	sexist=`test -d ${path} && echo "true" || echo "false"`
	if [ "${sexist}" == "false" ]; then
		dialog --stdout --title "Directory not found" --msgbox "${sroute} not found!" 30 60 
		continue
	fi
	
	touch empty

	local d=`date`
	echo -e "This system report is generated on ${d}" >> empty
	echo -e "================================================================" >> empty
	local hostname=`sysctl kern.hostname | awk '{print"Hostname: "$2"\n"}'`
	echo "${hostname}" >> empty
	local osname=`sysctl kern.ostype | awk '{print"OS Name: "$2"\n"}'`
	echo "${osname}" >> empty
	local osrelease=`sysctl kern.osrelease | awk '{print"OS Release Version: "$2"\n"}'`
	echo "${osrelease}" >> empty
	local osmodel=`sysctl hw.machine | awk '{print"OS Architecture: "$2"\n"}'`
	echo "${osmodel}" >> empty
	local pmodel=`sysctl hw.model | awk '{print"Processor Model: "$2"\n"}'`
	echo "${pmodel}" >> empty
	local ncpu=`sysctl hw.ncpu | awk '{print"Number of Processor Cores: "$2"\n"}'`
	echo "${ncpu}" >> empty
	local phymem=`sysctl hw.physmem | awk '{print $2}'`
	local phy=`echo "scale=2; ${phymem}/(1024^3)"|bc`
	local usermem=`sysctl hw.usermem | awk '{print $2}'`
	local free=`echo "scale=2; (${phymem}-${usermem})*100/${phymem}"|bc`
	local pmem=`echo -e "Total Physical Memory: ${phy} GB"`
	echo "${pmem}" >> empty
	local fmem=`echo -e "Free Memory (%): ${free}"`
	echo "${fmem}" >> empty
	local logged=`w | awk 'NR>2{print$1}' | uniq -c | awk 'END{print"Total logged in user: "NR}'`
	echo "${logged}" >> empty
	echo "asdfghjkl" >> empty
	
	mv empty ${sroute}

	if [ $? -ne 0 ]; then
		dialog --stdout --title "Permission Denied" --msgbox "No write permission to ${sroute}!" 30 60
		rm empty	
		continue
	fi

	local abs=`pwd`
	local r=`echo "${sroute}"|cut -c 1`
	if [ "${r}" != "/" ]; then
		local absroute=`echo -e "${abs}/${sroute}"`
	else
		local absroute=`echo -e "${sroute}"`
	fi

	dialog --stdout --title "System Info" \
	--msgbox \
	"This system report is generated on ${d}\n================================================================\n\
${hostname}\n${osname}\n${osrelease}\n${osmodel}\n${pmodel}\n${ncpu}\n${pmem}\n${fmem}\n${logged}\n\n\n\
The output file is saved to ${absroute}" 60 120
done
}
showLOADSYSTEMinfo(){
while true; do

	lroute=`dialog --stdout --title "Load from file" --inputbox "Enter the path:" 10 50`
	if [ $? -ne 0 ]; then
		break
	fi

	lexist=`test -f ${lroute} && echo "true" || echo "false"`
	if [ "${lexist}" == "false" ]; then
		dialog --stdout --title "Directory not found" --msgbox "${lroute} not found!" 30 60 
		continue
	fi

	local key=` tail -n 1 ${lroute}`
	local info=`head -n 11 ${lroute}`
	perm=`cat ${lroute}`
	if [ $? -ne 0 ]; then
		dialog --stdout --title "Permission Denied" --msgbox "No read permission to ${lroute}!" 30 60
		continue
	elif [ "${key}" != "asdfghjkl" ]; then
		dialog --stdout --title "File not found" --msgbox "The file is not generated by this program" 30 60
		continue
	fi

	local lfile=`echo ${lroute} | awk 'BEGIN{FS ="/"}{print $NF}'`	
	dialog --stdout --title "${lfile}" \
	--msgbox "${info}" 60 120
done
}

trap_ctrlc (){
	echo -e "\nCtrl+C pressed." >&1
	exit 2
}

trap "trap_ctrlc" 2

while true; do
	selection=`dialog --stdout --cancel-label "Exit" --menu "System Info Panel" 30 60 25 \
	1 "LOGIN RANK" 2 "PORT INFO" 3 "MOUNTPOINT INFO" 4 "SAVE SYSTEM INFO" 5 "LOAD SYSTEM INFO"`


	code=$?
	#if [ ${code} -ne 0 ]; then
		if [ ${code} -eq 1 ]; then
			echo -e "\nExit." >&1
			exit 0
		fi
		if [ ${code} -eq 255 ]; then
			echo -e "\nESC pressed." >&2
			exit 1
		fi	
	#fi

	case ${selection} in
		"1")showLoginRank;;
		"2")showPORTinfo;;
		"3")showMOUNTinfo;;
		"4")showSAVESYSTEMinfo;;
		"5")showLOADSYSTEMinfo;;
		"*")
		echo "error";;
	esac
done
	
