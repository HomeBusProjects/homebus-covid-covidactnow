# coding: utf-8

require 'homebus'

require 'dotenv'

require 'net/http'
require 'json'

class COVIDActNowHomebusApp < Homebus::App
  DDC_COVID_CASES = 'org.homebus.experimental.covid-cases'
  DDC_COVID_HOSPITALIZATIONS = 'org.homebus.experimental.covid-hospitalizations'
  DDC_COVID_VACCINATIONS = 'org.homebus.experimental.covid-vaccinations'

  def initialize(options)
    @options = options
    super
  end

  def update_interval
    60*60*4
  end

  def setup!
    Dotenv.load('.env')
    @api_key = ENV['API_KEY']
    @fips_code = ENV['FIPS_CODE']

    @device = Homebus::Device.new name: "COVID-19 Stats for #{@fips_code}",
                                  manufacturer: 'Homebus',
                                  model: 'COVID ActNow stats publisher',
                                  serial_number: @fips_code

  end

  def _url
    "https://api.covidactnow.org/v2/county/#{@fips_code}.json?apiKey=#{@api_key}"
  end

  def _get_stats
#    return JSON.parse File.read('cases.json'), symbolize_names: true

    begin
      uri = URI(_url)
      results = Net::HTTP.get(uri)

      stats = JSON.parse results, symbolize_names: true
      return stats
    rescue
      nil
    end
  end

  def work!
    stats = _get_stats

    if options[:verbose]
      pp stats
    end

    if stats &&
       stats[:metrics] &&
       stats[:actuals] &&
       stats[:actuals][:hospitalBeds] &&
       stats[:actuals][:icuBeds]
    then
      cases_payload = {
        update_date: stats[:lastUpdatedDate],
        population: stats[:population],
        positivity_ratio: stats[:metrics][:testPositivityRatio],
        case_density: stats[:metrics][:caseDensity],
        new_cases: stats[:actuals][:newCases],
        infection_rate: stats[:metrics][:infectionRate],
      }
      hospitalizations_payload = {
        update_date: stats[:lastUpdatedDate],
        hospital_covid_ratio: (stats[:actuals][:hospitalBeds][:currentUsageCovid] / stats[:actuals][:hospitalBeds][:capacity].to_f).truncate(2),
        hospital_ratio: (stats[:actuals][:hospitalBeds][:currentUsageTotal] / stats[:actuals][:hospitalBeds][:capacity].to_f).truncate(2),
        icu_covid_ratio: (stats[:actuals][:icuBeds][:currentUsageCovid]  / stats[:actuals][:icuBeds][:capacity].to_f).truncate(2),
        icu_ratio: (stats[:actuals][:icuBeds][:currentUsageTotal]  / stats[:actuals][:icuBeds][:capacity].to_f).truncate(2),
        new_deaths: stats[:actuals][:newDeaths]
      }

      vaccinations_payload = {
        update_date: stats[:lastUpdatedDate],
        vaccinations_initiated: stats[:metrics][:vaccinationsInitiatedRatio],
        vaccinations_completed: stats[:metrics][:vaccinationsCompletedRatio],
        vaccinations_boosted: stats[:metrics][:vaccinationsAdditionalDoseRatio]
      }

      if options[:verbose]
        pp DDC_COVID_CASES, cases_payload
        pp DDC_COVID_HOSPITALIZATIONS, hospitalizations_payload
        pp DDC_COVID_VACCINATIONS, vaccinations_payload
      end

      @device.publish! DDC_COVID_CASES, cases_payload
      @device.publish! DDC_COVID_HOSPITALIZATIONS, hospitalizations_payload
      @device.publish! DDC_COVID_VACCINATIONS, vaccinations_payload
    end

    sleep update_interval
  end

  def name
    'Homebus COVID Act Now stats publisher'
  end

  def publishes
    [ DDC_COVID_CASES, DDC_COVID_HOSPITALIZATIONS, DDC_COVID_VACCINATIONS ]
  end

  def devices
    [ @device ]
  end
end
