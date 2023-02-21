#!/usr/bin/python3
# Brightsky Weather Parsing
# Copyright (C) Roel Roscam Abbing 2023, released under aGPLv3
# License: https://www.gnu.org/licenses/agpl-3.0.html
# Support your local Low-Tech Magazine: https://solar.lowtechmagazine.com/donate.html

import json
import requests
import os
from datetime import date, timedelta
from time import sleep

today = date.today().strftime("%Y-%m-%d")
midday = "T12:00"
midday_p1 = "T13:00"
yesterday = date.today() - timedelta(1)
yesterday = yesterday.strftime("%Y-%m-%d")
tomorrow = date.today() + timedelta(1)
tomorrow = tomorrow.strftime("%Y-%m-%d")
day_after_t = date.today() + timedelta(2)
day_after_t = day_after_t.strftime("%Y-%m-%d")
forecast = 'forecast-{}'.format(today)
forecast_old = 'forecast-{}'.format(yesterday)

if not os.path.exists(forecast):
    #The latitude / longitude numbers below (41.48325,2.31539) determine the location of the forecast
    #See Brightsky docs for more info: https://brightsky.dev/
    data=[]
    for d in [today, tomorrow, day_after_t]:
        url = "https://api.brightsky.dev/weather?date={}&last_date={}&lat=41.48325&lon=2.31539&source_id=4071&tz=Europe%2FMadrid&units=dwd".format(d+midday, d+midday_p1)
        response = requests.get(url)
        data.append(json.loads(response.text))
        time.sleep(0.1)

    
    today = data[0]['weather'][0]['condition']
    today_icon = data[0]['weather'][0]['icon']

    tomorrow = data[1]['weather'][0]['condition']
    tomorrow_icon = data[1]['weather'][0]['icon']

    day_after_t = data[2]['weather'][0]['condition']
    day_after_t_icon = data[2]['weather'][0]['icon']


    string = '{}|{}|{}|{}|{}|{}'.format(today,tomorrow,day_after_t, today_icon, tomorrow_icon, day_after_t_icon)

    print(string)
    
    with open(forecast, 'w') as f:

        f.write(string)


if os.path.exists(forecast_old):
    os.remove(forecast_old)

