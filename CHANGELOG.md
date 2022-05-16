# Changelog

Add latest change log entries at top using template:

```
## Version <version>
### Added
  -
### Fixed
  -
### Modified
  -
### Removed
  -
```


## Version 1.4.0

### Added
  - New configuration options for caching and logging

## Version 1.3.1

### Removed
  - `addressable` gem dependency

## Version 1.3.0

### Modified
  - update Faraday dependency

### Added
  - support for Ruby 3.0 and 3.1

### Removed
  - removed support for Ruby 2.6

## Version 1.2.0

### Modified
  - updated Faraday dependency
  - updated development dependencies - rubocop, bundler
### Added
  - support/testing for ruby 2.7.0
### Removed
  - removed support for ruby 2.5
  - removed testing against ruby versions less than 2.6

## Version 1.1.0

### Modified
  - updated Faraday dependency
  - Fixed deprecation warning resulting from `Faraday::Error::ClientError` being deprecated in favour of `Faraday::ClientError`
  - updated development dependencies - rubocop, bundler

## Version 1.0.0

#### Note
The [API itself](https://laa-fee-calculator.service.justice.gov.uk/api/v1/docs) has changed datacenter and domain name. This version defaults to using the newly hosted API. The old API will no longer receive updates and should be considered deprecated. It will be removed entirely once traffic to it is near zero - please raise an [issue](https://github.com/ministryofjustice/laa-fee-calculator-client/issues) if this is problematic.

### Added
  - support/testing for ruby 2.6.0, 2.6.2 and 2.6.3
### Removed
  - removed support for ruby 2.4
  - removed testing against ruby versions less than 2.5.5
### Modified
  - default host to [https://laa-fee-calculator.service.justice.gov.uk/api/v1](https://laa-fee-calculator.service.justice.gov.uk/api/v1)

## Version 1.0.0.rc1
### Added
  - support/testing for ruby 2.6.0, 2.6.2 and 2.6.3
### Removed
  - removed support for ruby 2.4
  - removed support/testing against ruby versions less than 2.5.5
### Modified
  - default host to [https://laa-fee-calculator.service.justice.gov.uk/api/v1](https://laa-fee-calculator.service.justice.gov.uk/api/v1)

