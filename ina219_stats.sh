#!/bin/bash
# INA219 Current sensor statistics
# Roel Roscam Abbing 2019
# Support your local Low-Tech Magazine: https://solar.lowtechmagazine.com/donate.html

precision=2 #how many decimal places 
units=1000 #for W/V/A use 1000
shunt_resistor=`cat /sys/class/hwmon/hwmon0/shunt_resistor`

#Power Measurements from INA219 chip
ac_power=( $(( $( cat /sys/class/hwmon/hwmon0/in1_input) * $(cat /sys/class/hwmon/hwmon0/curr1_input) ))) #in uW
wattage=( $(echo "scale=$precision; `cat /sys/class/hwmon/hwmon0/power1_input` / 1000000 " | bc )) #in W
amperage=( $(echo "scale=$precision; `cat /sys/class/hwmon/hwmon0/curr1_input` / $units " | bc )) #in A
voltage=( $(echo "scale=$precision; `cat /sys/class/hwmon/hwmon0/in1_input` / $units " | bc )) #in V

# The system is assumed to operate between 12 and 13 volts, 
# with 12v being the lower-end cut-off and anything over 13v
# representing sunshine and the system charging
charging="yes"
if (( $(echo "$voltage < 13" | bc -l) ));  then
	charging="no"
	fi

	if (( $(echo "$voltage > 12" | bc -l) && $(echo "$voltage < 13" | bc -l) ));	then
		bat_capacity=( $(echo "$voltage - 12.0" | bc))
		bat_capacity=( $(echo "($bat_capacity * 100)/1" | bc))

	else
		bat_capacity="100"

	fi

power_usage="${wattage}W|${amperage}A|${voltage}V|$charging|$bat_capacity"

# Other statistics
temp=( $(echo "scale=$precision; `cat /sys/devices/virtual/thermal/thermal_zone0/temp` / 1000 " | bc  ))
read -r -a load <<< $(cat /proc/loadavg) #get cpu load average
loads="${load[0]}|${load[1]}|${load[2]}"
# Time on-line and current date
upt="`uptime -p`"
upt=${upt:3}
time="`date +'%H:%M %Z'`"

# Weather forecast
`python3 brightsky.py`
today=(`date +"%F"`)
weather=$( cat forecast-${today} )

# Prepare and return the JSON
stats="W|A|V|charging|charge|temperature|uptime|load_1|load_5|load_15|local_time|today|tomorrow|day_after_t|today_icon|tomorrow_icon|day_after_t_icon
$power_usage|$temp|$upt|$loads|$time|$weather"

jq -Rn '
( input  | split("|") ) as $keys |
( inputs | split("|") ) as $vals |
[[$keys, $vals] | transpose[] | {key:.[0],value:.[1]}] | from_entries
' <<<"$stats"

