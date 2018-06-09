RSpec.describe LAA::FeeCalculator do
  it "has a version number" do
    expect(LAA::FeeCalculator::VERSION).not_to be nil
  end

  describe ".client" do
    subject { described_class.client }

    it 'returns a client object' do
      is_expected.to be_a LAA::FeeCalculator::Client
    end
  end

  describe '.configuration' do
    subject { described_class.configuration }

    it 'returns configuration object' do
      is_expected.to be_a LAA::FeeCalculator::Configuration
    end
  end

  describe '.configure' do
    it 'yields a config' do
      expect { |block| described_class.configure(&block) }.to yield_with_args(kind_of(LAA::FeeCalculator::Configuration))
    end

    context 'configuring host' do
      let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }

      before do
        described_class.configure do |config|
          config.host = host
        end
      end

      it 'changes the host configuration' do
        expect(LAA::FeeCalculator::configuration.host).to eql host
      end

      it 'changes the connection host' do
        expect(LAA::FeeCalculator::Connection.instance.host).to eql host
      end
    end
  end

  describe '.reset' do
    let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }

    before do
      described_class.configure do |config|
        config.host = host
      end
    end

    it 'resets the configured host' do
      expect(LAA::FeeCalculator::configuration.host).to eql host
      LAA::FeeCalculator.reset
      expect(LAA::FeeCalculator::configuration.host).to eql LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
    end

    it 'resets the connection host' do
      expect(LAA::FeeCalculator::Connection.instance.host).to eql host
      LAA::FeeCalculator.reset
      expect(LAA::FeeCalculator::Connection.instance.host).to eql LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
    end
  end
end
