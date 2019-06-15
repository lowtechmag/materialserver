# material server
a bash script exposing `AXP209` device power metrics, temperature and machine load as a JSON API. 
For Allwinner A20 ARM boards with the `AXP209` chipset that run [armbian](https://armbian.com)

It further pulls in daily weather predictions using the [darksky](https://darksky.net) api.  

## dependencies
* `jq` > 1.5
* a darksky account

### installation

`sudo apt get install jq`

Make sure you get a darksky API key. Enter your API token into darksky_api.py.

Update the url request string in darksky.py with your location.

## usage

`bash stats.sh > /var/www/html/api/stats.json`

in crontab:
`*/2 * * * * /bin/bash /folder/to/stats.sh > /var/www/html/api/stats.json`
