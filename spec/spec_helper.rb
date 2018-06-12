require "laa/fee_calculator"
require "bundler/setup"
require 'pry-byebug'
require 'awesome_print'
# require 'webmock/rspec'

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

  # configure gem for testing against local version of api
  LAA::FeeCalculator.configure do |config|
    # [un]comment to test against api running locally or remotely
    config.host = 'http://localhost:8000/api/v1'
    # config.host = LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
  end
end
