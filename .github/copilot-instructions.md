# LAA Fee Calculator Client

Ruby gem client for the [LAA Fee Calculator](https://github.com/ministryofjustice/laa-fee-calculator)
API. It wraps lookup and calculation endpoints behind Ruby objects under `LAA::FeeCalculator`, with
Faraday for HTTP, optional Faraday HTTP caching, RSpec tests, and VCR cassettes for integration-style
API calls.

## Build & test

Run commands from the repository root.

```sh
bin/setup
bundle exec rake
```

Useful checks:

```sh
bundle exec rspec
bundle exec rspec spec/laa/fee_calculator/client_spec.rb
bundle exec rubocop
bundle exec rake rubocop
bundle exec rake spec
bin/console
bundle exec rake install
bin/ruby_version_test
```

- The default `rake` task runs RuboCop and RSpec.
- CI runs RSpec across Ruby 3.3, 3.4, 4.0, plus allowed-failure `head`.
- CI runs RuboCop on Ruby 3.3.
- Prefer focused specs for small changes, then `bundle exec rake` before handing work back.
- Use `bin/console` to manually exercise the client API.

## Architecture

- **Public entry point**: `lib/laa/fee_calculator.rb` loads the gem and exposes
  `LAA::FeeCalculator.client`.
- **Client and connection**: `lib/laa/fee_calculator/client.rb`, `connection.rb`, and
  `configuration.rb` handle API host configuration, Faraday setup, headers, caching, and logging.
- **Resources and calculations**: `fee_scheme.rb`, `calculator.rb`, and `has_manyable.rb` provide the
  Ruby interface for fee schemes, lookup endpoints, nested resources, and `#calculate`.
- **Errors**: `errors.rb`, `raise_error.rb`, and related specs define client-facing error behaviour.
- **Versioning**: `lib/laa/fee_calculator/version.rb` defines both the gem version and User-Agent.

### VCR and external API behaviour

- VCR cassettes live under `spec/vcr` and are named after the spec file that produced them.
- Specs inside `describe` blocks tagged with `:vcr` automatically use `record: :new_episodes`.
- VCR cassettes re-record after one year by default via `re_record_interval` in `spec/spec_helper.rb`.
- To recreate all cassettes, run the `laa-fee-calculator` API locally, delete `spec/vcr/*`, then run
  `bundle exec rspec`.
- To test against a real local API without VCR, run `VCR_OFF=true bundle exec rspec` and configure
  the host in `spec/spec_helper.rb` if needed.
- The default remote API host is `https://laa-fee-calculator.service.justice.gov.uk/api/v1`.

### Publishing

- Follow the publishing checklist in [README.md](../README.md) before releasing.
- For releases, update `lib/laa/fee_calculator/version.rb` and `CHANGELOG.md` together.
- Run `bin/ruby_version_test` before publishing so supported Ruby versions are checked.
- `bundle exec rake release` creates the git tag, pushes commits/tags, builds the gem, and pushes to
  RubyGems. Only run it when explicitly asked and when RubyGems credentials are configured.

## Conventions

- This is a gem, so dependency changes usually belong in `laa-fee-calculator-client.gemspec`; test
  and development dependencies belong in `Gemfile`.
- Keep runtime dependencies small and compatible with the supported Ruby range (`>= 3.3.0`).
- RuboCop target Ruby is 3.3.0; keep code compatible with Ruby 3.3 unless support is deliberately
  changed.
- Do not update VCR cassettes casually; cassette churn should correspond to changed API behaviour or
  an intentional re-record.
- Keep `CHANGELOG.md` entries at the top using its existing `Added` / `Fixed` / `Modified` /
  `Removed` template.
- Commit messages should use British English. The title should be imperative and the body should use
  present tense. Filenames, code, and other technical references should be in backticks.
- Keep commits focused and preserve unrelated user changes. Do not rewrite history, commit, or push
  unless explicitly instructed by the user.
- When changing build, test, deployment, architecture, or major workflow conventions, update this
  file in the same PR if its guidance would become stale.

## Additional information

- Usage, VCR, caching, development, and publishing docs: [README.md](../README.md)
- Changelog format: [CHANGELOG.md](../CHANGELOG.md)
- Gem specification: [laa-fee-calculator-client.gemspec](../laa-fee-calculator-client.gemspec)
- CI workflows: [.github/workflows/rspec.yml](workflows/rspec.yml) and
  [.github/workflows/rubocop.yml](workflows/rubocop.yml)
- Local API service used by integration tests: [laa-fee-calculator](https://github.com/ministryofjustice/laa-fee-calculator)
