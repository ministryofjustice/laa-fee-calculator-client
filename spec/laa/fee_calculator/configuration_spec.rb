RSpec.describe LAA::FeeCalculator::Configuration do
  describe '#host' do
    subject(:config) { described_class.new.host }

    it 'defaults to develpoment laa fee calculator api v1' do
      is_expected.to eql described_class::DEV_LAA_FEE_CALCULATOR_API_V1
    end
  end

  describe '#host=' do
    subject(:config) { described_class.new }
    let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }
    before { config.host = host }

    it 'assigns a non-default host' do
      expect(config.host).to eql host
    end
  end

  describe '#headers' do
    subject(:config) { described_class.new.headers }

    it 'defaults to JSON' do
      is_expected.to include('Accept' => 'application/json')
    end

    it 'includes user-agent' do
      is_expected.to include('User-Agent' => "laa-fee-calculator-client/#{LAA::FeeCalculator::VERSION}")
    end
  end

  describe '#headers=' do
    subject(:config) { described_class.new }
    let(:headers) { { 'Accept' => 'application/xml' } }
    before { config.headers = headers }

    it 'assigns a non-default header' do
      expect(config.headers).to eql headers
    end
  end
end
