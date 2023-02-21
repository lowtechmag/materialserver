# material server
a set bash scripts exposing device power metrics, temperature and machine load as a JSON API.

`axp_stats.sh` For Allwinner A20 ARM boards with the `AXP209` chipset that run [armbian](https://armbian.com)

`ina219_stats.sh` For devices that use an external `INA219` measurement circuit connected over `I2C` and loaded via the `ina2xx` kernel module

It further pulls in daily weather predictions using the [brightsky](https://brightsky.dev) API.  

## dependencies
* `jq` > 1.5

### installation

`sudo apt get install jq`

Update the url request string in `brightsky.py` with your location and other parameters you might need. Have a look at the [brightsky documentation](https://brightsky.dev/docs/) for options.

## usage

`bash ina219_stats.sh > /var/www/html/api/stats.json`

in crontab:
`*/2 * * * * /bin/bash /folder/to/ina219_stats.sh > /var/www/html/api/stats.json`
