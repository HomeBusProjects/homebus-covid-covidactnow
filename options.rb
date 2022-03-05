require 'homebus/options'

class COVIDActNowHomebusAppOptions < Homebus::Options
  def app_options(op)
    fipscode_help = 'the FIPS code of the reporting area'

    op.separator 'COVID ActNow options:'
    op.on('-f', '--fips-code FIPSCODE', fipscode_help) { |value| options[:fipscode] = value }
  end

  def banner
    'Homebus COVID Act Now stats publisher'
  end

  def version
    '0.0.1'
  end

  def name
    'homebus-covid-covidactnow'
  end
end
