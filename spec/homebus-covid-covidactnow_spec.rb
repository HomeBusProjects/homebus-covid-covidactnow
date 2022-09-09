require 'spec_helper'

require 'homebus-covid-covidactnow/version'
require 'homebus-covid-covidactnow/options'
require 'homebus-covid-covidactnow/app'

require 'homebus/config'

class TestHomebusCovidCovidactnow < HomebusCovidCovidactnow::App
  # override config so that the superclasses don't try to load it during testing
  def initialize(options)
    @config = Hash.new
    @config = Homebus::Config.new

    @config.login_config = {
                            "default_login": 0,
                            "next_index": 1,
                            "homebus_instances": [
                                      {
                                        "provision_server": "https://homebus.org",
                                       "email_address": "example@example.com",
                                       "token": "XXXXXXXXXXXXXXXX",
                                       "index": 0
                                      }
                                    ]
    }

    @store = Hash.new
    super
  end
end

describe HomebusCovidCovidactnow do
  context "Version number" do
    it "Has a version number" do
      expect(HomebusCovidCovidactnow::VERSION).not_to be_nil
      expect(HomebusCovidCovidactnow::VERSION.class).to be String
    end
  end 
end

describe HomebusCovidCovidactnow::Options do
  context "Methods" do
    options = HomebusCovidCovidactnow::Options.new

    it "Has a version number" do
      expect(options.version).not_to be_nil
      expect(options.version.class).to be String
    end

    it "Uses the VERSION constant" do
      expect(options.version).to eq(HomebusCovidCovidactnow::VERSION)
    end

    it "Has a name" do
      expect(options.name).not_to be_nil
      expect(options.name.class).to be String
    end

    it "Has a banner" do
      expect(options.banner).not_to be_nil
      expect(options.banner.class).to be String
    end
  end
end

describe TestHomebusCovidCovidactnow do
  context "Methods" do
    options = HomebusCovidCovidactnow::Options.new
    app = HomebusCovidCovidactnow::App.new(options)

    it "Has a name" do
      expect(app.name).not_to be_nil
      expect(app.name.class).to be String
    end

    it "Consumes" do
      expect(app.consumes).not_to be_nil
      expect(app.consumes.class).to be Array
    end

    it "Publishes" do
      expect(app.publishes).not_to be_nil
      expect(app.publishes.class).to be Array
    end

    it "Has devices" do
      expect(app.devices).not_to be_nil
      expect(app.devices.class).to be Array
    end
  end
end
