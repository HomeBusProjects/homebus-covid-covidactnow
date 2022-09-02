require 'homebus/options'

require 'homebus-covid-covidactnow/version'

class HomebusCovidCovidactnow::Options < Homebus::Options
  def app_options(op)
    fipscode_help = 'the FIPS code of the reporting area'

    op.separator 'COVID ActNow options:'
    op.on('-f', '--fips-code FIPSCODE', fipscode_help) { |value| options[:fipscode] = value }
  end

  def banner
    'Homebus COVID Act Now stats publisher'
  end

  def version
    HomebusCovidCovidactnow::VERSION
  end

  def name
    'homebus-covid-covidactnow'
  end
end
