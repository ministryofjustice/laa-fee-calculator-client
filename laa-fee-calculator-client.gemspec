# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'laa/fee_calculator/version'

Gem::Specification.new do |spec|
  spec.name          = 'laa-fee-calculator-client'
  spec.version       = LAA::FeeCalculator::VERSION
  spec.authors       = ['Joel Sugarman', 'Ministry of Justice']
  spec.email         = ['joel.sugarman@digital.justice.gov.uk', 'tools@digital.justice.gov.uk']
  spec.date          = '2018-06-29'
  spec.summary       = 'Ruby client for the [LAA fee calculator API](https://github.com/ministryofjustice/laa-fee-calculator)'
  spec.description   = "Ruby client for the [ministryofjustice/laa-fee-calculator](https://github.com/ministryofjustice/laa-fee-calculator). Simple interface for transparent calling of the [API](https://github.com/ministryofjustice/laa-fee-calculator) endpoints, providing a simple interface for querying data, in particular, the primary function of the API, the `#calculate` endpoint."
  spec.homepage      = 'https://github.com/ministryofjustice/laa-fee-calculator-client'
  spec.license       = 'MIT'
  spec.extra_rdoc_files = ["LICENSE", "README.md"]

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # see bin/ruby_version_test
  spec.required_ruby_version = '>= 2.4.0'

  spec.add_runtime_dependency 'addressable', '~> 2.3.7'
  spec.add_runtime_dependency 'faraday', '~> 0.9.2'

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", '~> 0.50'
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
