#!/bin/bash
#Set the working directory for the script to this one.
cd "$(dirname "$0")"

precision=2 #how many decimal places 
units=1000000 #for W/V/A use 1000 for mW/mV/mA

#AC Measurements
ac_power=( $(( $(cat /sys/power/axp_pmu/ac/amperage) / 1000 * $(cat /sys/power/axp_pmu/ac/voltage) / 1000 ))) #in uW
ac_power_watt=( $(echo "scale=$precision; $ac_power / $units" | bc) )  #in Watt
ac_amp=( $(echo "scale=$precision; `cat /sys/power/axp_pmu/ac/amperage` / $units " | bc )) #in Ah
ac_volt=( $(echo "scale=$precision; `cat  /sys/power/axp_pmu/ac/voltage` / $units " | bc )) #in V

ac_used="yes"
if [ $(cat /sys/power/axp_pmu/ac/used) -eq 0 ]
	then
		ac_used="no"
	fi


#Battery Measurements
bat_power=( $(echo "scale=$precision; `cat /sys/power/axp_pmu/battery/power`  / $units " | bc ))
bat_amp=( $(echo "scale=$precision; `cat /sys/power/axp_pmu/battery/amperage` / $units " | bc ))
bat_volt=( $(echo "scale=$precision; `cat /sys/power/axp_pmu/battery/voltage` / $units " | bc ))
bat_capacity=( $(cat /sys/power/axp_pmu/battery/capacity ))
#bat_charge=( $(cat /sys/power/axp_pmu/battery/charge )) #what is this variable?

bat_charging="yes"
if [ $(cat /sys/power/axp_pmu/battery/charging) -eq 0 ]
	then
		bat_charging="no"
	fi
#Other statistics

temp=( $(echo "scale=$precision; `cat /sys/devices/virtual/thermal/thermal_zone0/temp` / 1000 " | bc  ))

 
read -r -a load <<< $(cat /proc/loadavg) #get cpu load average
loads="${load[0]}|${load[1]}|${load[2]}"

upt="`uptime -p`"

ac="${ac_power_watt}W|${ac_amp}Ah|${ac_volt}V|$ac_used"
bat="${bat_power}W|${bat_amp}Ah|${bat_volt}V|${bat_capacity}%|$bat_charging"

time="`date +'%H:%M %Z'`"

`python3 darksky.py`
today=(`date +"%F"`)
weather=$( cat forecast-${today} )

#prepare and return the json
stats="ac_power|ac_current|ac_voltage|ac_used|bat_power|bat_current|bat_voltage|bat_capacity|bat_charging|temperature|uptime|load_1|load_5|load_15|local_time|today|tomorrow|day_after_t|today_icon|tomorrow_icon|day_after_t_icon
$ac|$bat|$temp|$upt|$loads|$time|$weather"

jq -Rn '
( input  | split("|") ) as $keys |
( inputs | split("|") ) as $vals |
[[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries
' <<<"$stats"
