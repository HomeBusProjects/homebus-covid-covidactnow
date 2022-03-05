#!/usr/bin/env ruby

require './options'
require './app'

aqi_app_options = COVIDActNowHomebusAppOptions.new

aqi = COVIDActNowHomebusApp.new aqi_app_options.options
aqi.run!
