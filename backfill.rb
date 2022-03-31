#!/usr/bin/env ruby

# coding: utf-8

require './options'
require './app'

require 'net/http'
require 'json'

class BackfillCOVIDActNowHomebusApp < COVIDActNowHomebusApp
  def _url
    "https://api.covidactnow.org/v2/county/#{@fips_code}.timeseries.json?apiKey=#{@api_key}"
  end

  def _get_stats
    if File.exists? 'cache.json'
      puts 'using cache'
      return JSON.parse File.read('cache.json'), symbolize_names: true
    end

    begin
      uri = URI(_url)
      results = Net::HTTP.get(uri)
      puts results

      stats = JSON.parse results, symbolize_names: true

      File.write('cache.json', JSON.pretty_generate(stats))

      return stats
    rescue
      nil
    end
  end

  def _timestamp(date)
    d = DateTime.parse date
    return DateTime.new d.year, d.month, d.day, 12, 0, 0, 0, d.zone.to_f
  end

  def _find_metric(stats, date)
    stats[:metricsTimeseries].select { |m| m[:date] == date }.first
  end

  def _any_data?(data)
    yes_data = false

    data.keys.each do |key|
      if key != :update_date && data[key]
        yes_data = true
      end
    end

    if yes_data
      return data
    else
      return nil
    end
  end

  def _cases_payload(actuals, metrics, all_stats)
    results = {
      update_date: actuals[:date],
      population: all_stats[:population],
      positivity_ratio: metrics[:testPositivityRatio],
      case_density: metrics[:caseDensity],
      new_cases: actuals[:newCases],
      total_cases: actuals[:cases],
      infection_rate: metrics[:infectionRate],
    }

    return _any_data?(results)
  end

  def _hospitalizations_payload(actuals, metrics, all_stats)
    results = {
      update_date: all_stats[:lastUpdatedDate],
      new_deaths: actuals[:newDeaths]
    }
      
    if actuals[:hospitals] && actuals[:hospitals][:currentUsageCovid] && actuals[:hospitals][:capacity]
      results[:hospital_covid_ratio] = (actuals[:hospitals][:currentUsageCovid] / actuals[:hospitals][:capacity].to_f).truncate(2)
    end

    if actuals[:hospitals] && actuals[:hospitals][:currentUsageTotal] && actuals[:hospitals][:capacity]
      results[:hospital_ratio] =  (actuals[:hospitals][:currentUsageTotal] / actuals[:hospitals][:capacity].to_f).truncate(2)
    end


    if actuals[:icuBeds] && actuals[:icuBeds][:currentUsageCovid] && actuals[:icuBeds][:capacity]
      results[:icu_covid_ratio] = (actuals[:icuBeds][:currentUsageCovid]  / actuals[:icuBeds][:capacity].to_f).truncate(2)
    end

    if actuals[:icuBeds] && actuals[:icuBeds][:currentUsageTotal] && actuals[:icuBeds][:capacity]
      results[:icu_ratio] = (actuals[:icuBeds][:currentUsageTotal]  / actuals[:icuBeds][:capacity].to_f).truncate(2)
    end

    return _any_data?(results)
  end

  def _vaccinations_payload(actuals, metrics, all_stats)
    results = {
      update_date: all_stats[:lastUpdatedDate],
      vaccinations_initiated: metrics[:vaccinationsInitiatedRatio],
      vaccinations_completed: metrics[:vaccinationsCompletedRatio],
      vaccinations_boosted: metrics[:vaccinationsAdditionalDoseRatio]
    }

    return _any_data?(results)
  end

  def work!
    stats = _get_stats

    if options[:verbose]
      pp stats
    end

    stats[:actualsTimeseries].each do |actual|
      metric = _find_metric(stats, actual[:date])

      cases_payload = _cases_payload(actual, metric, stats)
      hospitalizations_payload = _hospitalizations_payload(actual, metric, stats)
      vaccinations_payload = _vaccinations_payload(actual, metric, stats)

      if options[:verbose]
        pp DDC_COVID_CASES, cases_payload
        pp DDC_COVID_HOSPITALIZATIONS, hospitalizations_payload
        pp DDC_COVID_VACCINATIONS, vaccinations_payload
      end

      timestamp = _timestamp(cases_payload[:date])

      if cases_payload
        @device.publish! DDC_COVID_CASES, cases_payload, timestamp
      end

      if hospitalizations_payload
        @device.publish! DDC_COVID_HOSPITALIZATIONS, hospitalizations_payload, timestamp
      end

      if vaccinations_payload
        @device.publish! DDC_COVID_VACCINATIONS, vaccinations_payload, timestamp
      end
    end

    puts 'backfill complete'
    exit
  end
end


cvan_app_options = COVIDActNowHomebusAppOptions.new

cvan = BackfillCOVIDActNowHomebusApp.new cvan_app_options.options
cvan.run!
#cvan.setup!
#cvan.work!
