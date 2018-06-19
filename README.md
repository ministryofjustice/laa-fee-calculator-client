[![Build Status](https://travis-ci.org/ministryofjustice/laa-fee-calculator-client.svg?branch=master)](https://travis-ci.org/ministryofjustice/laa-fee-calculator-client)

# Legal Aid Agency Fee Calculator Client

Ruby client for the [ministryofjustice/laa-fee-calculator](https://github.com/ministryofjustice/laa-fee-calculator). It enables transparent calling of this API's
endpoints, providing a simple interface for querying data, in particular, the primary function of the API, the `#calculate` endpoint.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'laa-fee-calculator-client'
```

And then execute:

    $ bundle

Or install it yourself as:

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
fee_scheme = client.fee_schemes(1)
# or
fee_scheme = client.fee_schemes(id: 1)
#
# or to retrieve a scheme matching specific criteria you can use the supplier_type (ADVOCATE | SOLICITOR) and case_date (the fee scheme applicable from that date)
fee_scheme = client.fee_schemes(supplier_type: 'ADVOCATE', case_date: '2017-01-01')

```
note: supplier type and its args are to be changed (20/06/2018) in API

###### Lookup data

```
# all
fee_scheme.advocate_types
fee_scheme.scenarios
fee_scheme.offence_classes
fee_scheme.fee_types
fee_scheme.modifier_types
fee_scheme.units

# filtered
# by id
fee_scheme.advocate_types('JRALONE')
fee_scheme.modifier_types(1)

# by options
fee_scheme.modifier_types(fee_type_code: 'AGFS_APPEAL_CON')
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jsugarman/laa-fee-calculator-client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
