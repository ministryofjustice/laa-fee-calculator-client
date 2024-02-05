# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.client' do
    subject(:client) { described_class.client }

    it 'returns a client object' do
      expect(client).to be_a described_class::Client
    end
  end

  describe '.configuration' do
    subject(:configuration) { described_class.configuration }

    it 'returns configuration object' do
      expect(configuration).to be_a described_class::Configuration
    end

    it 'memoized' do
      expect(configuration).to equal(described_class.configuration)
    end
  end

  describe '.configure' do
    it 'yields a config' do
      expect { |block| described_class.configure(&block) }.to yield_with_args(kind_of(described_class::Configuration))
    end

    it 'returns a configuration' do
      expect(described_class.configure).to be_an_instance_of(described_class::Configuration)
    end

    context 'when configuring host' do
      let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }

      before do
        described_class.configure do |config|
          config.host = host
        end
      end

      it 'changes the host configuration' do
        expect(described_class.configuration.host).to eql host
      end

      it 'changes the connection host' do
        expect(described_class::Connection.instance.host).to eql host
      end
    end
  end

  describe '.reset' do
    subject(:reset) { described_class.reset }

    let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }

    before do
      described_class.configure do |config|
        config.host = host
      end
    end

    it 'resets the configured host' do
      expect { reset }
        .to change { described_class.configuration.host }
        .from(host)
        .to(described_class::Configuration::LAA_FEE_CALCULATOR_API_V1)
    end

    it 'resets the connection host' do
      expect { reset }
        .to change { described_class::Connection.instance.host }
        .from(host)
        .to(described_class::Configuration::LAA_FEE_CALCULATOR_API_V1)
    end
  end
end
