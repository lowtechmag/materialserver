import json, requests, datetime, os
from darksky_api import token

date = datetime.date.today().strftime("%Y-%m-%d")
yesterday = datetime.date.today() - datetime.timedelta(1)
yesterday = yesterday.strftime("%Y-%m-%d")
forecast = 'forecast-{}'.format(date)
forecast_old = 'forecast-{}'.format(yesterday)

if not os.path.exists(forecast):
    #The latitude / longitude numbers below (41.48325,2.31539) determine the location of the forecast 
    url = 'https://api.darksky.net/forecast/{}/41.48325,2.31539?exclude=minutely,hourly,flags,alerts&units=si'.format(token)

    response = requests.get(url)
    data = json.loads(response.text)

    currently = data['currently']['summary']

    today = data['daily']['data'][0]['summary']
    today_icon = data['daily']['data'][0]['icon']

    tomorrow = data['daily']['data'][1]['summary']
    tomorrow_icon = data['daily']['data'][1]['icon']

    day_after_t = data['daily']['data'][2]['summary']
    day_after_t_icon = data['daily']['data'][2]['icon']


    string = '{}|{}|{}|{}|{}|{}'.format(today,tomorrow,day_after_t, today_icon, tomorrow_icon, day_after_t_icon)

    print(string)
    
    with open(forecast, 'w') as f:

        f.write(string)


if os.path.exists(forecast_old):
    os.remove(forecast_old)

