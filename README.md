[![Build Status](https://travis-ci.org/ministryofjustice/laa-fee-calculator-client.svg?branch=master)](https://travis-ci.org/ministryofjustice/laa-fee-calculator-client)
[![Gem Version](https://badge.fury.io/rb/laa-fee-calculator-client.svg)](https://badge.fury.io/rb/laa-fee-calculator-client)
![](https://ruby-gem-downloads-badge.herokuapp.com/laa-fee-calculator-client?type=total)

# Legal Aid Agency Fee Calculator Client

Ruby client for the [ministryofjustice/laa-fee-calculator](https://github.com/ministryofjustice/laa-fee-calculator). It enables transparent calling of this API's
endpoints, providing a simple interface for querying data, in particular, the primary function of the API, the `#calculate` endpoint.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'laa-fee-calculator-client', '~> 0.1.1'
```

And then execute:

    $ bundle

Or install it yourself:

    $ gem install laa-fee-calculator-client

## Usage

<a name="quick-start"></a>
##### Quick start

```ruby
# retrieve a calculated value for AGFS scheme 9
client = LAA::FeeCalculator.client
fee_scheme = client.fee_schemes(1)

# using a hash of options
fee_scheme.calculate(
  scenario: 5,
  advocate_type: 'JRALONE',
  offence_class: 'E',
  fee_type_code: 'AGFS_APPEAL_CON',
  day: 1,
  number_of_defendants: 1,
  number_of_cases: 1
)
# => 130.0

# using a block to supply options
fee_scheme.calculate do |options|
  options[:scenario] = 5
  options[:offence_class] = 'E'
  options[:advocate_type] = 'JRALONE'
  options[:fee_type_code] = 'AGFS_APPEAL_CON'
  options[:day] = 1
  options[:number_of_defendants] = 1
  options[:number_of_cases] = 1
end
# => 130.0
```

##### Lookup endpoints

Lookup endpoints (`advocate_types`, `offence_classes`, `scenarios`, `fee_types`, `modifier_types`, `units`) respond to a single argument for the id, or options hashes (where id can also be specified explicitly). Any option key specified, except `id:`, will be converted to a URI param in the resulting request. `id`s will become part of the URI path itself. Options specified should therefore be available on the [ministryofjustice/laa-fee-caclulator](https://github.com/ministryofjustice/laa-fee-calculator)

```ruby
# instantiate a client
client = LAA::FeeCalculator.client
```

###### Fee schemes

All other endpoints are queried based on fee scheme so you will need one of these first

```ruby
# by id
fee_scheme = client.fee_schemes(1)
# or
fee_scheme = client.fee_schemes(id: 1)


# by type and/or date came into force
fee_scheme = client.fee_schemes(type: 'AGFS', case_date: '2018-01-01')
# => AGFS scheme 9 object

fee_scheme = client.fee_schemes(type: 'AGFS', case_date: '2018-04-01')
# => AGFS scheme 10 object
```

###### Lookup data

```
# all
fee_scheme.advocate_types
fee_scheme.scenarios
fee_scheme.offence_classes
fee_scheme.fee_types
fee_scheme.modifier_types
fee_scheme.units
fee_scheme.prices # defaults to first page (of 100)

# filtered
# by id
fee_scheme.advocate_types('JRALONE')
fee_scheme.modifier_types(1)

# by options
fee_scheme.modifier_types(fee_type_code: 'AGFS_APPEAL_CON')
fee_scheme.prices(scenario: 5, advocate_type: 'QC')

# searching (as opposed to query parameters filtering above)
# by attribute values
fee_scheme.scenarios.find_by(code: 'AS000002')
```

###### Calculate
see the [Quick start](#quick-start)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests.


To experiment with the code:

- clone the API's repo
```bash
git clone git@github.com:ministryofjustice/laa-fee-calculator.git
```

- setup and run the [API locally](https://github.com/ministryofjustice/laa-fee-calculator/blob/develop/docs/DEVELOPMENT.md)
- run `bin/console` for an interactive prompt in this repo's directory.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

The test suite makes extensive use of the [VCR](https://github.com/vcr/vcr) gem to stub requests to the external API. Any examples within a `describe` block with a `:vcr` tag will automatically use (or generate) VCR cassettes via an `around` block - see `spec_helper.rb`. All cassettes are stored in the `spec/vcr` directory and automatically named after the spec that produced them. Only new episodes/requests are created.

Note: VCR is configured to require a re-recording of cassettes once a year by default and will cause spec failures if this is not done. This can be disabled - see `spec_helper.rb` `re_record_interval`.

To recreate all cassettes:

- run the [laa-fee-calculator](https://github.com/ministryofjustice/laa-fee-calculator) API locally
- delete all files in `spec/vcr`
- `$ rspec`

Alternatively you can run tests against the local version of the API:

```bash
# run tests against local API
$ VCR_OFF=true rspec
```

You can also test against a hosted API by modifying the following in the `spec_helper.rb`

```ruby
# run tests against the default remote host
LAA::FeeCalculator.configure do |config|
  config.host = LAA::FeeCalculator::Configuration::LAA_FEE_CALCULATOR_API_V1
end

```

Note: 

## Contributing

Bug reports and pull requests are welcome on GitHub at [ministryofjustice/laa-fee-calculator-client](https://github.com/ministryofjustice/laa-fee-calculator-client)

## Publishing

1. Make required changes, run specs (rerecord vcr cassettes if necessary)

2. Run `bin/ruby_version_test` to test against ruby versions (2.5+ supported at present)

3. Update the VERSION in `lib/laa/fee_calculator/version` using [semantic versioning](https://guides.rubygems.org/patterns/#semantic-versioning).

4. Update the VERSION_RELEASED in `lib/laa/fee_calculator/version` to the date you intend to publish/release the version.

5. PR the change, code-review, merge.

6. Pull master and run rake task below to publish

```bash
$ rake release
```

This rake task automates the following:

```bash
$ git push -u origin <branch>
$ git tag -a v<VERSION> -m "Version <VERSION>"
$ git push origin v<VERSION>
$ gem build laa-fee-calculator-client.gemspec
$ gem push laa-fee-calculator-client-<VERSION>.gemspec
```
*`<VERSION>` is the value of `LAA::FeeCalculator::VERSION`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
