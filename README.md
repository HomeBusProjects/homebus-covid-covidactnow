# homebus-covid-covidactnow

![rspec](https://github.com/HomeBusProjects/homebus-aqi/actions/workflows/rspec.yml/badge.svg)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

Publishes COVID stats from [Covid Act Now's open API](https://apidocs.covidactnow.org) for regions in the United States. 

## Configuring

Create a `.env` file with the following lines:
```
API_KEY=
FIPS_CODE=
```

Set the API key to (the key issued by Covid Act Now)[https://apidocs.covidactnow.org).

The FIPS (Federal Information Processing Standard) code is a number identifying the county being queried. You can [look up the FIPS code for your county online](https://www.nrcs.usda.gov/wps/portal/nrcs/detail/national/home/?cid=nrcs143_013697). For instance, the FIPS code for Multnomah County, OR is 41051.

## Update Interval

COVID data is not updated frequently - generally once per day. Covid Act Now is very generous with access to their data. Please do not abuse their API by pulling data too frequently. Checking for new data once per minute is pointless; consider only checking every four to six hours.

## Data

The publisher provides three simple DDCs:

- org.homebus.experimental.covid-cases
- org.homebus.experimental.covid-hospitalizations
- org.homebus.experimental.covid-vaccinations

Each DDC provides incremental data from the previous 24 hour period as well as metrics (ratios, percentages) where appropriate.
