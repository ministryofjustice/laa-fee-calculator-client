# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'laa/fee_calculator/version'

Gem::Specification.new do |spec|
  spec.name          = 'laa-fee-calculator-client'
  spec.version       = LAA::FeeCalculator::VERSION
  spec.authors       = ['Katharine Ahern', 'Ministry of Justice']
  spec.email         = ['katharine.ahern@digital.justice.gov.uk', 'joel.sugarman@digital.justice.gov.uk', 'tools@digital.justice.gov.uk']
  spec.summary       = 'Ruby client for the Legal Aid Agency fee calculator API'
  spec.description   = 'Ruby client for the Ministry of Justices LAA fee calculator API. A simple interface for transparent calling of the API endpoints to query data and return calculated fee amounts.'
  spec.homepage      = 'https://github.com/ministryofjustice/laa-fee-calculator-client'
  spec.license       = 'MIT'
  spec.extra_rdoc_files = ['LICENSE', 'README.md']

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test/|spec/|features/|\..*)})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # see bin/ruby_version_test
  spec.required_ruby_version = '>= 3.0.0'

  spec.add_runtime_dependency 'faraday', '~> 2.9'
  spec.add_runtime_dependency 'faraday-http-cache', '~> 2.2'
  spec.add_runtime_dependency 'bigdecimal'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
