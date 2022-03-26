#!/usr/bin/env ruby

require './options'
require './app'

cvan_app_options = COVIDActNowHomebusAppOptions.new

cvan = COVIDActNowHomebusApp.new cvan_app_options.options
cvan.run!
