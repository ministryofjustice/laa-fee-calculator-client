require "laa/fee_calculator"
require "bundler/setup"
require 'pry-byebug'
require 'awesome_print'
require 'webmock/rspec'
require 'vcr'

# require all spec support files
Dir[File.join(LAA::FeeCalculator.root,'spec','support','**','*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  #######################################################
  # Mocking and VCR                                     #
  #######################################################
  WebMock.disable_net_connect!(allow_localhost: true)

  LAA::FeeCalculator.configure do |config|
    # [un]comment to test against api running locally or remotely
    # or to recreate VCR cassettes
    config.host = 'http://localhost:8000/api/v1'
    # config.host = LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
  end

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/vcr'
    c.hook_into :webmock
    c.default_cassette_options = { re_record_interval: 3600 * 24 * 7 } # 7 days in seconds
  end

  # uncomment to turn off VCR for testing actual/local api
  VCR.turn_off!

  # record/use cassette named after the spec file, adding new interactions only
  config.around(:example, :vcr) do |example|
    if VCR.turned_on?
      cassette = File.basename(example.metadata[:file_path],'.*')
      VCR.use_cassette(cassette, :record => :new_episodes) do
        example.run
      end
    else
      example.run
    end
  end
  #######################################################
end
